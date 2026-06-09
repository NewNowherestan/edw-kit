# Aliases — Quick Reference Card

## Git (Oh My Zsh `git` plugin)

### Status & Info
```
g         git
gst       git status
gsb       git status -sb          (short)
glog      git log --oneline --decorate --graph
gd        git diff
gds       git diff --staged
gb        git branch
gba       git branch -a           (all branches)
```

### Stage & Commit
```
ga        git add
gaa       git add --all
gc        git commit --verbose
gcm       git commit -m "<msg>"
gca       git commit -v -a        (add all + commit)
```

### Branch & Checkout
```
gco       git checkout
gcb       git checkout -b <branch>
gbd       git branch -d <branch>
gm        git merge
grb       git rebase
grbi      git rebase -i           (interactive)
```

### Remote
```
gl        git pull
gp        git push
gpf       git push --force-with-lease
gcl       git clone --recurse-submodules
```

### Restore & Stash
```
grs       git restore
grss      git restore --staged
gsta      git stash push
gstp      git stash pop
gstl      git stash list
```

---

## ADB (from ~/.zshrc)
```
adbscreen        screenshot → macOS clipboard (⌘V to paste)
adbscreen_save   screenshot → ~/Downloads/screen_YYYY-MM-DD_HH-MM-SS.png
```

### ADB Video
```
adb shell screenrecord /sdcard/Movies/rec.mp4   (Ctrl-C to stop, max 3 min)
adb pull /sdcard/Movies/rec.mp4 ~/Downloads/
adb exec-out screenrecord --output-format=h264 - | ffplay -   (live stream)
```

---

## macOS Plugin
```
ofd              open current dir in Finder
cdf              cd to frontmost Finder window location
pfd              print frontmost Finder window path
pfs              print current Finder selection
pushdf           pushd to frontmost Finder dir
tab              new iTerm2 tab in current dir
split_tab        split tab horizontally
vsplit_tab       split tab vertically
quick-look <f>   Quick Look file from terminal
man-preview <cmd>  open man page in Preview.app as PDF
showfiles        show hidden files in Finder
hidefiles        hide hidden files in Finder
rmdsstore        delete all .DS_Store files recursively
btrestart        restart Bluetooth daemon
music play/pause/next/prev   control Apple Music
spotify play/search <q>      control Spotify
```

---

## iTerm2 Shell Integration
```
imgcat <file>    show image inline in terminal
imgls            ls with image thumbnails
it2dl <url>      download to Mac (works over SSH)
it2ul <file>     upload from Mac to remote
it2copy          copy to clipboard over SSH
it2setcolor      change terminal color from script
it2profile       switch iTerm2 profile
it2attention     flash dock icon
it2tip           random iTerm2 productivity tip
```

---

## copypath / copyfile (Oh My Zsh)
```
copypath              copy current directory path to clipboard
copypath <path>       copy given path to clipboard
copyfile <file>       copy file contents to clipboard
```

---

## Zsh Builtins & Oh My Zsh Extras
```
!!                    repeat last command (e.g. sudo !!)
!$                    last argument of previous command
!<n>                  run command N from history
take <dir>            mkdir -p + cd in one command
als <keyword>         search active aliases by keyword
alias                 list all active aliases
```
