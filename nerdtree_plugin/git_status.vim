if exists('g:loaded_nerdtree_git_status')
    finish
endif
let g:loaded_nerdtree_git_status = 1

function! plugin:NerdGitStatus()
    if !exists('g:nerd_cached_git_status') || g:nerd_cached_git_status == '' 
        let g:nerd_cached_git_status = system("git status -s")
    endif
    let g:nerd_git_status_split = split(g:nerd_cached_git_status, '\n')
endfunction

function! plugin:NerdGitStatusRefresh()
    let g:nerd_cached_git_status = ''
    let g:nerd_git_status_split = {}
    call plugin:NerdGitStatus()
endfunction

function! plugin:GetStatusIndicator(us, them)
    if a:us == '?'
        return '✭'
    elseif a:us == 'R'
        return '➜'
    elseif a:us == 'D'
        return '✖'
    elseif a:us == 'U' || a:them == 'U'
        return '═'
    elseif a:us == 'M'
        return '✹'
    elseif a:us == 'A'
        return '✚'
    elseif a:us == ' '
        if a:them == 'M'
            return '✹'
        elseif a:them == 'D'
            return '✖'
        endif
    else
        return '*'
    endif
endfunction

function! plugin:GetGitStatusPrefix(path)
    let s:displayString = a:path.displayString()

    "remove the tree parts and the leading space
    let s:displayString = substitute (s:displayString, nerdtree#treeMarkupReg(),"","")

    "strip off any read only flag
    let s:displayString = substitute (s:displayString, ' \[RO\]', "","")

    "strip off any bookmark flags
    let s:displayString = substitute (s:displayString, ' {[^}]*}', "","")

    "strip off any executable flags
    let s:displayString = substitute (s:displayString, '*\ze\($\| \)', "","")

    "strip off any git status flags
    let s:displayString = substitute(s:displayString, '\[.*\]', "", "")

    for status in g:nerd_git_status_split
        let s:reletaivePath = substitute(status, '...', "", "")
        " echomsg a:path.AbsolutePathFor(s:reletaivePath)
        let s:position = stridx(status, s:displayString)
        if s:position != -1 
            if a:path.isDirectory 
                return "[✗]"
            endif
            let s:indicator = plugin:GetStatusIndicator(status[0], status[1])
            return "[" . s:indicator . "]"
        endif
    endfor

    return ""
endfunction
