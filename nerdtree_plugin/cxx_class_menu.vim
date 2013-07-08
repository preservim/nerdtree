" ============================================================================
" File:        cxx_class_menu.vim
" Description: NerdTree plugin to create header/class file pairs for C++
" Maintainer:  Frank Erens <frank@synthi.net>
" Last Change: 8 July, 2013
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" ============================================================================
if exists("g:loaded_nerdtree_cxx_class_menu")
    finish
endif
let g:loaded_nerdtree_cxx_class_menu = 1


call NERDTreeAddMenuItem({'text': 'create C++ header/class (p)air', 'shortcut': 'p', 'callback': 'NERDTreeAddCxxClass'})

"FUNCTION: s:echo(msg){{{1
function! s:echo(msg)
    redraw
    echomsg "NERDTree: " . a:msg
endfunction

"FUNCTION: s:echoWarning(msg){{{1
function! s:echoWarning(msg)
    echohl warningmsg
    call s:echo(a:msg)
    echohl normal
endfunction

"FUNCTION: NERDTreeAddNode(){{{1
function! NERDTreeAddCxxClass()
    let curDirNode = g:NERDTreeDirNode.GetSelected()

    let newNodeName = input("Create a C++ class\n".
                          \ "==========================================================\n".
                          \ "Create a new C++ .h/.cpp file pair with the given name\n" .
                          \ "", "", "file")

    if newNodeName ==# ''
        call s:echo("Node Creation Aborted.")
        return
    endif

    try
        let newPathPrefix = curDirNode.path.str() . g:NERDTreePath.Slash() . newNodeName
        let newPathH = g:NERDTreePath.Create(newPathPrefix . ".h")
        let newPathCpp = g:NERDTreePath.Create(newPathPrefix . ".cpp")
        let parentNode = b:NERDTreeRoot.findNode(newPathH.getParent())

        let newTreeNodeH = g:NERDTreeFileNode.New(newPathH)
        let newTreeNodeCpp = g:NERDTreeFileNode.New(newPathCpp)
        if parentNode.isOpen || !empty(parentNode.children)
            call parentNode.addChild(newTreeNodeH, 1)
            call parentNode.addChild(newTreeNodeCpp, 1)
            call NERDTreeRender()
            call newTreeNodeH.putCursorHere(1, 0)
        endif
    catch /^NERDTree/
        call s:echoWarning("Node Not Created.")
    endtry
endfunction

