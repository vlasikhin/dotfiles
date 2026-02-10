#!/bin/bash
input=$(cat)

eval "$(echo "$input" | jq -r '@sh "cwd=\(.workspace.current_dir) project_dir=\(.workspace.project_dir) model=\(.model.display_name) style=\(.output_style.name) remaining=\((.context_window.remaining_percentage // "") | tostring) vim_mode=\((.vim.mode // "") | tostring)"')"

relative_path="${cwd#$project_dir}"
[ "$relative_path" = "$cwd" ] && relative_path="~${cwd#$HOME}"
[ "$relative_path" = "" ] && relative_path="."

git_info=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    dirty=$(git -C "$cwd" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    stash=$(git -C "$cwd" stash list 2>/dev/null | wc -l | tr -d ' ')
    if [ "$dirty" -gt 0 ]; then
      git_info="$branch ~$dirty"
    else
      git_info="$branch ✓"
    fi
    [ "$stash" -gt 0 ] && git_info="$git_info ≡$stash"

    upstream=$(git -C "$cwd" rev-parse --abbrev-ref @{upstream} 2>/dev/null)
    if [ -n "$upstream" ]; then
      ahead=$(git -C "$cwd" rev-list --count @{upstream}..HEAD 2>/dev/null)
      behind=$(git -C "$cwd" rev-list --count HEAD..@{upstream} 2>/dev/null)
      [ "$ahead" -gt 0 ] && git_info="$git_info ↑$ahead"
      [ "$behind" -gt 0 ] && git_info="$git_info ↓$behind"
    fi
  fi
fi

ctx=""
if [ -n "$remaining" ]; then
  r="${remaining%.*}"
  case $((r/20)) in
    0) bar="░░░░░";; 1) bar="█░░░░";; 2) bar="██░░░";;
    3) bar="███░░";; 4) bar="████░";; *) bar="█████";;
  esac
  if [ "$r" -lt 15 ]; then cc="31"
  elif [ "$r" -lt 30 ]; then cc="33"
  else cc="32"
  fi
  ctx="\033[0;${cc}m${bar} ${r}%%"
fi

short_model=$(echo "$model" | sed 's/Claude //')
ct=$(date +%H:%M)

vim_ind=""
if [ -n "$vim_mode" ]; then
  if [ "$vim_mode" = "NORMAL" ]; then
    vim_ind="\033[0;34m⟨N⟩"
  else
    vim_ind="\033[0;32m⟨I⟩"
  fi
fi

printf "\033[0;36m %s " "$relative_path"
[ -n "$git_info" ] && printf "\033[2m❯\033[0;35m %s " "$git_info"
printf "\033[2m❯\033[0;33m %s " "$short_model"
[ "$style" != "default" ] && printf "\033[2m❯\033[0;32m %s " "$style"
[ -n "$ctx" ] && printf "\033[2m❯ $ctx \033[0m"
[ -n "$vim_ind" ] && printf " $vim_ind\033[0m"
printf " \033[2m%s\033[0m" "$ct"
printf "\n"
