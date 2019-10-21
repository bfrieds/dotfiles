#!/bin/bash

# vim: set foldmethod=marker :

# Prompts and colors {{{
# ====================================
RED='\[\033[00;31m\]'
GREEN='\[\033[00;32m\]'
YELLOW='\[\033[00;33m\]'
BLUE='\[\033[00;34m\]'
PURPLE='\[\033[00;35m\]'
CYAN='\[\033[00;36m\]'
LIGHTGRAY='\[\033[00;37m\]'

LRED='\[\033[01;31m\]'
LGREEN='\[\033[01;32m\]'
LYELLOW='\[\033[01;33m\]'
LBLUE='\[\033[01;34m\]'
LPURPLE='\[\033[01;35m\]'
LCYAN='\[\033[01;36m\]'
WHITE='\[\033[01;37m\]'

isGitRepo() {
  git rev-parse HEAD > /dev/null 2>&1
}

fullPrompt(){
  success=$?

  PS1="\n${BLUE}\u"
	PS1="${PS1} ${YELLOW} ${GREEN}\w"

  isGitRepo
  if [[ $? == 0 ]]
  then
    branch=$(git branch 2> /dev/null | grep "\*" | cut -d " " -f2)
    PS1="${PS1}${YELLOW}  ${BLUE}${branch}"
  fi

  PS1="${PS1}\n${YELLOW} \@"
  if [ $success -ne 0 ]; then
    PS1="${PS1} ${RED}${YELLOW}"
  fi

# »
  PS1="${PS1} ${YELLOW} \!"

	PS1="${PS1} ${BLUE} ${GREEN}"
}

minimalPrompt(){
  success=$?

  PS1="\n${YELLOW} ${GREEN}\W"

  isGitRepo
  if [[ $? == 0 ]]
  then
    branch=$(git branch 2> /dev/null | grep "\*" | cut -d " " -f2)
    PS1="${PS1}${YELLOW}  ${BLUE}${branch}"
  fi

  if [ $success -ne 0 ]; then
    PS1="${PS1} ${RED}${YELLOW}"
  fi

  PS1="${PS1}${YELLOW}  \!${BLUE} » ${GREEN}"
}

onelinerPrompt(){
  success=$?

  PS1="\n${YELLOW} ${GREEN}\w"

  isGitRepo
  if [[ $? == 0 ]]
  then
    branch=$(git branch 2> /dev/null | grep "\*" | cut -d " " -f2)
    PS1="${PS1}${YELLOW}  ${BLUE}${branch}"
  fi

  if [ $success -ne 0 ]; then
    PS1="${PS1} ${RED}${YELLOW}"
  fi

  PS1="${PS1}${YELLOW}  \!${BLUE} » ${GREEN}"
}

PROMPT_COMMAND=fullPrompt

export CLICOLOR=1
export LS_COLORS='di=0;35'

gruvbox_colors="$HOME/.dot_files/nvim/plugged/gruvbox/gruvbox_256palette_osx.sh"
test -f "$gruvbox_colors" && source $gruvbox_colors
# }}}

# Global Variables {{{
# ====================================
export VIMRC='$HOME/dot_files/nvim/init.vim'
export tmux='$HOME/dot_files/tmux/tmux.conf'

export EDITOR='nvim'
# }}}

# Aliases {{{
# ====================================
# <C-x> <C-e> to open vim and edit a command there

# Navigation
alias ..="cd .."
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias l='exa'
alias ll='exa -l --header'
alias lo='exa -l --sort=old --header'
alias la='exa -la --header'
alias lf='exa --header -d */'
alias lt='exa -T'


# Vim
alias v='nvim'
alias vim='nvim'
alias ebash='nvim ~/.bash_profile'
alias evim="nvim $VIMRC"

# Tmux
alias tmux='tmux -2'
alias tls='tmux ls'
alias tks='tmux kill-session -t'
alias tkill='tmux kill-server'
alias ta='tmux attach'
export TERM=xterm-256color

# Bash
alias bp="source $HOME/.bash_profile"
alias ls='ls -GFh'
alias ll='ls -la'

# cd to top level git dir
alias gcd='cd $(git rev-parse --show-toplevel)'
alias genv='source genv'

# Docker
alias d=docker
alias doc='docker'
alias dcomp='docker-compose'
alias dmongo='docker run -d -p 27017:27017 mongo'

# other
alias c='clear'
alias fup='python deploy/local/cluster_cmd.py fixture-up && python deploy/local/cluster_cmd.py logs'
alias fdn='make -C deploy/local fixture-down'
# }}}

# Plugins {{{
# ====================================
# autojump
[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh

# Bash Completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

# NVM
export NVM_DIR="$HOME/.nvm"
source "/usr/local/opt/nvm/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# FZF
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
# preview_opts='[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (highlight -O ansi -l {} || coderay {} || rougify {} || cat {}) 2> /dev/null | head -500'
# export FZF_DEFAULT_OPTS="--preview $preview_opts"

f () {
    fzf \
        --border \
        --preview '[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file \
            || (highlight -O ansi -l {} || coderay {} || rougify {} || cat {}) 2> \
            /dev/null | head -500' \
    "$@"
}

# FZF search files to open in vim
function vf() {
  nvim "$@" $(f -m)
}

# export FZF_DEFAULT_OPTS="--preview '[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (highlight -O ansi -l {} || coderay {} || rougify {} || cat {}) 2> /dev/null | head -500'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview' --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' --header 'Press CTRL-Y to copy command into clipboard' --border"
# Experimental
fzf-down() {
  fzf --height 50% "$@" --border
}

fs() {
  local session
  session=$(tmux list-sessions -F "#{session_name}" | \
    fzf --height 40% --reverse --query="$1" --exit-0) &&
  tmux switch-client -t "$session"
}

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-down -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
  cut -c4- | sed 's/.* -> //'
}

co() {
	git checkout $(gb)
}

gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -200' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {} | head -200'
}

gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -200' |
  grep -o "[a-f0-9]\{7,\}"
}

gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
  cut -d$'\t' -f1
}

if [[ $- =~ i ]]; then
  bind '"\er": redraw-current-line'
  bind '"\C-g\C-f": "$(gf)\e\C-e\er"'
  bind '"\C-g\C-b": "$(gb)\e\C-e\er"'
  bind '"\C-g\C-t": "$(gt)\e\C-e\er"'
  bind '"\C-g\C-h": "$(gh)\e\C-e\er"'
  bind '"\C-g\C-r": "$(gr)\e\C-e\er"'
fi

# }}}

# Path {{{
# ====================================
PATH="$PATH:$HOME/bin"
PATH="$PATH:$HOME/local_bin"
PATH="$PATH:/usr/local/bin"
PATH="$PATH:$HOME/.local/bin"

# Go installs packages here
export GOPATH="$HOME/go"
export GOBIN=$HOME/go/bin
export PATH=$PATH:$GOBIN
export PATH=$PATH:$GOROOT/bin
export GO111MODULE=on


export PATH="$HOME/.cargo/bin:$PATH"

local_conf="$HOME/.dot_files/shell/local_bin/local_conf.sh"
test -f "$local_conf" && source "$local_conf"
