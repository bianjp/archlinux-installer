set hlsearch
set backspace=2
set autoindent
set ruler           "show file info"
set showmode        "show current mode name"
set nu              "show line number"
set ignorecase      "ignore case when search"
set bg=dark
syntax on           "syntax check"

set ts=2            "tab stop"
set expandtab       "expand tab to spaces"

"Enter paste mode automatically when pasting"
let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction
