" Maintainer:	Greg Sexton (gregsexton@gmail.com)
" Version:      1.0
" Last Change:	2011-02-19

set background=dark

hi clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "mustangpp_op"

" Vim >= 7.0 specific colors
if version >= 700
  hi CursorLine   guibg=#444444 ctermbg=236
  hi CursorColumn guibg=#444444 ctermbg=236
  hi MatchParen   guifg=#ee0000 guibg=#202020 gui=bold  ctermfg=157 ctermbg=237 cterm=bold
  hi Pmenu        guifg=#ffffff guibg=#444444 ctermfg=255 ctermbg=238
  hi PmenuSel     guifg=#000000 guibg=#b1d631 ctermfg=0   ctermbg=148
endif

" General colors
"hi Cursor       guifg=NONE    guibg=#626262 gui=none ctermbg=241
hi Cursor       guifg=#000000 guibg=#ffffff gui=none ctermbg=241
hi Normal       guifg=#e2e2e5 guibg=#202020 gui=none ctermfg=253 ctermbg=none
hi NonText      guifg=#202020 guibg=#202020 gui=none ctermfg=244 ctermbg=none
hi LineNr       guifg=#454545 guibg=#252525 gui=none ctermfg=244 ctermbg=232
hi StatusLine   guifg=#d3d3d5 guibg=#444444 gui=none ctermfg=253 ctermbg=238
hi StatusLineNC guifg=#939395 guibg=#444444 gui=none ctermfg=246 ctermbg=238
hi VertSplit    guifg=#444444 guibg=#444444 gui=none ctermfg=238 ctermbg=238
hi Folded       guibg=#384048 guifg=#a0a8b0 gui=none ctermbg=4   ctermfg=248
hi Title        guifg=#f6f3e8 guibg=NONE    gui=bold ctermfg=254 cterm=bold
hi Visual       guifg=#faf4c6 guibg=#3c414c gui=none ctermfg=black ctermbg=148 cterm=bold
hi SpecialKey   guifg=#808080 guibg=#343434 gui=none ctermfg=darkgrey ctermbg=none
hi Directory    guifg=#f92672 gui=none      ctermfg=148

" Syntax highlighting
hi Argument   guifg=#EBD800 ctermfg=yellow
hi Comment    guifg=#808080 gui=none      ctermfg=244
"hi Todo       guifg=#8f8f8f gui=none      ctermfg=245
hi Identifier guifg=#89D64D gui=bold      ctermfg=148
hi Function   guifg=#5F80D3 gui=none      ctermfg=12
hi Statement  guifg=#66ab16 gui=none      ctermfg=12
hi Type       guifg=#7e8aa2 gui=none      ctermfg=66
hi Keyword    guifg=#76c1da gui=none      ctermfg=208
hi Constant   guifg=#ff9800 gui=none      ctermfg=208
hi Special    guifg=#729fcf gui=none      ctermfg=208
hi link String Argument
hi link Boolean Argument
hi link Number Argument
hi PreProc    guifg=#faf4c6 gui=none      ctermfg=230
"hi Todo       guifg=#000000 guibg=#e6ea50 gui=none
hi Todo	      guibg=orangered guifg=white

" Code-specific colors
hi pythonOperator guifg=#7e8aa2 gui=none ctermfg=103
hi link javaScriptString Argument
hi link javaScriptBoolean Argument
hi link javaScriptNumber Argument

" My personal (dark background) diff colours.
hi DiffDelete guifg=#303030 guibg=#505050
hi DiffAdd    guibg=#002851
hi DiffChange guibg=#450303
hi DiffText   guibg=#990909 gui=none
