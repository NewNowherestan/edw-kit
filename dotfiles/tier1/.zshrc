# zmodload zsh/zprof  # uncomment to profile startup: zsh -i -c 'zprof' 2>&1 | head -30

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(
  git
  history-substring-search
  zsh-syntax-highlighting
  aliases
  tmux
  docker
  copypath
  copyfile
  macos
  iterm2
  dirhistory
  extract
  zsh-autosuggestions
  zsh-auto-notify
  zsh-you-should-use
  fzf-tab                # requires fzf (brew install fzf — included in tier1)
)

source "$ZSH/oh-my-zsh.sh"

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
