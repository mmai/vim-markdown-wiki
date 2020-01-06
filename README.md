vim-markdown-wiki
================

*vim-markdown-wiki* is a Vim plugin which eases the navigation between files in a personnal wiki based on markdown 

Installation
-------------

 Add the line `Bundle 'mmai/vim-markdown-wiki'` in your .vimrc if you use *Vundle* or a similar plugin manager
 Or copy the after/ftplugin/markdown.vim file into the $HOME/.vim/after/ftplugin/ directory

Usage
-----

With the default key mappings :

**Link creation:**

 - Hit the ENTER key when the cursor is on a text between brackets : `[a title]`
 - The link will be created  `[a title](a-title.md)` and the corresponding file will be loaded in the buffer.

**Navigation:**

 - Hit the ENTER key when the cursor is on a wiki link
 - The corresponding link file is loaded in the current buffer.
 - Hit Leader key + ENTER to go back
 
 You can set a shortcut to open links in a new split, see below

Change key mappings in your vim config file
--------

Create or go to link :
`nnoremap  <CR> :MdwiGotoLink`

Open link in a new split with SPACE + ENTER :
`nnoremap <Space><CR> <C-w>v:MdwiGotoLink<CR>`

Return to previous page  :
`nnoremap  <Leader><CR> :MdwiReturn`

Customize new pages titles
--------

You can override the default format of the titles by defining a function _MdwiWriteTitle_ in your vim config file.

The default is :

```vim
function! MdwiWriteTitle(word)
  return 'normal!\ a'.escape(a:word, ' \').'\<esc>yypv$r=o\<cr>'
endfunction
```

which write the titles like this :

```
New page
========

```

Here is an example of a custom function which uses the `# ` style instead of underlining, and adds a timestamp before the title :

```vim
 function! MdwiWriteTitle(word)
   return 'normal!\ a# '.strftime('%c').' - '.escape(a:word, ' \').'\<esc>'
 endfunction
```

the result is something like this, depending on your locale : 

```
# Thu 10 Dec 2018 08:44:37 CET - New page

```


