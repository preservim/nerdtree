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
if exists("g:loaded_nerdtree_git_menu")
    finish
endif
let g:loaded_nerdtree_git_menu = 1

call NERDTreeAddMenuItem('(g)it menu', 'g', 'NERDTreeGitMenu')

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
        call s:promptCommand('git add ', path.strForOS(1), 'file')
    elseif choice ==# "c"
        call s:promptCommand('git checkout ', path.strForOS(1), 'file')
    elseif choice ==# "m"
        call s:promptCommand('git mv ', path.strForOS(1), 'file')
    elseif choice ==# "r"
        call s:promptCommand('git rm ', path.strForOS(1), 'file')
    endif

    call node.parent.refresh()
    call NERDTreeRender()
endfunction

function! s:promptCommand(cmd_base, cmd_tail_default, complete)
    let cmd_tail = input(":!" . a:cmd_base,  a:cmd_tail_default, a:complete)
    if cmd_tail != ''
        let output = system(a:cmd_base . cmd_tail)
        redraw!
        if v:shell_error != 0
            echom output
        endif
    endif
endfunction
