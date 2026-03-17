GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUPSTREAM=auto
setopt PROMPT_SUBST

_git_prompt_info=""

_async_git_prompt() {
  local output
  output=$(__git_ps1 "(%s)" 2>/dev/null)
  
  local tmpfile="/tmp/zsh_git_prompt_$$"
  echo "$output" > "$tmpfile"
  
  kill -USR1 $$ 2>/dev/null
}

TRAPUSR1() {
  local tmpfile="/tmp/zsh_git_prompt_$$"
  if [[ -f "$tmpfile" ]]; then
    _git_prompt_info=$(<"$tmpfile")
    rm -f "$tmpfile"
    zle && zle reset-prompt
  fi
}

_precmd_async_git() {
  async_pid=${async_pid:-0}
  (( async_pid > 0 )) && kill -0 $async_pid 2>/dev/null && kill $async_pid 2>/dev/null
  
  _async_git_prompt &!
  async_pid=$!
}
precmd_functions+=(_precmd_async_git)
