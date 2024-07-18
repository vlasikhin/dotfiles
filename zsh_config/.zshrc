export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="vpa"
plugins=(bundler gitfast)
source $ZSH/oh-my-zsh.sh

eval "$(rbenv init - zsh)"

eza_params=('--git' '--classify' '--group-directories-first' '--time-style=long-iso' '--group' '--color-scale')

alias ls='eza $eza_params'
alias l='eza --git-ignore $eza_params'
alias ll='eza --all --header --long $eza_params'
alias llm='eza --all --header --long --sort=modified $eza_params'
alias la='eza -lbhHigUmuSa'
alias lx='eza -lbhHigUmuSa@'
alias lt='eza --tree $eza_params'
alias tree='eza --tree $eza_params'

alias ss="subl"
alias sss="subl ."
alias as="bin/dathena start"
