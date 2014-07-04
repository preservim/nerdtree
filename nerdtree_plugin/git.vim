" ============================================================================
" File:        git.vim
" Description: Expt. plugin to add git flags to the UI
" Maintainer:
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" ============================================================================
if exists("g:loaded_nerdtree_git")
    finish
endif
let g:loaded_nerdtree_git = 1

call g:NERDTreeRefreshNotifier.AddListener("g:NERDTreeGitRefreshListener")

function! g:NERDTreeGitRefreshListener(path)
    if !isdirectory(b:NERDTreeRoot.path.str() . '/.git')
        return
    end

    let modifiedFiles = s:GetModifiedFiles()
    if index(modifiedFiles, a:path.str()) >= 0
        call a:path.addFlag("+")
    else
        call a:path.removeFlag("+")
    endif
endfunction

"Cache the list of modified files for a few seconds - otherwise we must shell
"out to get it for every path that is refreshed which takes ages
function! s:GetModifiedFiles()
    if !exists('s:modifiedFiles') || (localtime() - s:modifiedFilesTime > 2)
        let s:modifiedFiles = split(system('git -C ' . b:NERDTreeRoot.path.str() . ' ls-files -m'))
        let s:modifiedFilesTime = localtime()
        call map(s:modifiedFiles, 'b:NERDTreeRoot.path.str() . "/" . v:val')
    endif

    return s:modifiedFiles
endfunction

autocmd filetype nerdtree call s:AddHighlighting()
function! s:AddHighlighting()
    syn match NERDTreeGitflag #^ *\zs\[+\]# containedin=NERDTreeFile
    hi link NERDTreeGitFlag error
endfunction

"when a buffer is saved, refresh it in nerdtree
autocmd bufwritepost * call s:FileUpdated(expand("%"))
function! s:FileUpdated(fname)
    if !nerdtree#isTreeOpen()
        return
    endif

    call nerdtree#putCursorInTreeWin()
    let node = b:NERDTreeRoot.findNode(g:NERDTreePath.New(a:fname))
    if !empty(node)
        call node.refresh()
    endif

    call NERDTreeRender()
endfunction

