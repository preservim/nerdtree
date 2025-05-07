"CLASS: KeyMap
"============================================================
let s:KeyMap = {}
let g:NERDTreeKeyMap = s:KeyMap
let s:keyMaps = {}

"FUNCTION: KeyMap.All() {{{1
function! s:KeyMap.All()
    let sortedKeyMaps = values(s:keyMaps)
    call sort(sortedKeyMaps, s:KeyMap.Compare, s:KeyMap)

    return sortedKeyMaps
endfunction

"FUNCTION: KeyMap.Compare(keyMap1, keyMap2) {{{1
function! s:KeyMap.Compare(keyMap1, keyMap2)

    let k1 = a:keyMap1.key
    let k2 = a:keyMap2.key

    if type(k1) == type([])
        let k1 = k1[0]
    endif
    if type(k2) == type([])
        let k2 = k2[0]
    endif

    return (k1 >? k2) ?  1  : ((k1 <? k2) ?  -1 :  0)
endfunction

"FUNCTION: KeyMap.FindFor(key, scope) {{{1
function! s:KeyMap.FindFor(key, scope)
    if type(a:key) == type([])
        for i in a:key
            let result = get(s:keyMaps, i . a:scope, {})
            if result != {}
                return result
            endif
        endfor
        return {}
    else
        return get(s:keyMaps, a:key . a:scope, {})
    endif
endfunction

"FUNCTION: KeyMap.BindAll() {{{1
function! s:KeyMap.BindAll()
    for i in values(s:keyMaps)
        call i.bind()
    endfor
endfunction

"FUNCTION: KeyMap.bind() {{{1
function! s:KeyMap.bind()
    " If the key sequence we're trying to map contains any '<>' notation, we
    " must replace each of the '<' characters with '<lt>' to ensure the string
    " is not translated into its corresponding keycode during the later part
    " of the map command below
    " :he <>

    let _keyAsList = type(self.key) == type([]) ? self.key : [self.key]
    for _key in _keyAsList
      let specialNotationRegex = '\m<\([[:alnum:]_-]\+>\)'
      if _key =~# specialNotationRegex
          let keymapInvokeString = substitute(_key, specialNotationRegex, '<lt>\1', 'g')
      else
          let keymapInvokeString = _key
      endif
      let keymapInvokeString = escape(keymapInvokeString, '\"')

      let premap = _key ==# '<LeftRelease>' ? ' <LeftRelease>' : ' '

      exec 'nnoremap <buffer> <silent> '. _key . premap . ':call nerdtree#ui_glue#invokeKeyMap("'. keymapInvokeString .'")<cr>'
    endfor
endfunction

"FUNCTION: KeyMap.Remove(key, scope) {{{1
function! s:KeyMap.Remove(key, scope)
    return remove(s:keyMaps, a:key . a:scope)
endfunction

"FUNCTION: KeyMap.invoke() {{{1
"Call the KeyMaps callback function
function! s:KeyMap.invoke(...)
    let l:Callback = type(self.callback) ==# type(function('tr')) ? self.callback : function(self.callback)
    if a:0
        call l:Callback(a:1)
    else
        call l:Callback()
    endif
endfunction

"FUNCTION: KeyMap.Invoke() {{{1
"Find a keymapping for a:key and the current scope invoke it.
"
"Scope is determined as follows:
"   * if the cursor is on a dir node then DirNode
"   * if the cursor is on a file node then FileNode
"   * if the cursor is on a bookmark then Bookmark
"
"If a keymap has the scope of 'all' then it will be called if no other keymap
"is found for a:key and the scope.
function! s:KeyMap.Invoke(key)

    "required because clicking the command window below another window still
    "invokes the <LeftRelease> mapping - but changes the window cursor
    "is in first
    "
    "TODO: remove this check when the vim bug is fixed
    if !g:NERDTree.ExistsForBuf()
        return {}
    endif

    let node = g:NERDTreeFileNode.GetSelected()
    if !empty(node)

        "try file node
        if !node.path.isDirectory
            let km = s:KeyMap.FindFor(a:key, 'FileNode')
            if !empty(km)
                return km.invoke(node)
            endif
        endif

        "try dir node
        if node.path.isDirectory
            let km = s:KeyMap.FindFor(a:key, 'DirNode')
            if !empty(km)
                return km.invoke(node)
            endif
        endif

        "try generic node
        let km = s:KeyMap.FindFor(a:key, 'Node')
        if !empty(km)
            return km.invoke(node)
        endif

    endif

    "try bookmark
    let bm = g:NERDTreeBookmark.GetSelected()
    if !empty(bm)
        let km = s:KeyMap.FindFor(a:key, 'Bookmark')
        if !empty(km)
            return km.invoke(bm)
        endif
    endif

    "try all
    let km = s:KeyMap.FindFor(a:key, 'all')
    if !empty(km)
        return km.invoke()
    endif
endfunction

"FUNCTION: KeyMap.Create(options) {{{1
function! s:KeyMap.Create(options)
    let opts = extend({'scope': 'all', 'quickhelpText': ''}, copy(a:options))

    "dont override other mappings unless the 'override' option is given
    if get(opts, 'override', 0) ==# 0 && !empty(s:KeyMap.FindFor(opts['key'], opts['scope']))
        return
    end

    let newKeyMap = copy(self)
    let newKeyMap.key = opts['key']
    let newKeyMap.quickhelpText = opts['quickhelpText']
    let newKeyMap.callback = opts['callback']
    let newKeyMap.scope = opts['scope']

    call s:KeyMap.Add(newKeyMap)
endfunction

"FUNCTION: KeyMap.Add(keymap) {{{1
function! s:KeyMap.Add(keymap)
    if type(a:keymap.key) == type([])
        for k in a:keymap.key
            let s:keyMaps[k . a:keymap.scope] = a:keymap
        endfor
    else
        let s:keyMaps[a:keymap.key . a:keymap.scope] = a:keymap
    endif
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
