"CLASS: RefreshNotifier
"============================================================
let s:RefreshNotifier = {}
let g:NERDTreeRefreshNotifier = s:RefreshNotifier

function! s:RefreshNotifier.AddListener(funcname)
    call add(s:RefreshNotifier.GetListeners(), a:funcname)
endfunction

function! s:RefreshNotifier.NotifyListeners(refreshedPath)
    for listener in s:RefreshNotifier.GetListeners()
        call {listener}(a:refreshedPath)
    endfor
endfunction

function! s:RefreshNotifier.GetListeners()
    if !exists("s:refreshListeners")
        let s:refreshListeners = []
    endif
    return s:refreshListeners
endfunction
