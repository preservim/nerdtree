" =============================================================================
" Author:      George Hadjikyriacou <ghadjikyriacou at gmail dot com>
" Description: You can open files with the appropriate application, simply by 
"              pressing '!' key. Change global variables in file  
"              NERDTreeOpenWithApp_cfg.vim with application (command) and file 
"              extensions you want.
"              Use '@' key to open file manager in current directory
"              Use '#' key to open terminal in current directory
" Last Change: 17 Aug 2011
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
" ==============================================================================

call NERDTreeAddKeyMap({'key': '!','callback': 'NERDTreeOpenWithApp','quickhelpText': 'open with application' })
call NERDTreeAddKeyMap({'key': '@','callback': 'NERDTreeOpenFm','quickhelpText': 'open file manager' })
call NERDTreeAddKeyMap({'key': '#','callback': 'NERDTreeOpenTerm','quickhelpText': 'open terminal' })

let s:running_windows = has("win16") || has("win32") || has("win64")

"definition of the null device in windows (sucks) and linux
"in this case, null device used to disposing output streams of a command
if s:running_windows
    let s:nulldev = " >NUL &"
else
    let s:nulldev = " >/dev/null 2>&1 &"
endif


function! GETDirAndExt()
    let n=g:NERDTreeFileNode.GetSelected()
    if n!={}
        let s:selectedfile = n.path.str()
        let slash = strridx(s:selectedfile, "/")

"GET current directory
        let s:dir = strpart(s:selectedfile, 0, slash)

"GET file extension
        let dot = strridx(s:selectedfile, ".")
        let cext = strpart(s:selectedfile, dot)
        let s:ext = tolower(cext)

    endif
endfunction

"function launching terminal in current directory.
function! NERDTreeOpenTerm()
if exists('$DISPLAY') || s:running_windows
    call GETDirAndExt()  
    execute ":silent !cd " . s:dir . ";"  . g:nt_terminal . " " . s:nulldev
    redraw!
else
    echo "Error: You need to run NERDTreeOpenWithApp in an X environment!"
endif
endfunction

"function launching file manager in current directory.
function! NERDTreeOpenFm()
if exists('$DISPLAY') || s:running_windows
    call GETDirAndExt()
    execute ":silent !" . g:nt_file_manager . " "  . s:dir . " " . s:nulldev
    redraw!
else
    echo "Error: You need to run NERDTreeOpenWithApp in an X environment!"
endif
endfunction

" function to open files with the appropriate application.
function! NERDTreeOpenWithApp()
if exists('$DISPLAY') || s:running_windows
    call GETDirAndExt()
"Aplication => file extension association

    if index(g:image, s:ext) != -1
        execute ":silent !" . g:nt_image_viewer . " "  . s:selectedfile . s:nulldev
    
    elseif index(g:video_music, s:ext) != -1
        execute ":silent !" . g:nt_media_player . " " . s:selectedfile . s:nulldev

    elseif index(g:ebook, s:ext) != -1
        execute ":silent !" . g:nt_ebook_reader . " " .  s:selectedfile . s:nulldev

    elseif index(g:document, s:ext) != -1
        execute ":silent !" . g:nt_office_suite . " " . s:selectedfile . s:nulldev

    elseif index(g:webpage, s:ext) != -1
        execute ":silent !" . g:nt_web_browser . " " . s:selectedfile . s:nulldev

    elseif index(g:compressed, s:ext) != -1
       execute ":silent !" . g:nt_archive_manager . " " . s:selectedfile . s:nulldev

    elseif index(g:torrent, s:ext) != -1
        execute ":silent !" . g:nt_bittorrent_client . " " . s:selectedfile . s:nulldev

    elseif index(g:package, s:ext) != -1
        execute ":silent !" . g:packet_installer . " " . s:selectedfile . s:nulldev

    elseif index(g:windows_exe, s:ext) != -1
        execute ":silent !" . g:nt_win_program_loader . " " . s:selectedfile . s:nulldev

    endif

redraw!
else
    echo "Error: You need to run NERDTreeOpenWithApp in an X environment!"
endif
endfunction
