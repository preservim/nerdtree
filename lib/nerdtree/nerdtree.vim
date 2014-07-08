"CLASS: NERDTree
"============================================================
let s:NERDTree = {}
let g:NERDTree = s:NERDTree

function! s:NERDTree.ForCurrentBuf()
    return b:NERDTree
endfunction

function! s:NERDTree.New(path)
    let newObj = copy(self)
    let newObj.ui = g:NERDTreeUI.New(newObj)
    let newObj.root = g:NERDTreeDirNode.New(a:path)

    return newObj
endfunction

"FUNCTION: s:NERDTree.render() {{{1
"A convenience function - since this is called often
function! s:NERDTree.render()
    call self.ui.render()
endfunction

