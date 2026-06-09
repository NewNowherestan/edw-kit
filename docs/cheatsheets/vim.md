# Vim — Quick Reference Card

## Modes
```
i        insert before cursor     I   insert at line start
a        insert after cursor      A   insert at line end
o        new line below           O   new line above
v        visual (char)            V   visual (line)
Ctrl-v   visual (block)           R   replace mode
Esc      back to normal           :   command mode
```

## Navigation
```
h j k l      ←↓↑→
w / b        next/prev word start
e / ge       next/prev word end
W / B        next/prev WORD (space-separated)
0            line start (col 0)
^            first non-blank char
$            line end
gg           file top
G            file bottom
:N           go to line N
H / M / L    screen top / middle / bottom
} / {        next/prev paragraph (blank line)
%            jump to matching bracket/paren/brace
f<c>         forward to char <c> on line
F<c>         backward to char <c> on line
t<c>         forward to before char <c>
T<c>         backward to before char <c>
;            repeat f/F/t/T forward
,            repeat f/F/t/T backward
''           jump back to last position
Ctrl-d       half page down
Ctrl-u       half page up
Ctrl-e       scroll down one line
Ctrl-y       scroll up one line
```

## Editing
```
x        delete char under cursor
r<c>     replace char with <c>
J        join line below to current
.        repeat last change
u        undo
Ctrl-r   redo
~        toggle case
```

## Operators (combine with motion or text object)
```
d        delete (cut)
y        yank (copy)
c        change (delete + insert)
>        indent
<        dedent
=        auto-indent
```
Examples: `dw` delete word, `d$` delete to end, `yy` yank line, `cc` change line, `gg=G` indent whole file

## Text Objects (use with d/y/c/v + i or a)
```
iw / aw    inner word / word + space
is / as    inner sentence / + space
ip / ap    inner paragraph / + blank lines
i( / a(    inner parens / including parens
i{ / a{    inner braces / including braces
i[ / a[    inner brackets / including brackets
i" / a"    inner quotes / including quotes
i' / a'    inner single quotes / including
it / at    inner tag / including tag (HTML/XML)
```
Examples: `diw` delete word, `ci(` change inside parens, `vit` select inside HTML tag, `yi"` yank inside quotes

## Copy / Paste
```
yy / Y    yank current line
dd        delete (cut) current line
D         delete to end of line
p         paste after cursor
P         paste before cursor
gv        reselect last visual selection
```

## Visual Mode
```
v + motion    select chars
V + motion    select lines
Ctrl-v        block select (column edit)
o             move to other end of selection
O             move to other corner (block)
d / x         delete selection
y             yank selection
c             change selection
> / <         indent / dedent
```

## Search & Replace
```
/pattern     search forward
?pattern     search backward
n / N        next / prev match
*            search word under cursor forward
#            search word under cursor backward
:%s/old/new/g       replace all in file
:%s/old/new/gc      replace all, confirm each
:s/old/new/g        replace in current line
```

## Splits & Tabs
```
:vsp [file]    vertical split
:sp [file]     horizontal split
Ctrl-w h/j/k/l navigate splits
Ctrl-w w       cycle splits
Ctrl-w q       close split
:tabe [file]   new tab
gt / gT        next / prev tab
```

## Buffers
```
F6        previous buffer          (custom)
F7        next buffer              (custom)
Ctrl-Tab  fuzzy buffer switch      (custom)
:ls       list open buffers
:bd       delete (close) buffer
:b <name> switch to buffer
```

## Custom Keys (your vimrc)
```
F2           save file (all modes)
F4           current error (:cc)
F5           next error (:cn)
F6           previous buffer
F7           next buffer
F11          toggle NERDTree
F12          Explore (netrw)
Ins          save and quit (:wq)

Ctrl-J       move line down (all modes)
Ctrl-K       move line up
Ctrl-H       dedent line/selection
Ctrl-L       indent line/selection
Ctrl-P       fuzzy file search (FufFile)
Ctrl-Tab     fuzzy buffer switch (FufBuffer)
```

## Plugins

### NERDCommenter  (leader = ,)
```
,cc    comment line/selection
,cu    uncomment
,ci    toggle comment
,cs    sexy block comment
,cm    minimal block comment
```

### vim-gitgutter
```
]c / [c    next / prev git hunk
,hp        preview hunk diff
,hs        stage hunk
,hu        undo hunk
```

### vim-multiple-cursors
```
Ctrl-N    select next occurrence (add cursor)
Ctrl-X    skip current, go to next
Ctrl-P    go back to prev
```

## Save / Quit
```
:w       save
:wq / :x  save and quit
:q       quit (fails if unsaved)
:q!      force quit without saving
:qa!     force quit all splits/tabs
ZZ       save and quit
ZQ       quit without saving
```

## Readonly mode (auto on read-only files)
```
Space    page down
F10      quit all
Esc      force quit all
```

## IdeaVim (IntelliJ IDEA)
```
# In ~/.ideavimrc:
source ~/.vim/vimrc

map \r <Action>(ReformatCode)
map \b <Action>(ToggleLineBreakpoint)
map gd <Action>(GotoDeclaration)
map gi <Action>(GotoImplementation)
map \e <Action>(ShowErrorDescription)
```
