#!/bin/bash
set -f

input=$(cat)

if [ -z "$input" ]; then
    printf "Claude"
    exit 0
fi

blue='\033[38;2;0;153;255m'
orange='\033[38;2;255;176;85m'
green='\033[38;2;0;160;0m'
cyan='\033[38;2;46;149;153m'
red='\033[38;2;255;85;85m'
yellow='\033[38;2;230;200;0m'
dim='\033[2m'
reset='\033[0m'

format_tokens() {
    local num=$1
    if [ "$num" -ge 1000000 ]; then
        awk "BEGIN {printf \"%.1fm\", $num / 1000000}"
    elif [ "$num" -ge 1000 ]; then
        awk "BEGIN {printf \"%.0fk\", $num / 1000}"
    else
        printf "%d" "$num"
    fi
}

build_bar() {
    local pct=$1
    local width=$2
    [ "$pct" -lt 0 ] 2>/dev/null && pct=0
    [ "$pct" -gt 100 ] 2>/dev/null && pct=100

    local filled=$(( pct * width / 100 ))
    local empty=$(( width - filled ))

    local bar_color
    if [ "$pct" -ge 90 ]; then bar_color="$red"
    elif [ "$pct" -ge 70 ]; then bar_color="$yellow"
    elif [ "$pct" -ge 50 ]; then bar_color="$orange"
    else bar_color="$green"
    fi

    local filled_str="" empty_str=""
    [ "$filled" -gt 0 ] && filled_str=$(printf '━%.0s' $(seq 1 "$filled"))
    [ "$empty" -gt 0 ] && empty_str=$(printf '─%.0s' $(seq 1 "$empty"))

    printf "${bar_color}${filled_str}${dim}${empty_str}${reset}"
}

