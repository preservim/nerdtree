"CLASS: RefreshNotifier
"============================================================
let s:RefreshNotifier = {}
let g:NERDTreeRefreshNotifier = s:RefreshNotifier

function! s:RefreshNotifier.AddListenerForAction(action, funcname)
    let listeners = s:RefreshNotifier.GetListenersForAction(a:action)
    if listeners == []
        let listenersMap = s:RefreshNotifier.GetListenersMap()
        let listenersMap[a:action] = listeners
    endif
    call add(listeners, a:funcname)
endfunction

function! s:RefreshNotifier.NotifyListenersForAction(action, refreshedPath, params)
    for listener in s:RefreshNotifier.GetListenersForAction(a:action)
        call {listener}(a:refreshedPath, a:params)
    endfor
endfunction

function! s:RefreshNotifier.GetListenersMap()
    if !exists("s:refreshListenersMap")
        let s:refreshListenersMap = {}
    endif
    return s:refreshListenersMap
endfunction

function! s:RefreshNotifier.GetListenersForAction(action)
    let listenersMap = s:RefreshNotifier.GetListenersMap()
    return get(listenersMap, a:action, [])
endfunction
