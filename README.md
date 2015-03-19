"MarkdownWiki" is a Vim plugin which eases the navigation between files in a personnal wiki based on markdown 

 Installation
 ------------
 Copy the plugin/vim-markdown-wiki.vim file into the $HOME/.vim/plugin/ directory
 or add the line `Bundle 'mmai/vim-markdown-wiki'` in your .vimrc if you use *Vundle* or a similar plugin manager

 Usage
 -----

 **Link creation : **

 - Hit the ENTER key when the cursor is on a text between brackets : `[a title]`
 - The link will be created  `[a title](a-title.md)` and the corresponding file will be loaded in the buffer.

 **Navigation : **

 - Hit the ENTER key when the cursor is on a wiki link
 - The corresponding link file is loaded in the current buffer.
 - Hit Shift + ENTER to go back

