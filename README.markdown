# The NERDTree [![Vint](https://github.com/preservim/nerdtree/workflows/Vint/badge.svg)](https://github.com/preservim/nerdtree/actions?workflow=Vint)

## Introduction

The NERDTree is a file system explorer for the Vim editor. Using this plugin, users can visually browse complex directory hierarchies, quickly open files for reading or editing, and perform basic file system operations.

![NERDTree Screenshot](https://github.com/preservim/nerdtree/raw/master/screenshot.png)

## Installation

Use your favorite plugin manager to install this plugin. [vim-pathogen](https://github.com/tpope/vim-pathogen), [Vundle.vim](https://github.com/VundleVim/Vundle.vim), [vim-plug](https://github.com/junegunn/vim-plug), [neobundle.vim](https://github.com/Shougo/neobundle.vim), and [dein.vim](https://github.com/Shougo/dein.vim) are some of the more popular ones. A lengthy discussion of these and other managers can be found on [vi.stackexchange.com](https://vi.stackexchange.com/questions/388/what-is-the-difference-between-the-vim-plugin-managers). You must read, understand, and follow all the safety instructions that come with your plugin manager.

If you have no favorite, or want to manage your plugins without 3rd-party dependencies, consider using Vim 8+ packages, as described in Greg Hurrell's excellent Youtube video: [Vim screencast #75: Plugin managers](https://www.youtube.com/watch?v=X2_R3uxDN6g).

<details>
<summary>Vim 8+ packages</summary>

If you are using Vim version 8 or higher you can use its built-in package management; see `:help packages` for more information. Just run these commands in your terminal:

```bash
git clone https://github.com/preservim/nerdtree.git ~/.vim/pack/vendor/start/nerdtree
vim -u NONE -c "helptags ~/.vim/pack/vendor/start/nerdtree/doc" -c q
```
</details>

<details>
<summary>Pathogen</summary>

In the terminal,
```bash
git clone https://github.com/preservim/nerdtree.git ~/.vim/bundle/nerdtree
```
In your vimrc,
```vim
call pathogen#infect()
syntax on
filetype plugin indent on
```

Then reload Vim, run `:helptags ~/.vim/bundle/nerdtree/doc/` or `:Helptags`.
</details>

<details>
  <summary>Vundle</summary>

```vim
call vundle#begin()
  Plugin 'preservim/nerdtree'
call vundle#end()
```
</details>

<details>
  <summary>Vim-Plug</summary>

```vim
call plug#begin()
  Plug 'preservim/nerdtree'
call plug#end()
```
</details>

<details>
  <summary>Dein</summary>

```vim
call dein#begin()
  call dein#add('preservim/nerdtree')
call dein#end()
  ```
</details>

## Getting Started
After installing NERDTree, the best way to learn it is to turn on the Quick Help. Open NERDTree with the `:NERDTree` command, and press `?` to turn on the Quick Help, which will show you all the mappings and commands available in the NERDTree. Of course, your most complete source of information is the documentation: `:help NERDTree`.

## NERDTree Plugins
NERDTree can be extended with custom mappings and functions using its built-in API. The details of this API and are described in the included documentation. Several plugins have been written, and are available on Github for installation like any other plugin. The plugins in this list are maintained (or not) by their respective owners, and certain combinations may be incompatible.

* [Xuyuanp/nerdtree-git-plugin](https://github.com/Xuyuanp/nerdtree-git-plugin): Shows Git status flags for files and folders in NERDTree.
* [ryanoasis/vim-devicons](https://github.com/ryanoasis/vim-devicons): Adds filetype-specific icons to NERDTree files and folders,
* [tiagofumo/vim-nerdtree-syntax-highlight](https://github.com/tiagofumo/vim-nerdtree-syntax-highlight): Adds syntax highlighting to NERDTree based on filetype.
* [scrooloose/nerdtree-project-plugin](https://github.com/scrooloose/nerdtree-project-plugin): Saves and restores the state of the NERDTree between sessions.
* [PhilRunninger/nerdtree-buffer-ops](https://github.com/PhilRunninger/nerdtree-buffer-ops): 1) Highlights open files in a different color. 2) Closes a buffer directly from NERDTree.
* [PhilRunninger/nerdtree-visual-selection](https://github.com/PhilRunninger/nerdtree-visual-selection): Enables NERDTree to open, delete, move, or copy multiple Visually-selected files at once.
* [jistr/vim-nerdtree-tabs](https://github.com/jistr/vim-nerdtree-tabs): Maintains a single NERDTree window on all tabs.

If any others should be listed, mention them in an issue or pull request.


## Frequently Asked Questions

### How do I open NERDTree automatically when Vim starts up?
Add one of these code blocks to your vimrc.
```vim
" Start NERDTree and leave the cursor in it.
autocmd VimEnter * NERDTree
```
---
```vim
" Start NERDTree and put the cursor back in the other window.
autocmd VimEnter * NERDTree | wincmd p
```
---
```vim
" Start NERDTree only if Vim is started without arguments.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
```
---
```vim
" Start NERDTree if Vim is started without arguments, and put the cursor back in the empty buffer.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | else | NERDTree | wincmd p | endif
```
---
```vim
" Start NERDTree on startup, unless opening a session, eg. vim -S session_file.vim.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") && v:this_session == "" | NERDTree | endif
```
---
```vim
" Start NERDTree when Vim starts up with a directory argument.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") |
    \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif
```

### How can I close Vim automatically when NERDTree is the last window?

```vim
" Exit Vim if NERDTree is the only window left.
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
```

### How can I map a specific key or shortcut to open NERDTree?

You, of course, have many keys and NERDTree commands to choose from. Here are but a few examples.
```vim
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
```

### How can I change default arrows?

Use these variables in your vimrc. Note that below are default arrow symbols.
```vim
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
```
You can remove the arrows altogether by setting these variables to empty strings, as shown below. This will remove not only the arrows, but a single space following them, shifting the whole tree two character positions to the left.
```vim
let g:NERDTreeDirArrowExpandable = ''
let g:NERDTreeDirArrowCollapsible = ''
```
See `:h NERDTreeDirArrowExpandable` for more details.

### Can I have the nerdtree on every tab automatically?

Nope. If this is something you want then chances are you aren't using tabs and
buffers as they were intended to be used. Read this
http://stackoverflow.com/questions/102384/using-vims-tabs-like-buffers

If you are interested in this behaviour then consider [vim-nerdtree-tabs](https://github.com/jistr/vim-nerdtree-tabs)
