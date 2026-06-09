# Other Commands — Quick Reference Card

## Zsh / Shell
```
Ctrl-R           fuzzy history search (type fragment, cycle)
↑ / ↓            history substring search (type first, then arrow)
Ctrl-A           jump to line start
Ctrl-E           jump to line end
Ctrl-W           delete word back
Ctrl-U           clear line
Ctrl-L           clear screen
Ctrl-D           exit shell / close pane
cd -             go back to previous directory
dirs -v          show directory stack
pushd / popd     push/pop directory stack
```

## Oh My Zsh — Plugins in Use
```
git                  git aliases
history-substring-search   ↑↓ search history by partial string
zsh-syntax-highlighting    green=valid, red=invalid as you type
aliases              als command to search aliases
tmux                 auto-start/attach tmux on open
iterm2               tab-complete for it2*, imgcat
docker               docker aliases + tab completion
copypath             copy dir path to clipboard
copyfile             copy file contents to clipboard
macos                Finder/macOS bridge (see Aliases card)
```

## Docker Plugin Quick Aliases
```
dps      docker ps
dpsa     docker ps -a
drit     docker container run -it
dlo      docker container logs
dxc      docker container exec
dsts     docker stats (live)
dils     docker image ls
dsta     stop all running containers
dipru    docker image prune -a
```

## nvm (Node Version Manager)
```
nvm ls                   list installed node versions
nvm ls-remote            list available versions
nvm install <ver>        install node version
nvm use <ver>            switch node version
nvm alias default <ver>  set default version
node -v / npm -v         check current versions
```

## IdeaVim Setup (IntelliJ IDEA)
```
# Install IdeaVim plugin in IDEA: Settings → Plugins → IdeaVim
# In ~/.ideavimrc:
source ~/.vim/vimrc

# Add IDEA-specific actions:
map \r <Action>(ReformatCode)
map \b <Action>(ToggleLineBreakpoint)
map gd <Action>(GotoDeclaration)
map gi <Action>(GotoImplementation)
map \e <Action>(ShowErrorDescription)
map \f <Action>(FindInPath)
```

### IntelliJ IDEA essential shortcuts
```
⌘⇧A     action search (find any action/menu)
⌘E      recent files
⌘⇧E     recent edit locations
⌘B      go to declaration
⌘⌥B     go to implementation
Alt+F12  embedded terminal (full Zsh/tmux)
⌘⌥L     reformat code
⌘/      comment/uncomment line
⌘D      duplicate line
⌘⇧F     find in path (project-wide)
⌘R      replace in file
⌘⇧R     replace in path
```

## macOS System
```
open <file>              open file with default app
open -a "App Name" <f>   open with specific app
open .                   open current dir in Finder
open "https://..."       open URL in default browser
pbcopy < file.txt        copy file contents to clipboard
pbpaste > file.txt       paste clipboard to file
say "text"               macOS text-to-speech
caffeinate               prevent sleep (Ctrl-C to stop)
caffeinate -t 3600       prevent sleep for 1 hour
```

## Useful One-liners
```
# Find and kill process on port
lsof -ti:3000 | xargs kill -9

# Check what's on a port
lsof -i :8080

# Watch a command every 2 seconds
watch -n 2 docker ps

# Tail multiple log files
tail -f log1.txt log2.txt

# Copy SSH public key to clipboard
cat ~/.ssh/id_rsa.pub | pbcopy

# Create a local HTTP server
python3 -m http.server 8080

# Find large files (>100MB)
find . -size +100M -type f

# Recursive text search with context
grep -rn "search_term" . --include="*.js"
```

## Zshrc / Config Editing
```
vim ~/.zshrc         edit zsh config
vim ~/.tmux.conf     edit tmux config
vim ~/.vimrc         edit vim config
vim ~/.ideavimrc     edit IdeaVim config
source ~/.zshrc      reload zsh config (or: exec zsh)
C-a r                reload tmux config (from inside tmux)
```
