" =============================================================================
" Author:      George Hadjikyriacou <ghadjikyriacou at gmail dot com>
" Description: You can open files with the appropriate application, simply by 
"              pressing '!' key. Change global variables in file  
"              NERDTreeOpenWithApp_cfg.vim with application (command) and file 
"              extensions you want.
"              Use '@' key to open file manager in current directory
" Last Change: 18 July 2011
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
" ==============================================================================

call NERDTreeAddKeyMap({'key': '!','callback': 'NERDTreeOpenWithApp','quickhelpText': 'open with application' })
call NERDTreeAddKeyMap({'key': '@','callback': 'NERDTreeOpenFm','quickhelpText': 'open file manager' })

let s:running_windows = has("win16") || has("win32") || has("win64")

"definition of the null device in windows (sucks) and linux
"in this case, null device used to disposing output streams of a command
if s:running_windows
    let s:nulldev = " >NUL &"
else
    let s:nulldev = " >/dev/null 2>&1 &"
endif

"function launching file manager in current directory.
function! NERDTreeOpenFm()
if exists('$DISPLAY') || s:running_windows
    let n=g:NERDTreeFileNode.GetSelected()
    if n!={}
"GET current directory
        let selectedfile = n.path.str({'format': 'Edit'})
        let slash = strridx(selectedfile, "/")
        let dir = strpart(selectedfile, 0, slash)
        execute ":silent !" . g:nt_file_manager . " "  . dir . " " . s:nulldev
        echo dir
    endif
redraw!
else
    echo "Error: You need to run NERDTreeOpenWithApp in an X environment!"
endif
endfunction

" function to open files with the appropriate application.
function! NERDTreeOpenWithApp()
if exists('$DISPLAY') || s:running_windows
    let n=g:NERDTreeFileNode.GetSelected()
    if n!={}

"GET filename and file extension
        let selectedfile = n.path.str({'format': 'Edit'})
        let dot = strridx(selectedfile, ".")
        let cext = strpart(selectedfile, dot)
        let ext = tolower(cext)

"Aplication => file extension association

        if index(g:image, ext) != -1
            execute ":silent !" . g:nt_image_viewer . " "  . selectedfile . s:nulldev
    
        elseif index(g:video_music, ext) != -1
            execute ":silent !" . g:nt_media_player . " " . selectedfile . s:nulldev

        elseif index(g:ebook, ext) != -1
            execute ":silent !" . g:nt_ebook_reader . " " .  selectedfile . s:nulldev

        elseif index(g:document, ext) != -1
            execute ":silent !" . g:nt_office_suite . " " . selectedfile . s:nulldev

        elseif index(g:webpage, ext) != -1
            execute ":silent !" . g:nt_web_browser . " " . selectedfile . s:nulldev

        elseif index(g:compressed, ext) != -1
            execute ":silent !" . g:nt_archive_manager . " " . selectedfile . s:nulldev

        elseif index(g:torrent, ext) != -1
            execute ":silent !" . g:nt_bittorrent_client . " " . selectedfile . s:nulldev

        elseif index(g:package, ext) != -1
            execute ":silent !" . g:packet_installer . " " . selectedfile . s:nulldev

        elseif index(g:windows_exe, ext) != -1
            execute ":silent !" . g:nt_win_program_loader . " " . selectedfile . s:nulldev

        endif

    endif
    redraw!
else
    echo "Error: You need to run NERDTreeOpenWithApp in an X environment!"
endif
endfunction
