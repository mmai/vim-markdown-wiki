" File: wikilink.vim
" Author: Henri Bourcereau 
" Version: 1.0
" Last Modified: March 19, 2015
"
" "vim-markdown-wiki" is a Vim plugin which eases the navigation between files 
" in a personnal wiki
" Links syntax currently supported follows Github Flavored Markdown ie [My displayed link](My-link.md)
"
" Installation
" ------------
" Copy the vim-markdown-wiki.vim file into the $HOME/.vim/plugin/ directory
"
" Configuration
" -------------
" Window split on footer and sidebar detection can be disabled by writing this
" line on your .vimrc file :
" let wikilinkAutosplit="off"
"
" Usage
" -----
" Link creation : 
" - Hit the ENTER key when the cursor is on a text between brackets : `[a title]`
" - The link will be created  `[a title](a-title.md)` and the corresponding file will be loaded in the buffer.

" Navigation : 
" - Hit the ENTER key when the cursor is on a wiki link
" - The corresponding link file is loaded in the current buffer.
" - Hit Shift + ENTER to go back

" Contribute
" ----------
" You can fork this project on Github :
" https://github.com/mmai/vim-markdown-wiki

"initVariable borrowed from NERDTree
function! s:initVariable(var, value)
    if !exists(a:var)
        exec 'let ' . a:var . ' = ' . "'" . a:value . "'"
        return 1
    endif
    return 0
endfunction

"Initialize variables
call s:initVariable("g:wikilinkAutosplit", "on")
call s:initVariable("g:wikilinkOnEnter", "on")

call s:initVariable("s:footer", "_Footer")
call s:initVariable("s:sidebar", "_Sidebar")
call s:initVariable("s:startWord", '[')
call s:initVariable("s:endWord", ']')
call s:initVariable("s:startLink", '(')
call s:initVariable("s:endLink", ')')

function! WikiLinkGetWord()
  let word = WikiLinkStrBetween(s:startWord, s:endWord)

  if !empty(word)
    " strip leading and trailing spaces
    let word = substitute(word, '^\s*\(.\{-}\)\s*$', '\1', '')
    "substitute spaces by dashes
    let word = substitute(word, '\s', '-', 'g')
  end

  return word
endfunction

function! WikiLinkStrBetween(startStr, endStr)
  let str = ''

  "Get string between <startStr> and <endStr>
  let origPos = getpos('.')
  let endPos = searchpos(a:endStr, 'W', line('.'))
  let startPos = searchpos(a:startStr, 'bW', line('.'))
  let ok = cursor(origPos[1], origPos[2]) "Return to the original position

  if (startPos[1] < origPos[2])
    let ll = getline(line('.'))
    let str = strpart(ll, startPos[1], endPos[1] - startPos[1] - 1)
  endif
  return str
endfunction

function! WikiLinkFindLinkPos()
  let origPos = getpos('.')
  let newPos = origPos
  let startPos = searchpos(s:startWord, 'bW', line('.'))
  let endPos = searchpos(s:endWord, 'W', line('.'))

  if (startPos[1] < origPos[2])
    let nextchar = matchstr(getline('.'), '\%' . (col('.')+1) . 'c.')
    if (nextchar == s:startLink)
      let newPos = [origPos[0], line('.'), col('.') + 2, origPos[3]]
    endif
  endif

  let ok = cursor(origPos[1], origPos[2]) "Return to the original position
  return newPos
endfunction


function! WikiLinkWordFilename(word)
  let file_name = ''
  "Same directory and same extension as the current file
  if !empty(a:word)
    let cur_file_name = bufname("%")
    let dir = fnamemodify(cur_file_name, ":h")
    if !empty(dir)
      if (dir == ".")
        let dir = ""
      else
        let dir = dir."/"
      endif
    endif
    let extension = fnamemodify(cur_file_name, ":e")
    let file_name = dir.a:word.".".extension
  endif
  return file_name
endfunction

function! WikiLinkGetLink()
  let link = ''

  "Is there already a link defined ?
  let linkPos = WikiLinkFindLinkPos()
  if (linkPos != getpos('.'))
    let ok = cursor(linkPos[1], linkPos[2])
    let link = WikiLinkStrBetween(s:startLink, s:endLink)
  else
    "No link defined : return a constructed link based on the text between
    "brackets
    let link = WikiLinkWordFilename(WikiLinkGetWord())
    if !empty(link)
      "Add link to the document
      let endPos = searchpos(s:endWord, 'W', line('.'))
      let ok = cursor(endPos[0], endPos[1])
      exec "normal a(".link.")"
      exec ":w"
    endif
  endif
  return link
endfunction

function! WikiLinkGotoLink()
  let link = WikiLinkGetLink()
  if !empty(link)
    "Search in subdirectories
    let mypath =  fnamemodify(bufname("%"), ":p:h")."/**"
    let existing_link = findfile(link, mypath)
    if !empty(existing_link)
      let link = existing_link
    endif
    exec "edit " . link 
  endif
endfunction

"search file in the current directory and its ancestors
function! WikiLinkFindFile(afile)
  "XXX does not work : return findfile(a:afile, '.;')
  let afile = fnamemodify(a:afile, ":p")
  if filereadable(afile)
    return afile
  else
    let filename = fnamemodify(afile, ":t")
    let file_parentdir = fnamemodify(afile, ":h:h")
    if file_parentdir == "//"
      "We've reached the root, no more parents
      return ""
    else
      return WikiLinkFindFile(file_parentdir . "/" . filename)
    endif
  endif
endfunction

function! WikiLinkDetectFile(word)
  return WikiLinkFindFile(WikiLinkWordFilename(a:word))
endfunction

command! WikiLinkGotoLink call WikiLinkGotoLink()
nnoremap <script> <Plug>WikiLinkGotoLink :WikiLinkGotoLink<CR>
if !hasmapto('<Plug>WikiLinkGotoLink')
  nmap <silent> <CR> <Plug>WikiLinkGotoLink
endif
"Shift+Return to return to the previous buffer 
nmap <S-CR> :b#<CR>

