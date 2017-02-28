" File: mkd_wiki.vim
" Author: Henri Bourcereau 
" Version: 1.4
" Last Modified: April 28, 2017
"
" "vim-markdown-wiki" is a Vim plugin which eases the navigation between files 
" in a personnal wiki
" Links syntax currently supported follows Github Flavored Markdown ie [My displayed link](My-link.md)
"
" Installation
" ------------
" Copy the markdown.vim file into the $HOME/.vim/after/ftplugin/ directory
"
" Change key mappings in your vim config file
" --------
" 
" Create or go to link :
" nnoremap  <CR> :MdwiGotoLink 
"
" Return to previous page :
" nnoremap  <Leader><CR> :MdwiReturn
"
" Usage 
" -----
" Link creation : 
" - Hit the ENTER key when the cursor is on a text between brackets : `[a title]`
" - The link will be created  `[a title](a-title.md)` and the corresponding file will be loaded in the buffer.

" Navigation : 
" - Hit the ENTER key when the cursor is on a wiki link
" - The corresponding link file is loaded in the current buffer.
" - Hit leader key + ENTER to go back


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
call s:initVariable("s:footer", "_Footer")
call s:initVariable("s:sidebar", "_Sidebar")
call s:initVariable("s:startWord", '[')
call s:initVariable("s:endWord", ']')
call s:initVariable("s:startLink", '(')
call s:initVariable("s:endLink", ')')
call s:initVariable("s:lastPosLine", 0)
call s:initVariable("s:lastPosCol", 0)

" *********************************************************************
" *                      Utilities 
" *********************************************************************

function! MdwiStrBetween(startStr, endStr)
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


function! MdwiWordFilename(word)
  let file_name = ''
  "Same directory and same extension as the current file
  if !empty(a:word)
    " strip leading and trailing spaces
    let word = substitute(a:word, '^\s*\(.\{-}\)\s*$', '\1', '')
    "substitute spaces by dashes
    let word = substitute(word, '\s', '-', 'g')

    let cur_file_name = bufname("%")
    let extension = fnamemodify(cur_file_name, ":e")
    let file_name = word.".".extension
  endif
  return file_name
endfunction

function! MdwiFilePath(relativepath)
  let cur_file_name = bufname("%")
  let dir = fnamemodify(cur_file_name, ":h")
  if !empty(dir)
    if (dir == ".")
      let dir = ""
    else
      let dir = dir."/"
    endif
  endif
  let file_path = dir.a:relativepath
  return file_path
endfunction

" *********************************************************************
" *                      Words 
" *********************************************************************

function! MdwiFindWordPos()
  let origPos = getpos('.')
  let newPos = origPos
  let endPos = searchpos(s:endWord, 'W', line('.'))
  let startPos = searchpos(s:startWord, 'bW', line('.'))

  if (startPos[0] != 0 )
    let newcolpos = col('.') + 1
    if (newcolpos == origPos[2])
      let newcolpos = newcolpos + 1
    endif
    let newPos = [origPos[0], line('.'), newcolpos, origPos[3]]
  endif

  let ok = cursor(origPos[1], origPos[2]) "Return to the original position
  return newPos
endfunction

function! MdwiGetWord()
  let word = ''
  let wordPos = MdwiFindWordPos()
  if (wordPos != getpos('.'))
    let ok = cursor(wordPos[1], wordPos[2])
    let word = MdwiStrBetween(s:startWord, s:endWord)
  endif
  return word
endfunction

" *********************************************************************
" *                      Links 
" *********************************************************************
function! MdwiFindLinkPos()
  let origPos = getpos('.')
  let newPos = origPos
  let startPos = searchpos(s:startWord, 'bW', line('.'))
  let endPos = searchpos(s:endWord, 'W', line('.'))

  if (startPos[0] != 0)
    let nextchar = matchstr(getline('.'), '\%' . (col('.')+1) . 'c.')
    if (nextchar == s:startLink)
      let newcolpos = col('.') + 2
      if (newcolpos == origPos[2])
        let newcolpos = newcolpos + 1
      endif
      let newPos = [origPos[0], line('.'), newcolpos, origPos[3]]
    endif
  endif

  let ok = cursor(origPos[1], origPos[2]) "Return to the original position
  return newPos
endfunction

function! MdwiGetLink()
  let link = ''
  "Is there a link defined ?
  let linkPos = MdwiFindLinkPos()
  if (linkPos != getpos('.'))
    let ok = cursor(linkPos[1], linkPos[2])
    let link = MdwiStrBetween(s:startLink, s:endLink)
  endif
  return link
endfunction

" ******** Go to link *****************
if !exists('*MdwiGotoLink')
function! MdwiGotoLink()
  let s:lastPosLine = line('.')
  let s:lastPosCol = col('.')

  let word = MdwiGetWord()
  let strCmd = ""
  if !empty(word)
    let relativepath = MdwiGetLink()
    if (empty(relativepath))
      let relativepath = MdwiWordFilename(word)
      "Add link to the document
      let endPos = searchpos(s:endWord, 'W', line('.'))
      let ok = cursor(endPos[0], endPos[1])
      exec "normal! a(".relativepath.")"
      exec ":w"
      "Write title to the new document
      let strCmd = 'normal!\ a'.escape(word, ' \').'\<esc>yypv$r=o\<cr>'
    endif

    let link = MdwiFilePath(relativepath)
    exec 'edit +execute\ "' . escape(strCmd, ' "\') . '" ' . link 
  endif
endfunction
endif

command! -buffer MdwiGotoLink call MdwiGotoLink()
nnoremap <buffer> <script> <Plug>MdwiGotoLink :MdwiGotoLink<CR>
if !hasmapto('<Plug>MdwiGotoLink')
  nmap <buffer> <silent> <CR> <Plug>MdwiGotoLink
endif

"Shift+Return to return to the previous buffer 
if !exists('*MdwiReturn')
function! MdwiReturn()
  exec 'buffer #'
  let ok = cursor(s:lastPosLine, s:lastPosCol)
endfunction
endif

command! -buffer MdwiReturn call MdwiReturn()
nnoremap <buffer> <script> <Plug>MdwiReturn :MdwiReturn<CR>
if !hasmapto('<Plug>MdwiReturn')
  nmap <buffer> <silent> <Leader><CR> <Plug>MdwiReturn
endif

