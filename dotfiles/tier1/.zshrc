export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(
  git
  history-substring-search
  zsh-syntax-highlighting
  aliases
  tmux
  iterm2
  docker
  copypath
  copyfile
  macos
  zsh-autosuggestions
)

source "$ZSH/oh-my-zsh.sh"

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
