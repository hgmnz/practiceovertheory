---
layout: post
title: Small collection of useful vim tricks
date: 2009-08-18 16:44:42 -0400
comments: true
---

I've been using vim for the past couple of years. Vim is a cross-platform programmer's editor that is highly customizable and has a ton of well known and not-so well known features. As time goes by, I always come across new or better ways of doing things that increase productivity. What's most important is to force yourself to start using them so that they become part of your workflow, becoming muscle memory.

Here's a small collection of tips that I've picked up along the way:

### Moving around files

* I never bought into NERDTree or any of the other explorer plugins. I usually jump around using gf, using Rails.vim's <code>:R</code>, <code>:A</code>, etc, or you can open up vim's built in explorer using <code>:Ex</code>. <code>:Sex</code> opens it up in a split window.

* Use vim marks to jump around any number of files. Here's a quick [reference](http://www.linux.com/archive/feature/54159)

* <code>gf</code> will open the filename under the cursor. <code>Rails.vim</code> extends this by being smart about view partials. You can also use <code><C-W>gf</code> to open the file in a new tab.

* Use ctags. <code>C-]</code> on any method name or attribute to jump to the declaration point (or <code><C-W>-]</code> to open on a new window. Use <code><C-T></code> to come back. The tag stack is maintained. Then, <code>:ta</code> to jump to the tag. I use F5 to rebuild my ctags database:
<code>map <silent> <F5>:!ctags -R --exclude=.svn --exclude=.git --exclude=log *<CR></code>

* Learn how to use windows and tabs: it can really improve your work flow. I usually have multiple tabs open with different areas of the project. On each tab, I may have up to four windows open. I use tabs when it's a different context, for example, a CSS and a view file on one tab, and a controller, cucumber feature and step definitions on another tab, each on its own windows. When working with many windows, it's useful to quickly resize them: <code><C-W>_</code> maximizes the viewing area of the active window (for vertical windows, <code><C-W>|</code> does the same). You can come back to equally sized windows with <code><C-W>=</code>. The easiest way for me to move around tabs is using <code>gt</code> and <code>gT</code>. To move around windows, I typically use <code><C-W></code> along with one of h, j, k, l.

### More efficient editing

