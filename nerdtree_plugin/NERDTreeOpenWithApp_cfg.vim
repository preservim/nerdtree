" =============================================================================
" Author:      George Hadjikyriacou <ghadjikyriacou at gmail dot com>
" Description: Change global variables below with application 
"              (command) and file extension you want and restart Vim!
" Last Change: 26 July 2011
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
" =============================================================================

"++++++++++++++++++++++++++++ Applications ++++++++++++++++++++++++++++
"============================Image Viewer (default: "eog")
let g:nt_image_viewer = "eog"

"============================Media Player (default: "vlc")
let g:nt_media_player = "vlc"

"============================Ebook Reader (default: "evince")
let g:nt_ebook_reader = "evince"

"============================Office Suite (default: "openoffice.org")
let g:nt_office_suite = "openoffice.org"

"============================Web Browser (default: "firefox")
let g:nt_web_browser = "firefox"

"============================Archive Manager (default: "file-roller")
let g:nt_archive_manager = "file-roller"

"============================BitTorrent Client (default: "transmission")
let g:nt_bittorrent_client = "transmission"

"============================Package Installer (default: "gdebi-gtk")
let g:package_installer = "gdebi-gtk"

"============================Windows Program Loader (default: "wine")
let g:nt_win_program_loader = "wine"

"============================File Manager (default: "pcmanfm")
let g:nt_file_manager = "pcmanfm"

"============================Terminal (default: "xterm")
let g:nt_terminal = "terminator"

"++++++++++++++++++++++++++++ File Extensions ++++++++++++++++++++++++++++
"============================Image Viewer
let g:image = [".jpg", ".jpeg", ".png", ".gif", ".bmp", ".svg", ".svgz", ".tiff", ".tga", ".ico"]

"============================Media Player
let g:video_music = [".avi", ".mp3", ".mpg", ".mpeg", ".mpeg1", ".mpeg2", ".ogg", ".ogv", ".ogm", ".mkv", ".wav", ".wmv", ".mp4", ".mpeg4", ".m3u", ".m4v", ".flv", ".aac", ".mov", ".ts", ".vod", ".3gp", ".ram"]

"============================Ebook Reader
let g:ebook = [".pdf", ".ps"]

"============================Office Suite
let g:document = [".odt", ".ods", ".odp", ".odg", ".odf", ".doc", ".xls", ".ppt"]

"============================Web Browser
let g:webpage = [".html", ".htm", ".xml"]

"============================Archive Manager
let g:compressed = [".zip", ".rar", ".tar", ".gz", ".tgz", ".bz", ".tbz", ".7z", ".ar", "jar", ".xz", ".lzma", ".cbz", ".cbr", ".iso"]

"============================BitTorrent Client
let g:torrent = [".torrent"]

"============================Package Installer
let g:package = [".deb", ".rpm"]

"============================Windows Program Loader
let g:windows_exe = [".exe", ".msi", ".bat"]
