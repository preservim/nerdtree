" ============================================================================
" File:        nerdtree_git_menu.vim
" Description: plugin for the NERD Tree that provides a git menu
" Maintainer:  Martin Grenfell <martin_grenfell at msn dot com>
" Last Change: 20 July, 2009
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" ============================================================================
"
" Adds a "g" submenu to the NERD tree menu.
"
" Note: this plugin assumes that the current tree root has a .git dir under
" it, and that the working tree and the .git repo are in the same place
"
if exists("g:loaded_nerdtree_git_menu")
    finish
endif
let g:loaded_nerdtree_git_menu = 1

call NERDTreeAddMenuItem({
            \ 'text': '(g)it menu',
            \ 'shortcut': 'g',
            \ 'check_to_enable_callback': 'NERDTreeGitMenuEnabled',
            \ 'callback': 'NERDTreeGitMenu' })

function! NERDTreeGitMenuEnabled()
    return isdirectory(s:GitRepoPath())
endfunction

function! s:GitRepoPath()
    return b:NERDTreeRoot.path.str(0) . ".git"
endfunction

function! NERDTreeGitMenu()
    let node = g:NERDTreeFileNode.GetSelected()

    let path = node.path
    let parent = path.getParent()

    let prompt = "NERDTree Git Menu\n" .
       \ "==========================================================\n".
       \ "Select the desired operation:                             \n" .
       \ " (a) - git add\n".
       \ " (c) - git checkout\n".
       \ " (m) - git mv\n".
       \ " (r) - git rm\n"

    echo prompt

    let choice = nr2char(getchar())

    if choice ==# "a"
        call s:promptCommand('add ', path.strForOS(1), 'file')
    elseif choice ==# "c"
        call s:promptCommand('checkout ', path.strForOS(1), 'file')
    elseif choice ==# "m"
        let p = path.strForOS(1)
        call s:promptCommand('mv ', p . ' ' . p, 'file')
    elseif choice ==# "r"
        call s:promptCommand('rm ', path.strForOS(1), 'file')
    endif

    call node.parent.refresh()
    call NERDTreeRender()
endfunction

function! s:promptCommand(sub_command, cmd_tail_default, complete)
    let extra_options  = ' --git-dir=' . s:GitRepoPath()
    let extra_options .= ' --work-tree=' . b:NERDTreeRoot.path.str(0) . ' '
    let base = "git" . extra_options . a:sub_command

    let cmd_tail = input(":!" . base,  a:cmd_tail_default, a:complete)
    if cmd_tail != ''
        let output = system(base . cmd_tail)
        redraw!
        if v:shell_error != 0
            echo output
        endif
    else
        redraw
        echo "Aborted"
    endif
endfunction
