"" =============================================================================
" Contributor: George Hadjikyriacou <ghadjikyriacou at gmail dot com>
" Additions:   Code between "NERDTree++ comments
" Description: You can open files with the appropriate application, simply by 
"              pressing '!' key. Change global strings in file  
"              NERDTreeOpenInApp_cfg.vim with application (command) you like.
" Last Change: 25 April 2011 
" ==============================================================================

call NERDTreeAddKeyMap({'key': '!','callback': 'NERDTreeOpenInApp','quickhelpText': 'open in application' })

function! NERDTreeOpenInApp()
let n=g:NERDTreeFileNode.GetSelected()

if n!={}
"definition of the null device in linux
"in this case, null device used to disposing output streams of a command
    let nulldev = " >/dev/null 2>&1 &"

"GET filename and file extension
    let selectedfile = n.path.str({'format': 'Edit'})
    let dot = strridx(selectedfile, ".")
    let cext = strpart(selectedfile, dot)
    let ext = tolower(cext)

"File Extensions
    let image = [".jpg", ".jpeg", ".png", ".gif", ".bmp", ".svg", ".svgz", ".tiff", ".tga", ".ico"]
    let video_music = [".avi", ".mp3", ".mpg", ".mpeg", ".mpeg1", ".mpeg2", ".ogg", ".ogv", ".ogm", ".mkv", ".wav", ".wmv", ".mp4", ".mpeg4", ".m3u", ".m4v", ".flv", ".aac", ".mov", ".ts", ".vod", ".3gp"]
    let ebook = [".pdf", ".ps"]
    let document = [".odt", ".ods", ".odp", ".odg", ".odf", ".doc", ".xls", ".ppt"]
    let webpage = [".html", ".htm", ".xml"]
    let compressed = [".zip", ".rar", ".tar", ".gz", ".tgz", ".bz", ".tbz", ".7z", ".ar", "jar", ".xz", ".lzma", ".cbz", ".cbr", ".iso"]
    let torrent = [".torrent"] 

"Aplication => file extension association

    if index(image, ext) != -1
        execute ":silent !" . g:nt_image_viewer . " "  . selectedfile . nulldev
    endif

    if index(video_music, ext) != -1
        execute ":silent !" . g:nt_media_player . " " . selectedfile . nulldev
    endif

    if index(ebook, ext) != -1
        execute ":silent !" . g:nt_ebook_reader . " " .  selectedfile . nulldev
    endif

    if index(document, ext) != -1
        execute ":silent !" . g:nt_office_suite . " " . selectedfile . nulldev
    endif

    if index(webpage, ext) != -1
        execute ":silent !" . g:nt_web_browser . " " . selectedfile . nulldev
    endif

    if index(compressed, ext) != -1
        execute ":silent !" . g:nt_archive_manager . " " . selectedfile . nulldev
    endif

    if index(torrent, ext) != -1
        execute ":silent !" . g:nt_bittorrent_client . " " . selectedfile . nulldev
    endif
endif
redraw!
endfunction
