# iTerm2 + tmux — Quick Reference Card

## Daily Workflow
```
Open iTerm2        → auto-attaches to tmux session "main"
New tab (⌘T)       → drops into bare zsh (NOT tmux)
Fix: always run    → tmux attach -t main
                     or: tmux attach (picks last session)

tmux ls            list all sessions
tmux attach -t <name>   attach to named session
tmux new -s <name>      create new named session
```

## PREFIX = Ctrl-a  (not default Ctrl-b)

## Sessions
```
C-a d         detach (session keeps running)
C-a s         interactive session switcher
C-a $         rename current session
C-a :new      new session from inside tmux
```

## Windows (tabs inside tmux)
```
C-a c         new window
C-a n / p     next / prev window
C-a <1-9>     jump to window by number
C-a F1–F12    jump to windows 10–21
C-a ,         rename window
C-a w         window list (visual picker)
C-a F         toggle window size mode
C-a &         kill window (confirm)
```

## Panes (splits inside window)
```
C-a |         split right (vertical)
C-a -         split down (horizontal)
C-a h/j/k/l   navigate left/down/up/right
C-a z         zoom pane fullscreen (toggle)
C-a !         break pane into its own window
C-a q         show pane numbers
C-a x         kill pane
```

## Copy Mode (vi)
```
C-a [         enter copy mode
h/j/k/l       move cursor (vi motions)
/             search forward
?             search backward
n / N         next / prev search result
v             begin selection
V             select line
y             copy to macOS clipboard (pbcopy)
Enter         copy to macOS clipboard + exit
q             quit copy mode
C-a ]         paste
```

## Useful Bindings
```
C-a r         reload ~/.tmux.conf
C-a m         toggle monitor activity on window
C-a y         toggle sync panes (type in all at once)
C-a :         command prompt
```

## Kill & Cleanup (from shell)
```
tmux kill-session -t <name>    kill one session
tmux kill-session -a           kill all except current
tmux kill-server               kill everything
```

## Kill from inside tmux
```
C-a :kill-session
C-a :kill-server
```

## "Pane is Dead" Recovery
```
tmux respawn-pane              rerun original command
tmux respawn-pane bash         fresh shell in dead pane
C-a :respawn-pane bash         same from inside tmux
C-a C-c                        (if bound) kill+respawn pane
```

## Nested tmux
```
Status bar turns RED when inside a tmux-inside-tmux.
Send prefix to inner session: C-a C-a
```

## iTerm2 Hotkeys
```
⌘T           new tab
⌘D           split pane right
⌘⇧D          split pane down
⌘W           close pane/tab
⌘⌥←/→        prev/next tab
⌘1–9         jump to tab N
⌘F           find in terminal output
⌘⌥;          jump between shell prompt marks
⌘⌥B          command history browser
Option key   configured as hotkey (dropdown window)
```

## Shell Integration (iTerm2 prompt marks)
```
Each prompt is marked → click to jump between outputs
⌘⌥↑/↓        jump to prev/next prompt mark
Click output block    select full command output
```

## imgcat / iTerm2 CLI
```
imgcat <file>        display image inline in terminal
imgls                ls with image thumbnails
it2dl <url>          download file to Mac (even over SSH)
it2ul <file>         upload file to remote
it2copy              copy to clipboard over SSH
it2setcolor          change terminal colorscheme from script
it2profile <name>    switch iTerm2 profile
it2attention         flash dock icon
it2tip               random iTerm2 tip
```