* Automate simple tasks with macros. <code>q{reg}<your-macro>q</code>. Then invoke it *n* times with <code>n@{reg}</code>. Learn about [recursive macros](http://vim.wikia.com/wiki/Record_a_recursive_macro) to run it until EOF.

* Use your registers. Yanking (and putting) and recording macros to different registers is most useful. Use <code>:reg</code> to view contents of your registers.

* Quickly change text surrounded by *something* using <code>ci</code>. For example, to change a string in double quotes use <code>ci"</code>, or to change parenthesized parameters, use <code>ci(</code>. 

* When working with large number of files, you can run the same command on all buffers/windows/tabs by using <code>:bufdo</code>/<code>:windo</code>/<code>:tabdo</code>. Such a time saver.

* Learn how to use vim's substitute command with regular expressions and the grouping operators \\( and \\). You can morph a file at will using the matched part of the pattern and \1, \2. Throw <code>i</code> at the end of the command for interactive substitution. Here's a [good vim regex guide](http://www.geocities.com/volontir/) 

* Vim's built in autocompletion rocks. Use <code><C-n></code> or <code><C-p></code> in insert mode to activate and move through the options. 

* When moving within a file, <code>f<char></code> moves the cursor forward until the first <code><char></code>. <code>;</code> repeats the action. You can move to the second occurrence of <code><char></code> by using <code>2f<char></code>. <code>F<char></code> does the same, but backwards.

* Learn the different ways to enter insert mode. The ones I use the most, other than <code>i</code> are
  * <code>a</code> to enter insert mode at the next character (as opposed to i, which enters insert mode before the current character).
  * <code>A</code> to enter insert mode at the end of the line.
  * <code>I</code> to enter insert mode at the beginning of the line.
  * <code>O</code> to create a new line above the current line and enter insert mode.
  * <code>o</code> to create a new line below the current line and enter insert mode.

* Block selection is magical. Use it when you want to select a vertical block or column to yank it, delete it, etc. To enter visual block select, do <code><C-q></code>. You can also insert arbitrary text before the block with <code><C-I><type your chars>Esc</code>. For example, this is very useful for inserting the same text on a set of aligned <code><li>s</code>(like adding a class="foo" attribute) or after hash rockets or equal signs on your ruby code - yet another reason to align these properly.

* <code>C-e</code> and <code>C-y</code>, scrolls the buffer without moving the cursor. Make it scroll three lines at a time with:
<code> nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y></code>

* Use <code>%</code> to jump to the matching open or closing bracket/parenthesis. Use the [matchit plugin](http://www.vim.org/scripts/script.php?script_id=39) to have it match more than single characters, for example <code>def</code> matches <code>end</code> in Ruby code, or <code><ul></code> matches <code></ul></code> in HTML.

### Other miscellanea

* For bash style command tab completion, put <code>set wildmode=list:longest</code> on your vimrc. Then tab away when running commands on ex mode.

* View unprintable characters with <code>:set list</code>. Cancel out with <code>:set nolist</code>

* Analyzing log files with vim is also a win. For example, you may be in a rails app and used <code>Rails.vim</code>'s <code>:Rlog</code> command. Now you can use the global command to surface up the specific pattern you're looking for using <code>:g/{pattern}/p</code>, or you may remove any useless lines with <code>:g/{useless}/d</code>.

* When pasting something, vim will autoindent which is usually not what you want. Use <code>:set paste</code> before the paste to avoid that.

* Use <code>gg=G</code> to apply proper indentation to a messy source file. I define 2 space "tabs" for all file types by using <code>set tabstop=2 shiftwidth=2 expandtab</code>.

* Saving and reopening a vim session is easy using <code>:mksession!</code> and <code>:source</code>. I have the following two maps in my vimrc to make this even easier with F2 and F3:
<code>map <F2> :mksession! ~/vim_session <cr> " Quick write session with F2
map <F3> :source ~/vim_session <cr>     " And load session with F3</code>

* <code>Ctrl-L</code> to redraw the screen (to fix broken syntax highlighting). The following mapping will also remove highlighting after a search: <code>nnoremap <C-L> :nohls<CR><C-L></code>.

* About those darn backup files infecting your project: Keep them, but on a different location - you may come to a crash, and you'll need them. I created a directory called ~/.vim_backups, and vim puts them there. The relevant lines are:
<code> silent execute '!mkdir -p ~/.vim_backups'
set backupdir=~/.vim_backups//
set directory=~/.vim_backups//</code>

* I usually write blog posts in Vim using markdown. I use vim's integrated spell checking by setting <code>:set spellang=en_us</code> on my vimrc. To invoke it, use <code>:set spell</code> which will underline misspelled words, and <code>z=</code> brings up suggestions for the misspelled words under the cursor.

* Word wrapping is sluggish by default. I added [these lines](http://github.com/hgimenez/vimfiles/blob/c07ac584cbc477a0619c435df26a590a88c3e5a2/vimrc#L72-122) to my .vimrc which do a few of things: <code><leader>w</code> toggles between wrap and no wrap. It adds a <code>></code> character to new lines, making it obvious that you're on a wrapping line. It tries to wrap on word boundaries, and finally, it remaps k and j so that you're moving up/down on visual lines, not actual lines.

* Use <code>set showmatch</code> and <code>set mat=5</code> on your .vimrc to blink matching parenthesis or brackets. Unobstrusive and useful.

I am sure I'm missing many, but this is what I use most often. Got any tips worth sharing or even better, improvements to the above?

#### Resources
The following are books, tutorials or articles that I've found useful in learning and improving my vim workflow.

* [Vim cookbook](http://vim.runpaint.org/toc/)
* [The vi/ex editor](http://www.networkcomputing.com/unixworld/tutorial/009/009.html) 
* [Vi for smarties](http://jerrywang.net/vi/) 
* [Efficient editing with vim](http://jmcpherson.org/editing.html)
* [Why, oh WHY, do those #?@! nutheads use vi?](http://www.viemu.com/a-why-vi-vim.html)
* [A byte of vim](http://www.swaroopch.com/notes/Vim)
