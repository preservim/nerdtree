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

call NERDTreeAddMenuSeparator({'isActiveCallback': 'NERDTreeGitMenuEnabled'})
let s:menu = NERDTreeAddMenuItem({
            \ 'text': '(g)it menu',
            \ 'shortcut': 'g',
            \ 'isActiveCallback': 'NERDTreeGitMenuEnabled',
            \ 'callback': 'NERDTreeGitMenu' })

call NERDTreeAddMenuItem({
            \ 'text': 'git (a)dd',
            \ 'shortcut': 'a',
            \ 'isActiveCallback': 'NERDTreeGitMenuEnabled',
            \ 'callback': 'NERDTreeGitAdd',
            \ 'parent': s:menu })

call NERDTreeAddMenuItem({
            \ 'text': 'git (c)heckout',
            \ 'shortcut': 'c',
            \ 'isActiveCallback': 'NERDTreeGitMenuEnabled',
            \ 'callback': 'NERDTreeGitCheckout',
            \ 'parent': s:menu })

call NERDTreeAddMenuItem({
            \ 'text': 'git (m)v',
            \ 'shortcut': 'm',
            \ 'isActiveCallback': 'NERDTreeGitMenuEnabled',
            \ 'callback': 'NERDTreeGitMove',
            \ 'parent': s:menu })

call NERDTreeAddMenuItem({
            \ 'text': 'git (r)m',
            \ 'shortcut': 'r',
            \ 'isActiveCallback': 'NERDTreeGitMenuEnabled',
            \ 'callback': 'NERDTreeGitRemove',
            \ 'parent': s:menu })

function! NERDTreeGitMenuEnabled()
    return isdirectory(s:GitRepoPath())
endfunction

function! s:GitRepoPath()
    return b:NERDTreeRoot.path.str(0) . ".git"
endfunction

function! NERDTreeGitMove()
    let node = g:NERDTreeFileNode.GetSelected()
    let path = node.path
    let p = path.strForOS(1)
    call s:promptCommand('mv ', p . ' ' . p, 'file')
endfunction

function! NERDTreeGitAdd()
    let node = g:NERDTreeFileNode.GetSelected()
    let path = node.path
    call s:promptCommand('add ', path.strForOS(1), 'file')
endfunction

function! NERDTreeGitRemove()
    let node = g:NERDTreeFileNode.GetSelected()
    let path = node.path
    call s:promptCommand('rm ', path.strForOS(1), 'file')
endfunction

function! NERDTreeGitCheckout()
    let node = g:NERDTreeFileNode.GetSelected()
    let path = node.path
    call s:promptCommand('checkout ', path.strForOS(1), 'file')
endfunction

function! s:promptCommand(sub_command, cmd_tail_default, complete)
    let extra_options  = ' --git-dir=' . s:GitRepoPath()
    let extra_options .= ' --work-tree=' . b:NERDTreeRoot.path.str(0) . ' '
    let base = "git" . extra_options . a:sub_command

    let node = g:NERDTreeFileNode.GetSelected()

    let cmd_tail = input(":!" . base,  a:cmd_tail_default, a:complete)
    if cmd_tail != ''
        let output = system(base . cmd_tail)
        redraw!
        if v:shell_error == 0
            call node.parent.refresh()
            call NERDTreeRender()
        else
            echo output
        endif
    else
        redraw
        echo "Aborted"
    endif
endfunction
