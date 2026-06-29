# ~/.zshrc — managed by edw-kit (tiers/terminal/dotfiles). Edit there, not in ~.
#
# Load optional profiler
[[ -f "$HOME/.zsh_profiler.zsh" ]] && source "$HOME/.zsh_profiler.zsh"

# ── Homebrew on PATH ─────────────────────────────────────────────────────────
# The installer puts `brew shellenv` in ~/.zprofile, which only runs for LOGIN
# shells. Non-login interactive shells — Ghostty's quick terminal, tmux popups,
# `zsh -c` — skip it, so brew tools (starship, zoxide, tmux…) fall off PATH and
# everything below breaks. Load it here too; the guard makes it a no-op when
# .zprofile already ran.
if [[ -z "${HOMEBREW_PREFIX:-}" ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# ── Oh My Zsh ────────────────────────────────────────────────────────────────
export EDITOR=vim
export VISUAL=vim

export ZSH="$HOME/.oh-my-zsh"                  # core, owned by the shell tier
export ZSH_CUSTOM="$HOME/.config/omz-custom"   # plugins, owned by the terminal tier
export UDATE_ZSH_DAYS=7

ZSH_THEME="robbyrussell"      # cosmetic only — starship takes over the prompt below

# tmux plugin: auto-start/attach a "main" session on shell launch
#ZSH_TMUX_AUTOSTART=true
#ZSH_TMUX_AUTOSTART_ONCE=true
#ZSH_TMUX_AUTOCONNECT=true
#ZSH_TMUX_DEFAULT_SESSION_NAME="main"

# Custom plugins live in tiers/terminal/dotfiles/.config/omz-custom/plugins (submodules)
plugins=(
    git
    history-substring-search
    zsh-syntax-highlighting
    aliases
    tmux
#    docker
    copypath
    copyfile
    macos
    dirhistory
#    extract
    zsh-autosuggestions
    auto-notify
    zsh-you-should-use
    fzf-tab                   # requires fzf (Brewfile.terminal)

#    branch
#    colored-man-pages
#    man
    thefuck
    vi-mode
    zoxide
    # iterm2                  # re-enable if you go back to iTerm2
)

#Faster compinit (before OMZ so its wrappers use it)
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

source "$ZSH/oh-my-zsh.sh"

# ── Tool hooks ───────────────────────────────────────────────────────────────
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
eval "$(thefuck --alias)"

# ── Environment ──────────────────────────────────────────────────────────────
if [[ -n "$SSH_CONNECTION" ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

export TASKWARRIOR_TUI_TASKWARRIOR_CLI="/opt/homebrew/opt/task/bin/task"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ── Aliases ──────────────────────────────────────────────────────────────────
# Cheatsheet: docs/cheatsheets/aliases.md
alias tmux_main='tmux new-session -A -s main'
alias cc='clipcopy'           # stdin/file → clipboard
alias cv='clippaste'          # clipboard → stdout (was `cp`, which shadowed cp(1)!)
alias cnms='clippaste | nms -a -f cyan'
alias lgit='lazygit'
alias th='fuck'
alias cm='cmatrix -s -C cyan'
alias aerostat='aerospace list-windows --all --format "%{workspace} │ %{window-id} │ %{app-name} │ %{window-title}"| sort | column -t -s "│"'

alias adbscreen_save='adb exec-out screencap -p > ~/Downloads/screen_$(date +"%Y-%m-%d_%H-%M-%S").png'
alias adbscreen='adb exec-out screencap -p > /tmp/adb_screen.png && \
  osascript -e "set the clipboard to (read (POSIX file \"/tmp/adb_screen.png\") as «class PNGf»)"'

# ── Key bindings ─────────────────────────────────────────────────────────────
bindkey '^U' backward-kill-line
bindkey '^N' end-of-line
