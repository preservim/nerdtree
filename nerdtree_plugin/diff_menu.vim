" ============================================================================
" File:        vimdiff_menu.vim
"
" ============================================================================
if exists("g:loaded_nerdtree_vimdiff_menu")
    finish
endif
let g:loaded_nerdtree_vimdiff_menu = 1

call NERDTreeAddMenuItem({'text': '(v)imdiff with current node', 'shortcut': 'v', 'callback': 'NERDTreeDiffNode'})

" FUNCTION: NERDTreeDiffNode()
function! NERDTreeDiffNode()
    let currentNode = g:NERDTreeFileNode.GetSelected()

    if currentNode.path.isDirectory
        call  s:echoWarning("STOP! Cannot diff with directory\n")
    endif

    try
        execute "wincmd p"
        execute "vertical diffsplit " currentNode.path.str()
        "" no folding
        execute 'set nofoldenable'
        execute 'wincmd p'
        execute 'set nofoldenable'
        execute 'wincmd p'
    catch /^NERDTree/
        call s:echoWarning("Could not diff")
    endtry
endfunction

function! s:echo(msg)
    redraw
    echo "NERDTree: " . a:msg
endfunction

function! s:echoWarning(msg)
    echohl warningmsg
    call s:echo(a:msg)
    echohl normal
endfunction
