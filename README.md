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

Change key mappings in your vim config file
--------

Create or go to link :
`nnoremap  <CR> :MdwiGotoLink`

Return to previous page  :
`nnoremap  <Leader><CR> :MdwiReturn`
