# Tools - Quick Reference Card

Use this card for tools installed by edw-kit that are not covered in `aliases.md`, `tmux.md`, `vim.md`, and `other.md`.

## Fast Navigation and Files
```bash
# starship (prompt)
starship explain            # explain prompt modules for current dir
starship preset nerd-font-symbols -o ~/.config/starship.toml

# zoxide (smart cd)
z foo                 # jump to frecent dir matching "foo"
zi                    # interactive jump with fzf
zoxide query foo      # print best match path

# eza (modern ls)
eza -la --git         # long view, hidden files, git status
eza -T -L 2           # tree view depth 2
eza -lah --sort=modified

# fd (fast find)
fd config             # find by name
fd -e md cheatsheet   # find by extension + pattern
fd -H -I "^\.env"      # include hidden + ignored

# tree
tree -L 2             # tree to depth 2
tree -a               # include hidden files
```

## Search and Preview
```bash
# ripgrep (rg)
rg "TODO"                    # recursive search
rg -n "pattern" src/         # with line numbers
rg -tjs "useEffect"          # only JS files
rg -g "*.md" "tmux" docs/    # include glob filter

# fzf
fzf                          # fuzzy-pick lines from stdin
history | fzf                # fuzzy search shell history
fd . | fzf                   # fuzzy-pick project file

# bat (better cat)
bat README.md                # syntax-highlighted view
bat -n file.txt              # show line numbers
bat --paging=never file.txt  # no pager
```

## Git Power Tools
```bash
# lazygit
lazygit                      # open interactive git TUI

# git-delta (pager)
git -c core.pager=delta show
git -c core.pager=delta log -p -1
git -c core.pager=delta diff
```

## HTTP, JSON, YAML
```bash
# curl / wget
curl -fsSL https://example.com/health
curl -I https://example.com
wget -c https://example.com/bigfile.iso

# httpie
http GET :3000/health
http POST :3000/api/users name=Stan role=admin
http -v GET https://api.github.com/repos/owner/repo

# jq (JSON)
cat data.json | jq '.'
cat data.json | jq '.items[] | {id, name}'
curl -s https://api.github.com/rate_limit | jq '.rate.remaining'

# yq (YAML/JSON)
yq '.services.web.image' docker-compose.yml
yq '.version = "2"' app.yml
yq -o=json app.yml | jq '.metadata'

# gawk / gnu-sed
awk -F, '{print $1, $3}' data.csv
gsed -n '1,40p' file.txt
gsed -E 's/(foo|bar)/baz/g' file.txt
```

## System and Disk
```bash
# btop / htop
btop                         # full system monitor
htop                         # lightweight process viewer

# dust / duf
dust                         # disk usage by folder
DU_COLORS=1 dust -d 2 .      # top 2 levels
duf                          # filesystem free/used overview
```

## Shell Productivity
```bash
# tldr / cheat
tldr tar                     # practical command examples
cheat git                    # quick community cheatsheet

# direnv (project envs)
echo 'export APP_ENV=dev' > .envrc
direnv allow                 # trust and auto-load
direnv status                # inspect active state

# entr (run on file change)
fd -e py | entr -r python3 app.py
find . -name "*.md" | entr -c make docs

# stow (dotfiles symlink manager)
stow -nv terminal            # dry-run link changes
stow -v terminal             # apply links
stow -D terminal             # unlink package
```

## Zsh Plugins You Have (quick use)
```bash
# thefuck plugin + tool
fuck                         # re-run previous command corrected

# extract plugin
extract archive.tar.gz
extract file.zip

# dirhistory plugin
cd --<TAB>                   # jump backward in dir history
cd -<TAB>                    # jump forward in dir history

# zsh-you-should-use
# Shows alias suggestion after full command, for example:
# "git status" -> suggests "gst"
```

## Media and Markdown Helpers
```bash
# glow (render markdown in terminal)
glow README.md
glow -p docs/notes_to_parse.md

# ffmpeg
ffmpeg -i in.mov -vf "fps=1" out-%03d.jpg        # extract frames
ffmpeg -i in.mov -c:v libx264 -crf 23 out.mp4     # compress video

# yt-dlp
yt-dlp "https://youtube.com/watch?v=..."
yt-dlp -x --audio-format mp3 "https://youtube.com/watch?v=..."
```

## Optional GUI Tools (tier2/tier3)
```bash
# Aerospace (tiling WM)
aerospace list-windows --all
aerospace list-workspaces --all

# Hammerspoon
open -a Hammerspoon

# mas (Mac App Store CLI)
mas list
mas search "Xcode"
mas upgrade
```

## Install/Update Reminders
```bash
./install.sh [PROFILE]       # full install/update
./setup-env.sh               # post-install setup (direnv, tmux, ghostty)
brew bundle --file=brew/Brewfile.terminal
brew bundle --file=brew/Brewfile.workstation
brew bundle --file=brew/Brewfile.full
brew upgrade && brew cleanup
```