_jq_out=$(echo "$input" | jq -r '
    (.model.display_name // "Claude"),
    (.workspace.current_dir // ""),
    (.context_window.context_window_size // 200000 | tostring),
    (.context_window.current_usage.input_tokens // 0 | tostring),
    (.context_window.current_usage.cache_creation_input_tokens // 0 | tostring),
    (.context_window.current_usage.cache_read_input_tokens // 0 | tostring)')
{ read -r model_name; read -r cwd; read -r size; read -r input_tokens; read -r cache_create; read -r cache_read; } <<< "$_jq_out"

git_info=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        dirty=$(git -C "$cwd" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        if [ "$dirty" -gt 0 ]; then
            git_info="$branch ~$dirty"
        else
            git_info="$branch"
        fi
        upstream=$(git -C "$cwd" rev-parse --abbrev-ref @{upstream} 2>/dev/null)
        if [ -n "$upstream" ]; then
            ahead=$(git -C "$cwd" rev-list --count @{upstream}..HEAD 2>/dev/null)
            behind=$(git -C "$cwd" rev-list --count HEAD..@{upstream} 2>/dev/null)
            [ "$ahead" -gt 0 ] && git_info="$git_info ↑$ahead"
            [ "$behind" -gt 0 ] && git_info="$git_info ↓$behind"
        fi
    fi
fi

[ "$size" -eq 0 ] 2>/dev/null && size=200000
current=$(( input_tokens + cache_create + cache_read ))

used_tokens=$(format_tokens $current)
total_tokens=$(format_tokens $size)

if [ "$size" -gt 0 ]; then
    pct_used=$(( current * 100 / size ))
else
    pct_used=0
fi
context_bar=$(build_bar "$pct_used" 15)

line1=""
line1+="${blue}${model_name}${reset}"
[ -n "$git_info" ] && line1+=" ${dim}|${reset} ${green}${git_info}${reset}"
line1+=" ${dim}|${reset} "
line1+="${context_bar} ${orange}${used_tokens}/${total_tokens}${reset} ${dim}${pct_used}%${reset}"

get_oauth_token() {
    if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
        echo "$CLAUDE_CODE_OAUTH_TOKEN"
        return 0
    fi

    if command -v security >/dev/null 2>&1; then
        local blob
        blob=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
        if [ -n "$blob" ]; then
            local token
            token=$(echo "$blob" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
            if [ -n "$token" ] && [ "$token" != "null" ]; then
                echo "$token"
                return 0
            fi
        fi
    fi

    local creds_file="${HOME}/.claude/.credentials.json"
    if [ -f "$creds_file" ]; then
        local token
        token=$(jq -r '.claudeAiOauth.accessToken // empty' "$creds_file" 2>/dev/null)
        if [ -n "$token" ] && [ "$token" != "null" ]; then
            echo "$token"
            return 0
        fi
    fi

    echo ""
}

iso_to_epoch() {
    local iso_str="$1"

    local epoch
    epoch=$(date -d "${iso_str}" +%s 2>/dev/null)
    if [ -n "$epoch" ]; then
        echo "$epoch"
        return 0
    fi

    local stripped="${iso_str%%.*}"
    stripped="${stripped%%Z}"
    stripped="${stripped%%+*}"

    if [[ "$iso_str" == *"Z"* ]] || [[ "$iso_str" == *"+00:00"* ]] || [[ "$iso_str" == *"-00:00"* ]]; then
        epoch=$(env TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$stripped" +%s 2>/dev/null)
    else
        epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$stripped" +%s 2>/dev/null)
    fi

    if [ -n "$epoch" ]; then
        echo "$epoch"
        return 0
    fi

    return 1
}

format_time_remaining() {
    local iso_str="$1"
    [ -z "$iso_str" ] || [ "$iso_str" = "null" ] && return

    local epoch
    epoch=$(iso_to_epoch "$iso_str")
    [ -z "$epoch" ] && return

    local now
    now=$(date +%s)
    local diff=$(( epoch - now ))
    [ "$diff" -le 0 ] && { printf "now"; return; }

    local hours=$(( diff / 3600 ))
    local mins=$(( (diff % 3600) / 60 ))

    if [ "$hours" -gt 0 ]; then
        printf "%dh%dm" "$hours" "$mins"
    else
        printf "%dm" "$mins"
    fi
}

format_reset_date() {
    local iso_str="$1"
    [ -z "$iso_str" ] || [ "$iso_str" = "null" ] && return

    local epoch
    epoch=$(iso_to_epoch "$iso_str")
    [ -z "$epoch" ] && return

    date -j -r "$epoch" +"%a %H:%M" 2>/dev/null || \
    date -d "@$epoch" +"%a %H:%M" 2>/dev/null
}

cache_file="/tmp/claude/statusline-usage-cache.json"
cache_max_age=60
mkdir -p /tmp/claude

needs_refresh=true
usage_data=""

if [ -f "$cache_file" ]; then
    cache_mtime=$(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null)
    now=$(date +%s)
    cache_age=$(( now - cache_mtime ))
    if [ "$cache_age" -lt "$cache_max_age" ]; then
        needs_refresh=false
        usage_data=$(cat "$cache_file" 2>/dev/null)
    fi
fi

if $needs_refresh; then
    token=$(get_oauth_token)
    if [ -n "$token" ] && [ "$token" != "null" ]; then
        response=$(curl -s --max-time 5 \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $token" \
            -H "anthropic-beta: oauth-2025-04-20" \
            -H "User-Agent: claude-code/2.1.34" \
            "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)
        if [ -n "$response" ] && echo "$response" | jq . >/dev/null 2>&1; then
            usage_data="$response"
            echo "$response" > "$cache_file"
        fi
    fi
    if [ -z "$usage_data" ] && [ -f "$cache_file" ]; then
        usage_data=$(cat "$cache_file" 2>/dev/null)
    fi
fi

if [ -n "$usage_data" ] && echo "$usage_data" | jq -e . >/dev/null 2>&1; then
    _usage_jq=$(echo "$usage_data" | jq -r '
        ((.five_hour.utilization // 0) | round | tostring),
        (.five_hour.resets_at // ""),
        ((.seven_day.utilization // 0) | round | tostring),
        (.seven_day.resets_at // "")')
    { read -r five_pct; read -r five_reset_iso; read -r seven_pct; read -r seven_reset_iso; } <<< "$_usage_jq"
    five_remaining=$(format_time_remaining "$five_reset_iso")
    five_bar=$(build_bar "$five_pct" 10)
    seven_reset=$(format_reset_date "$seven_reset_iso")
    seven_bar=$(build_bar "$seven_pct" 10)

    line1+=" ${dim}|${reset} "
    line1+="${dim}session${reset} ${five_bar} ${cyan}${five_pct}%${reset}"
    [ -n "$five_remaining" ] && line1+=" ${dim}${five_remaining}${reset}"

    line1+=" ${dim}|${reset} "
    line1+="${dim}weekly${reset} ${seven_bar} ${cyan}${seven_pct}%${reset}"
    [ -n "$seven_reset" ] && line1+=" ${dim}${seven_reset}${reset}"
fi

printf "%b" "$line1"

exit 0
