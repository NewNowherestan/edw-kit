# ~/.zsh_profiler.zsh

# Turn profiling on/off here
ZSH_PROFILE_STARTUP=${ZSH_PROFILE_STARTUP:-false}

# Directory for logs
ZPROF_LOG_DIR=${ZPROF_LOG_DIR:-$HOME/.zsh-profiles}

if [[ "$ZSH_PROFILE_STARTUP" == true ]]; then
  zmodload zsh/zprof
  mkdir -p "$ZPROF_LOG_DIR"
  ZPROF_LOG_FILE="$ZPROF_LOG_DIR/$(date +'%Y%m%d-%H%M%S').log"

  # Register a hook that runs at shell exit
  TRAPEXIT() {
    {
      echo "=== zprof at $(date +'%F %T') pid=$$ ==="
      zprof
    } >> "$ZPROF_LOG_FILE" 2>&1
  }
fi
