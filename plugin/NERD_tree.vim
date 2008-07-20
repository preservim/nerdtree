" ============================================================================
" File:        NERD_tree.vim
" Description: vim global plugin that provides a nice tree explorer
" Maintainer:  Martin Grenfell <martin_grenfell at msn dot com>
" Last Change: 20 July, 2008
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" ============================================================================
let s:NERD_tree_version = '2.13.0'

" SECTION: Script init stuff {{{1
"============================================================
if exists("loaded_nerd_tree")
    finish
endif
if v:version < 700
    echoerr "NERDTree: this plugin requires vim >= 7. DOWNLOAD IT! You'll thank me later!"
    finish
endif
let loaded_nerd_tree = 1
"Function: s:InitVariable() function {{{2
"This function is used to initialise a given variable to a given value. The
"variable is only initialised if it does not exist prior
"
"Args:
"var: the name of the var to be initialised
"value: the value to initialise var to
"
"Returns:
"1 if the var is set, 0 otherwise
function! s:InitVariable(var, value)
    if !exists(a:var)
        exec 'let ' . a:var . ' = ' . "'" . a:value . "'"
        return 1
    endif
    return 0
endfunction

"SECTION: Init variable calls and other random constants {{{2
call s:InitVariable("g:NERDChristmasTree", 1)
call s:InitVariable("g:NERDTreeAutoCenter", 1)
call s:InitVariable("g:NERDTreeAutoCenterThreshold", 3)
call s:InitVariable("g:NERDTreeCaseSensitiveSort", 0)
call s:InitVariable("g:NERDTreeChDirMode", 0)
if !exists("g:NERDTreeIgnore")
    let g:NERDTreeIgnore = ['\~$']
endif
call s:InitVariable("g:NERDTreeHighlightCursorline", 1)
call s:InitVariable("g:NERDTreeBookmarksFile", expand('$HOME') . '/.NERDTreeBookmarks')
call s:InitVariable("g:NERDTreeMouseMode", 1)
call s:InitVariable("g:NERDTreeNotificationThreshold", 100)
call s:InitVariable("g:NERDTreeQuitOnOpen", 0)
call s:InitVariable("g:NERDTreeShowBookmarks", 0)
call s:InitVariable("g:NERDTreeShowFiles", 1)
call s:InitVariable("g:NERDTreeShowHidden", 0)
call s:InitVariable("g:NERDTreeShowLineNumbers", 0)
call s:InitVariable("g:NERDTreeSortDirs", 1)

if !exists("g:NERDTreeSortOrder")
    let g:NERDTreeSortOrder = ['\/$', '*', '\.swp$',  '\.bak$', '\~$']
else
    "if there isnt a * in the sort sequence then add one
    if count(g:NERDTreeSortOrder, '*') < 1
        call add(g:NERDTreeSortOrder, '*')
    endif
endif

"we need to use this number many times for sorting... so we calculate it only
"once here
let s:NERDTreeSortStarIndex = index(g:NERDTreeSortOrder, '*')

call s:InitVariable("g:NERDTreeWinPos", "left")
call s:InitVariable("g:NERDTreeWinSize", 31)

let s:running_windows = has("win16") || has("win32") || has("win64")

"init the shell commands that will be used to copy nodes, and remove dir trees
"
"Note: the space after the command is important
if s:running_windows
    call s:InitVariable("g:NERDTreeRemoveDirCmd", 'rmdir /s /q ')
else
    call s:InitVariable("g:NERDTreeRemoveDirCmd", 'rm -rf ')
    call s:InitVariable("g:NERDTreeCopyCmd", 'cp -r ')
endif


"SECTION: Init variable calls for key mappings {{{2
call s:InitVariable("g:NERDTreeMapActivateNode", "o")
call s:InitVariable("g:NERDTreeMapChangeRoot", "C")
call s:InitVariable("g:NERDTreeMapChdir", "cd")
call s:InitVariable("g:NERDTreeMapCloseChildren", "X")
call s:InitVariable("g:NERDTreeMapCloseDir", "x")
call s:InitVariable("g:NERDTreeMapExecute", "!")
call s:InitVariable("g:NERDTreeMapFilesystemMenu", "m")
call s:InitVariable("g:NERDTreeMapHelp", "?")
call s:InitVariable("g:NERDTreeMapJumpFirstChild", "K")
call s:InitVariable("g:NERDTreeMapJumpLastChild", "J")
call s:InitVariable("g:NERDTreeMapJumpNextSibling", "<C-j>")
call s:InitVariable("g:NERDTreeMapJumpParent", "p")
call s:InitVariable("g:NERDTreeMapJumpPrevSibling", "<C-k>")
call s:InitVariable("g:NERDTreeMapJumpRoot", "P")
call s:InitVariable("g:NERDTreeMapOpenExpl", "e")
call s:InitVariable("g:NERDTreeMapOpenInTab", "t")
call s:InitVariable("g:NERDTreeMapOpenInTabSilent", "T")
call s:InitVariable("g:NERDTreeMapOpenRecursively", "O")
call s:InitVariable("g:NERDTreeMapOpenSplit", "<tab>")
call s:InitVariable("g:NERDTreeMapPreview", "g" . NERDTreeMapActivateNode)
call s:InitVariable("g:NERDTreeMapPreviewSplit", "g" . NERDTreeMapOpenSplit)
call s:InitVariable("g:NERDTreeMapQuit", "q")
call s:InitVariable("g:NERDTreeMapRefresh", "r")
call s:InitVariable("g:NERDTreeMapRefreshRoot", "R")
call s:InitVariable("g:NERDTreeMapToggleBookmarks", "B")
call s:InitVariable("g:NERDTreeMapToggleFiles", "F")
call s:InitVariable("g:NERDTreeMapToggleFilters", "f")
call s:InitVariable("g:NERDTreeMapToggleHidden", "H")
call s:InitVariable("g:NERDTreeMapUpdir", "u")
call s:InitVariable("g:NERDTreeMapUpdirKeepOpen", "U")

"SECTION: Script level variable declaration{{{2
let s:escape_chars =  " \\`\|\"#%&,?()\*^<>"
let s:NERDTreeWinName = '_NERD_tree_'

let s:tree_wid = 2
let s:tree_markup_reg = '[ \-+~`|]'
let s:tree_markup_reg_neg = '[^ \-+~`|]'
let s:tree_up_dir_line = '.. (up a dir)'

let s:os_slash = '/'
if s:running_windows
    let s:os_slash = '\'
endif


" SECTION: Commands {{{1
"============================================================
"init the command that users start the nerd tree with
command! -n=? -complete=dir NERDTree :call s:InitNerdTree('<args>')
command! -n=? -complete=dir NERDTreeToggle :call s:Toggle('<args>')
command! -n=0 NERDTreeClose :call s:CloseTreeIfOpen()
command! -n=1 -complete=customlist,s:CompleteBookmarks NERDTreeFromBookmark call s:InitNerdTree('<args>')
" SECTION: Auto commands {{{1
"============================================================
"Save the cursor position whenever we close the nerd tree
exec "autocmd BufWinLeave *". s:NERDTreeWinName ."* :call <SID>SaveScreenState()"
"cache bookmarks when vim loads
autocmd VimEnter * call s:oBookmark.CacheBookmarks(0)

"SECTION: Classes {{{1
"============================================================
"CLASS: oBookmark {{{2
"============================================================
let s:oBookmark = {}
" FUNCTION: oBookmark.AddBookmark(name, path) {{{3
" Class method to add a new bookmark to the list, if a previous bookmark exists
" with the same name, just update the path for that bookmark
function! s:oBookmark.AddBookmark(name, path) dict
    for i in s:oBookmark.Bookmarks()
        if i.name == a:name
            let i.path = a:path
            return
        endif
    endfor
    call add(s:oBookmark.Bookmarks(), s:oBookmark.New(a:name, a:path))
    call s:oBookmark.Sort()
endfunction
" Function: oBookmark.Bookmarks()   {{{3
" Class method to get all bookmarks. Lazily initializes the bookmarks global
" variable
function! s:oBookmark.Bookmarks() dict
    if !exists("g:NERDTreeBookmarks")
        let g:NERDTreeBookmarks = []
    endif
    return g:NERDTreeBookmarks
endfunction
" Function: oBookmark.BookmarkExistsFor(name)   {{{3
" class method that returns 1 if a bookmark with the given name is found, 0
" otherwise
function! s:oBookmark.BookmarkExistsFor(name) dict
    try
        call s:oBookmark.BookmarkFor(a:name)
        return 1
    catch /NERDTree.BookmarkNotFound/
        return 0
    endtry
endfunction
" Function: oBookmark.BookmarkFor(name)   {{{3
" Class method to get the bookmark that has the given name. {} is return if no
" bookmark is found
function! s:oBookmark.BookmarkFor(name) dict
    for i in s:oBookmark.Bookmarks()
        if i.name == a:name
            return i
        endif
    endfor
    throw "NERDTree.BookmarkNotFound exception: no bookmark found for name: \"". a:name  .'"'
endfunction
" Function: oBookmark.BookmarkNames()   {{{3
" Class method to return an array of all bookmark names
function! s:oBookmark.BookmarkNames() dict
    let names = []
    for i in s:oBookmark.Bookmarks()
        call add(names, i.name)
    endfor
    return names
endfunction
" FUNCTION: oBookmark.CacheBookmarks(silent) {{{3
" Class method to read all bookmarks from the bookmarks file intialize
" bookmark objects for each one.
"
" Args:
" silent - dont echo an error msg if invalid bookmarks are found
function! s:oBookmark.CacheBookmarks(silent) dict
    if filereadable(g:NERDTreeBookmarksFile)
        let g:NERDTreeBookmarks = []
        let g:NERDTreeInvalidBookmarks = []
        let bookmarkStrings = readfile(g:NERDTreeBookmarksFile)
        let invalidBookmarksFound = 0
        for i in bookmarkStrings

            "ignore blank lines
            if i != ''

                let name = substitute(i, '^\(.\{-}\) .*$', '\1', '')
                let path = substitute(i, '^.\{-} \(.*\)$', '\1', '')

                try
                    let bookmark = s:oBookmark.New(name, s:oPath.New(path))
                    call add(g:NERDTreeBookmarks, bookmark)
                catch /NERDTree.Path.InvalidArguments/
                    call add(g:NERDTreeInvalidBookmarks, i)
                    let invalidBookmarksFound += 1
                endtry
            endif
        endfor
        if invalidBookmarksFound
            call s:oBookmark.Write()
            if !a:silent
                call s:Echo(invalidBookmarksFound . " invalid bookmarks were read. See :help NERDTreeInvalidBookmarks for info.")
            endif
        endif
        call s:oBookmark.Sort()
    endif
endfunction
" FUNCTION: oBookmark.CompareTo(otherbookmark) {{{3
" Compare these two bookmarks for sorting purposes
function! s:oBookmark.CompareTo(otherbookmark) dict
    return a:otherbookmark.name < self.name
endfunction
" FUNCTION: oBookmark.ClearAll() {{{3
" Class method to delete all bookmarks.
function! s:oBookmark.ClearAll() dict
    for i in s:oBookmark.Bookmarks()
        call i.Delete()
    endfor
    call s:oBookmark.Write()
endfunction
" FUNCTION: oBookmark.Delete() {{{3
" Delete this bookmark. If the node for this bookmark is under the current
" root, then recache bookmarks for its Path object
function! s:oBookmark.Delete() dict
    let node = {}
    try
        let node = self.GetNode(1)
    catch /NERDTree.BookmarkNotFound/
    endtry
    call remove(s:oBookmark.Bookmarks(), index(s:oBookmark.Bookmarks(), self))
    if !empty(node)
        call node.path.CacheDisplayString()
    endif
    call s:oBookmark.Write()
endfunction
" FUNCTION: oBookmark.GetNode(searchFromAbsoluteRoot) {{{3
" Gets the treenode for this bookmark
"
" Args:
" searchFromAbsoluteRoot: specifies whether we should search from the current
" tree root, or the highest cached node
function! s:oBookmark.GetNode(searchFromAbsoluteRoot) dict
    let searchRoot = a:searchFromAbsoluteRoot ? s:AbsoluteTreeRoot() : t:NERDTreeRoot
    let targetNode = searchRoot.FindNode(self.path)
    if empty(targetNode)
        throw "NERDTree.BookmarkedNodeNotFound no node was found for bookmark: " . self.name
    endif
    return targetNode
endfunction
" FUNCTION: oBookmark.GetNodeForName(name, searchFromAbsoluteRoot) {{{3
" Class method that finds the bookmark with the given name and returns the
" treenode for it.
function! s:oBookmark.GetNodeForName(name, searchFromAbsoluteRoot) dict
    let bookmark = s:oBookmark.BookmarkFor(a:name)
    return bookmark.GetNode(a:searchFromAbsoluteRoot)
endfunction
" Function: oBookmark.InvalidBookmarks()   {{{3
" Class method to get all invalid bookmark strings read from the bookmarks
" file
function! s:oBookmark.InvalidBookmarks() dict
    if !exists("g:NERDTreeInvalidBookmarks")
        let g:NERDTreeInvalidBookmarks = []
    endif
    return g:NERDTreeInvalidBookmarks
endfunction
" FUNCTION: oBookmark.MustExist() {{{3
function! s:oBookmark.MustExist() dict
    if !self.path.Exists()
        call s:oBookmark.CacheBookmarks(1)
        throw "NERDTree.BookmarkPointsToInvalidLocation exception: the bookmark \"".
            \ self.name ."\" points to a non existing location: \"". self.path.StrForOS(0)
    endif
endfunction
" FUNCTION: oBookmark.New(name, path) {{{3
" Create a new bookmark object with the given name and path object
function! s:oBookmark.New(name, path) dict
    if a:name =~ ' '
        throw "NERDTree.IllegalBookmarkName illegal name:" . a:name
    endif

    let newBookmark = copy(self)
    let newBookmark.name = a:name
    let newBookmark.path = a:path
    return newBookmark
endfunction
" Function: oBookmark.SetPath(path)   {{{3
" makes this bookmark point to the given path
function! s:oBookmark.SetPath(path) dict
    let self.path = a:path
endfunction
" Function: oBookmark.Sort()   {{{3
" Class method that sorts all bookmarks
function! s:oBookmark.Sort() dict
    let CompareFunc = function("s:CompareBookmarks")
    call sort(s:oBookmark.Bookmarks(), CompareFunc)
endfunction
" Function: oBookmark.Str()   {{{3
" Get the string that should be rendered in the view for this bookmark
function! s:oBookmark.Str() dict
    let pathStrMaxLen = winwidth(s:GetTreeWinNum()) - 5 - len(self.name)
    if &nu
        let pathStrMaxLen = pathStrMaxLen - &numberwidth
    endif

    let pathStr = self.path.StrForOS(0)
    if len(pathStr) > pathStrMaxLen
        let pathStr = '<' . strpart(pathStr, len(pathStr) - pathStrMaxLen)
    endif
    return '>' . self.name . ' [' . pathStr . ']'
endfunction
" Function: oBookmark.Write()   {{{3
" Class method to write all bookmarks to the bookmarks file
function! s:oBookmark.Write() dict
    let bookmarkStrings = []
    for i in s:oBookmark.Bookmarks()
        call add(bookmarkStrings, i.name . ' ' . i.path.StrForOS(0))
    endfor

    "add a blank line before the invalid ones
    call add(bookmarkStrings, "")

    for j in s:oBookmark.InvalidBookmarks()
        call add(bookmarkStrings, j)
    endfor
    call writefile(bookmarkStrings, g:NERDTreeBookmarksFile)
endfunction
"CLASS: oTreeFileNode {{{2
"This class is the parent of the oTreeDirNode class and constitures the
"'Component' part of the composite design pattern between the treenode
"classes.
"============================================================
let s:oTreeFileNode = {}
"FUNCTION: oTreeFileNode.Bookmark(name) {{{3
"bookmark this node with a:name
function! s:oTreeFileNode.Bookmark(name) dict
    try
        let oldMarkedNode = s:oBookmark.GetNodeForName(a:name, 1)
        call oldMarkedNode.path.CacheDisplayString()
    catch /NERDTree.Bookmark\(DoesntExist\|NotFound\)/
    endtry

    call s:oBookmark.AddBookmark(a:name, self.path)
    call self.path.CacheDisplayString()
    call s:oBookmark.Write()
endfunction
"FUNCTION: oTreeFileNode.CacheParent {{{3
"initializes self.parent if it isnt already
function! s:oTreeFileNode.CacheParent() dict
    if empty(self.parent)
        let parentPath = self.path.GetParent()
        if parentPath.Equals(self.path)
            throw "NERDTree.CannotCacheParent exception: already at root"
        endif
        let self.parent = s:oTreeFileNode.New(parentPath)
    endif
endfunction
"FUNCTION: oTreeFileNode.CompareNodes {{{3
"This is supposed to be a class level method but i cant figure out how to
"get func refs to work from a dict..
"
"A class level method that compares two nodes
"
"Args:
"n1, n2: the 2 nodes to compare
function! s:CompareNodes(n1, n2)
    return a:n1.path.CompareTo(a:n2.path)
endfunction

"FUNCTION: oTreeFileNode.ClearBookmarks() {{{3
function! s:oTreeFileNode.ClearBookmarks() dict
    for i in s:oBookmark.Bookmarks()
        if i.path.Equals(self.path)
            call i.Delete()
        end
    endfor
    call self.path.CacheDisplayString()
endfunction
"FUNCTION: oTreeFileNode.Copy(dest) {{{3
function! s:oTreeFileNode.Copy(dest) dict
    call self.path.Copy(a:dest)
    let newPath = s:oPath.New(a:dest)
    let parent = t:NERDTreeRoot.FindNode(newPath.GetParent())
    if !empty(parent)
        call parent.Refresh()
    endif
    return parent.FindNode(newPath)
endfunction

"FUNCTION: oTreeFileNode.Delete {{{3
"Removes this node from the tree and calls the Delete method for its path obj
function! s:oTreeFileNode.Delete() dict
    call self.path.Delete()
    call self.parent.RemoveChild(self)
endfunction

"FUNCTION: oTreeFileNode.Equals(treenode) {{{3
"
"Compares this treenode to the input treenode and returns 1 if they are the
"same node.
"
"Use this method instead of ==  because sometimes when the treenodes contain
"many children, vim seg faults when doing ==
"
"Args:
"treenode: the other treenode to compare to
function! s:oTreeFileNode.Equals(treenode) dict
    return self.path.Str(1) == a:treenode.path.Str(1)
endfunction

"FUNCTION: oTreeFileNode.FindNode(path) {{{3
"Returns self if this node.path.Equals the given path.
"Returns {} if not equal.
"
"Args:
"path: the path object to compare against
function! s:oTreeFileNode.FindNode(path) dict
    if a:path.Equals(self.path)
        return self
    endif
    return {}
endfunction
"FUNCTION: oTreeFileNode.FindOpenDirSiblingWithChildren(direction) {{{3
"
"Finds the next sibling for this node in the indicated direction. This sibling
"must be a directory and may/may not have children as specified.
"
"Args:
"direction: 0 if you want to find the previous sibling, 1 for the next sibling
"
"Return:
"a treenode object or {} if no appropriate sibling could be found
function! s:oTreeFileNode.FindOpenDirSiblingWithChildren(direction) dict
    "if we have no parent then we can have no siblings
    if self.parent != {}
        let nextSibling = self.FindSibling(a:direction)

        while nextSibling != {}
            if nextSibling.path.isDirectory && nextSibling.HasVisibleChildren() && nextSibling.isOpen
                return nextSibling
            endif
            let nextSibling = nextSibling.FindSibling(a:direction)
        endwhile
    endif

    return {}
endfunction
"FUNCTION: oTreeFileNode.FindSibling(direction) {{{3
"
"Finds the next sibling for this node in the indicated direction
"
"Args:
"direction: 0 if you want to find the previous sibling, 1 for the next sibling
"
"Return:
"a treenode object or {} if no sibling could be found
function! s:oTreeFileNode.FindSibling(direction) dict
    "if we have no parent then we can have no siblings
    if self.parent != {}

        "get the index of this node in its parents children
        let siblingIndx = self.parent.GetChildIndex(self.path)

        if siblingIndx != -1
            "move a long to the next potential sibling node
            let siblingIndx = a:direction == 1 ? siblingIndx+1 : siblingIndx-1

            "keep moving along to the next sibling till we find one that is valid
            let numSiblings = self.parent.GetChildCount()
            while siblingIndx >= 0 && siblingIndx < numSiblings

                "if the next node is not an ignored node (i.e. wont show up in the
                "view) then return it
                if self.parent.children[siblingIndx].path.Ignore() == 0
                    return self.parent.children[siblingIndx]
                endif

                "go to next node
                let siblingIndx = a:direction == 1 ? siblingIndx+1 : siblingIndx-1
            endwhile
        endif
    endif

    return {}
endfunction

"FUNCTION: oTreeFileNode.IsVisible() {{{3
"returns 1 if this node should be visible according to the tree filters and
"hidden file filters (and their on/off status)
function! s:oTreeFileNode.IsVisible() dict
    return !self.path.Ignore()
endfunction


"FUNCTION: oTreeFileNode.IsRoot() {{{3
"returns 1 if this node is t:NERDTreeRoot
function! s:oTreeFileNode.IsRoot() dict
    if !s:TreeExistsForTab()
        throw "NERDTree.TreeFileNode.IsRoot exception: No tree exists for the current tab"
    endif
    return self.Equals(t:NERDTreeRoot)
endfunction

"FUNCTION: oTreeFileNode.MakeRoot() {{{3
"Make this node the root of the tree
function! s:oTreeFileNode.MakeRoot() dict
    if self.path.isDirectory
        let t:NERDTreeRoot = self
    else
        call self.CacheParent()
        let t:NERDTreeRoot = self.parent
    endif

    call t:NERDTreeRoot.Open()

    "change dir to the dir of the new root if instructed to
    if g:NERDTreeChDirMode == 2
        exec "cd " . t:NERDTreeRoot.path.StrForEditCmd()
    endif
endfunction
"FUNCTION: oTreeFileNode.New(path) {{{3
"Returns a new TreeNode object with the given path and parent
"
"Args:
"path: a path object representing the full filesystem path to the file/dir that the node represents
function! s:oTreeFileNode.New(path) dict
    if a:path.isDirectory
        return s:oTreeDirNode.New(a:path)
    else
        let newTreeNode = {}
        let newTreeNode = copy(self)
        let newTreeNode.path = a:path
        let newTreeNode.parent = {}
        return newTreeNode
    endif
endfunction

"FUNCTION: oTreeFileNode.Refresh {{{3
function! s:oTreeFileNode.Refresh() dict
    call self.path.Refresh()
endfunction
"FUNCTION: oTreeFileNode.Rename {{{3
"Calls the rename method for this nodes path obj
function! s:oTreeFileNode.Rename(newName) dict
    let newName = substitute(a:newName, '\(\\\|\/\)$', '', '')
    call self.path.Rename(newName)
    call self.parent.RemoveChild(self)

    let parentPath = self.path.GetPathTrunk()
    let newParent = t:NERDTreeRoot.FindNode(parentPath)

    if newParent != {}
        call newParent.CreateChild(self.path, 1)
        call newParent.Refresh()
    endif
endfunction
"FUNCTION: oTreeFileNode.StrDisplay() {{{3
"
"Returns a string that specifies how the node should be represented as a
"string
"
"Return:
"a string that can be used in the view to represent this node
function! s:oTreeFileNode.StrDisplay() dict
    return self.path.StrDisplay()
endfunction

"CLASS: oTreeDirNode {{{2
"This class is a child of the oTreeFileNode class and constitutes the
"'Composite' part of the composite design pattern between the treenode
"classes.
"============================================================
let s:oTreeDirNode = copy(s:oTreeFileNode)
"FUNCTION: oTreeDirNode.AddChild(treenode, inOrder) {{{3
"Adds the given treenode to the list of children for this node
"
"Args:
"-treenode: the node to add
"-inOrder: 1 if the new node should be inserted in sorted order
function! s:oTreeDirNode.AddChild(treenode, inOrder) dict
    call add(self.children, a:treenode)
    let a:treenode.parent = self

    if a:inOrder
        call self.SortChildren()
    endif
endfunction

"FUNCTION: oTreeDirNode.Close {{{3
"Closes this directory
function! s:oTreeDirNode.Close() dict
    let self.isOpen = 0
endfunction

"FUNCTION: oTreeDirNode.CloseChildren {{{3
"Closes all the child dir nodes of this node
function! s:oTreeDirNode.CloseChildren() dict
    for i in self.children
        if i.path.isDirectory
            call i.Close()
            call i.CloseChildren()
        endif
    endfor
endfunction

"FUNCTION: oTreeDirNode.CreateChild(path, inOrder) {{{3
"Instantiates a new child node for this node with the given path. The new
"nodes parent is set to this node.
"
"Args:
"path: a Path object that this node will represent/contain
"inOrder: 1 if the new node should be inserted in sorted order
"
"Returns:
"the newly created node
function! s:oTreeDirNode.CreateChild(path, inOrder) dict
    let newTreeNode = s:oTreeFileNode.New(a:path)
    call self.AddChild(newTreeNode, a:inOrder)
    return newTreeNode
endfunction

"FUNCTION: oTreeDirNode.FindNode(path) {{{3
"Will find one of the children (recursively) that has the given path
"
"Args:
"path: a path object
unlet s:oTreeDirNode.FindNode
function! s:oTreeDirNode.FindNode(path) dict
    if a:path.Equals(self.path)
        return self
    endif
    if stridx(a:path.Str(1), self.path.Str(1), 0) == -1
        return {}
    endif

    if self.path.isDirectory
        for i in self.children
            let retVal = i.FindNode(a:path)
            if retVal != {}
                return retVal
            endif
        endfor
    endif
    return {}
endfunction

"FUNCTION: oTreeDirNode.GetChildDirs() {{{3
"Returns the number of children this node has
function! s:oTreeDirNode.GetChildCount() dict
    return len(self.children)
endfunction

"FUNCTION: oTreeDirNode.GetChildDirs() {{{3
"Returns an array of all children of this node that are directories
"
"Return:
"an array of directory treenodes
function! s:oTreeDirNode.GetChildDirs() dict
    let toReturn = []
    for i in self.children
        if i.path.isDirectory
            call add(toReturn, i)
        endif
    endfor
    return toReturn
endfunction

"FUNCTION: oTreeDirNode.GetChildFiles() {{{3
"Returns an array of all children of this node that are files
"
"Return:
"an array of file treenodes
function! s:oTreeDirNode.GetChildFiles() dict
    let toReturn = []
    for i in self.children
        if i.path.isDirectory == 0
            call add(toReturn, i)
        endif
    endfor
    return toReturn
endfunction

"FUNCTION: oTreeDirNode.GetChild(path) {{{3
"Returns child node of this node that has the given path or {} if no such node
"exists.
"
"This function doesnt not recurse into child dir nodes
"
"Args:
"path: a path object
function! s:oTreeDirNode.GetChild(path) dict
    if stridx(a:path.Str(1), self.path.Str(1), 0) == -1
        return {}
    endif

    let index = self.GetChildIndex(a:path)
    if index == -1
        return {}
    else
        return self.children[index]
    endif

endfunction

"FUNCTION: oTreeDirNode.GetChildByIndex(indx, visible) {{{3
"returns the child at the given index
"Args:
"indx: the index to get the child from
"visible: 1 if only the visible children array should be used, 0 if all the
"children should be searched.
function! s:oTreeDirNode.GetChildByIndex(indx, visible) dict
    let array_to_search = a:visible? self.GetVisibleChildren() : self.children
    if a:indx > len(array_to_search)
        throw "NERDTree.TreeDirNode.InvalidArguments exception. Index is out of bounds."
    endif
    return array_to_search[a:indx]
endfunction

"FUNCTION: oTreeDirNode.GetChildIndex(path) {{{3
"Returns the index of the child node of this node that has the given path or
"-1 if no such node exists.
"
"This function doesnt not recurse into child dir nodes
"
"Args:
"path: a path object
function! s:oTreeDirNode.GetChildIndex(path) dict
    if stridx(a:path.Str(1), self.path.Str(1), 0) == -1
        return -1
    endif

    "do a binary search for the child
    let a = 0
    let z = self.GetChildCount()
    while a < z
        let mid = (a+z)/2
        let diff = a:path.CompareTo(self.children[mid].path)

        if diff == -1
            let z = mid
        elseif diff == 1
            let a = mid+1
        else
            return mid
        endif
    endwhile
    return -1
endfunction

"FUNCTION: oTreeDirNode.GetVisibleChildCount() {{{3
"Returns the number of visible children this node has
function! s:oTreeDirNode.GetVisibleChildCount() dict
    return len(self.GetVisibleChildren())
endfunction

"FUNCTION: oTreeDirNode.GetVisibleChildren() {{{3
"Returns a list of children to display for this node, in the correct order
"
"Return:
"an array of treenodes
function! s:oTreeDirNode.GetVisibleChildren() dict
    let toReturn = []
    for i in self.children
        if i.path.Ignore() == 0
            call add(toReturn, i)
        endif
    endfor
    return toReturn
endfunction

"FUNCTION: oTreeDirNode.HasVisibleChildren {{{3
"returns 1 if this node has any childre, 0 otherwise..
function! s:oTreeDirNode.HasVisibleChildren()
    return self.GetChildCount() != 0
endfunction

"FUNCTION: oTreeDirNode.InitChildren {{{3
"Removes all childen from this node and re-reads them
"
"Args:
"silent: 1 if the function should not echo any "please wait" messages for
"large directories
"
"Return: the number of child nodes read
function! s:oTreeDirNode.InitChildren(silent) dict
    "remove all the current child nodes
    let self.children = []

    "get an array of all the files in the nodes dir
    let dir = self.path
    let filesStr = globpath(dir.StrForGlob(), '*') . "\n" . globpath(dir.StrForGlob(), '.*')
    let files = split(filesStr, "\n")

    if !a:silent && len(files) > g:NERDTreeNotificationThreshold
        call s:Echo("Please wait, caching a large dir ...")
    endif

    let invalidFilesFound = 0
    for i in files

        "filter out the .. and . directories
        "Note: we must match .. AND ../ cos sometimes the globpath returns
        "../ for path with strange chars (eg $)
        if i !~ '\.\.\/\?$' && i !~ '\.\/\?$'

            "put the next file in a new node and attach it
            try
                let path = s:oPath.New(i)
                call self.CreateChild(path, 0)
            catch /^NERDTree.Path.\(InvalidArguments\|InvalidFiletype\)/
                let invalidFilesFound += 1
            endtry
        endif
    endfor

    call self.SortChildren()

    if !a:silent && len(files) > g:NERDTreeNotificationThreshold
        call s:Echo("Please wait, caching a large dir ... DONE (". self.GetChildCount() ." nodes cached).")
    endif

    if invalidFilesFound
        call s:EchoWarning(invalidFilesFound . " file(s) could not be loaded into the NERD tree")
    endif
    return self.GetChildCount()
endfunction
"FUNCTION: oTreeDirNode.New(path) {{{3
"Returns a new TreeNode object with the given path and parent
"
"Args:
"path: a path object representing the full filesystem path to the file/dir that the node represents
unlet s:oTreeDirNode.New
function! s:oTreeDirNode.New(path) dict
    if a:path.isDirectory != 1
        throw "NERDTree.TreeDirNode.InvalidArguments exception. A TreeDirNode object must be instantiated with a directory Path object."
    endif

    let newTreeNode = copy(self)
    let newTreeNode.path = a:path

    let newTreeNode.isOpen = 0
    let newTreeNode.children = []

    let newTreeNode.parent = {}

    return newTreeNode
endfunction
"FUNCTION: oTreeDirNode.Open {{{3
"Reads in all this nodes children
"
"Return: the number of child nodes read
function! s:oTreeDirNode.Open() dict
    let self.isOpen = 1
    if self.children == []
        return self.InitChildren(0)
    else
        return 0
    endif
endfunction

"FUNCTION: oTreeDirNode.OpenRecursively {{{3
"Opens this treenode and all of its children whose paths arent 'ignored'
"because of the file filters.
"
"This method is actually a wrapper for the OpenRecursively2 method which does
"the work.
function! s:oTreeDirNode.OpenRecursively() dict
    call self.OpenRecursively2(1)
endfunction

"FUNCTION: oTreeDirNode.OpenRecursively2 {{{3
"Dont call this method from outside this object.
"
"Opens this all children of this treenode recursively if either:
"   *they arent filtered by file filters
"   *a:forceOpen is 1
"
"Args:
"forceOpen: 1 if this node should be opened regardless of file filters
function! s:oTreeDirNode.OpenRecursively2(forceOpen) dict
    if self.path.Ignore() == 0 || a:forceOpen
        let self.isOpen = 1
        if self.children == []
            call self.InitChildren(1)
        endif

        for i in self.children
            if i.path.isDirectory == 1
                call i.OpenRecursively2(0)
            endif
        endfor
    endif
endfunction

"FUNCTION: oTreeDirNode.Refresh {{{3
unlet s:oTreeDirNode.Refresh
function! s:oTreeDirNode.Refresh() dict
    call self.path.Refresh()

    "if this node was ever opened, refresh its children
    if self.isOpen || !empty(self.children)
        "go thru all the files/dirs under this node
        let newChildNodes = []
        let invalidFilesFound = 0
        let dir = self.path
        let filesStr = globpath(dir.StrForGlob(), '*') . "\n" . globpath(dir.StrForGlob(), '.*')
        let files = split(filesStr, "\n")
        for i in files
            if i !~ '\.\.$' && i !~ '\.$'

                try
                    "create a new path and see if it exists in this nodes children
                    let path = s:oPath.New(i)
                    let newNode = self.GetChild(path)
                    if newNode != {}
                        call newNode.Refresh()
                        call add(newChildNodes, newNode)

                    "the node doesnt exist so create it
                    else
                        let newNode = s:oTreeFileNode.New(path)
                        let newNode.parent = self
                        call add(newChildNodes, newNode)
                    endif


                catch /^NERDTree.InvalidArguments/
                    let invalidFilesFound = 1
                endtry
            endif
        endfor

        "swap this nodes children out for the children we just read/refreshed
        let self.children = newChildNodes
        call self.SortChildren()

        if invalidFilesFound
            call s:EchoWarning("some files could not be loaded into the NERD tree")
        endif
    endif
endfunction

"FUNCTION: oTreeDirNode.RemoveChild {{{3
"
"Removes the given treenode from this nodes set of children
"
"Args:
"treenode: the node to remove
"
"Throws a NERDTree.TreeDirNode exception if the given treenode is not found
function! s:oTreeDirNode.RemoveChild(treenode) dict
    for i in range(0, self.GetChildCount()-1)
        if self.children[i].Equals(a:treenode)
            call remove(self.children, i)
            return
        endif
    endfor

    throw "NERDTree.TreeDirNode exception: child node was not found"
endfunction

"FUNCTION: oTreeDirNode.SortChildren {{{3
"
"Sorts the children of this node according to alphabetical order and the
"directory priority.
"
function! s:oTreeDirNode.SortChildren() dict
    let CompareFunc = function("s:CompareNodes")
    call sort(self.children, CompareFunc)
endfunction

"FUNCTION: oTreeDirNode.ToggleOpen {{{3
"Opens this directory if it is closed and vice versa
function! s:oTreeDirNode.ToggleOpen() dict
    if self.isOpen == 1
        call self.Close()
    else
        call self.Open()
    endif
endfunction

"FUNCTION: oTreeDirNode.TransplantChild(newNode) {{{3
"Replaces the child of this with the given node (where the child node's full
"path matches a:newNode's fullpath). The search for the matching node is
"non-recursive
"
"Arg:
"newNode: the node to graft into the tree
function! s:oTreeDirNode.TransplantChild(newNode) dict
    for i in range(0, self.GetChildCount()-1)
        if self.children[i].Equals(a:newNode)
            let self.children[i] = a:newNode
            let a:newNode.parent = self
            break
        endif
    endfor
endfunction
"============================================================
"CLASS: oPath {{{2
"============================================================
let s:oPath = {}
"FUNCTION: oPath.BookmarkNames() {{{3
function! s:oPath.BookmarkNames() dict
    if !exists("self.bookmarkNames")
        call self.CacheDisplayString()
    endif
    return self.bookmarkNames
endfunction
"FUNCTION: oPath.CacheDisplayString() {{{3
function! s:oPath.CacheDisplayString() dict
    let self.cachedDisplayString = self.GetLastPathComponent(1)

    if self.isExecutable
        let self.cachedDisplayString = self.cachedDisplayString . '*'
    endif

    let self.bookmarkNames = []
    for i in s:oBookmark.Bookmarks()
        if i.path.Equals(self)
            call add(self.bookmarkNames, i.name)
        endif
    endfor
    if !empty(self.bookmarkNames)
        let self.cachedDisplayString .= ' {' . join(self.bookmarkNames) . '}'
    endif

    if self.isSymLink
        let self.cachedDisplayString .=  ' -> ' . self.symLinkDest
    endif

    if self.isReadOnly
        let self.cachedDisplayString .=  ' [RO]'
    endif
endfunction
"FUNCTION: oPath.ChangeToDir() {{{3
function! s:oPath.ChangeToDir() dict
    let dir = self.StrForCd()
    if self.isDirectory == 0
        let dir = self.GetPathTrunk().StrForCd()
    endif

    try
        execute "cd " . dir
        call s:Echo("CWD is now: " . getcwd())
    catch
        throw "NERDTree.Path.Change exception: cannot change to " . dir
    endtry
endfunction

"FUNCTION: oPath.ChopTrailingSlash(str) {{{3
function! s:oPath.ChopTrailingSlash(str) dict
    if a:str =~ '\/$'
        return substitute(a:str, "\/$", "", "")
    else
        return substitute(a:str, "\\$", "", "")
    endif
endfunction

"FUNCTION: oPath.CompareTo() {{{3
"
"Compares this oPath to the given path and returns 0 if they are equal, -1 if
"this oPath is "less than" the given path, or 1 if it is "greater".
"
"Args:
"path: the path object to compare this to
"
"Return:
"1, -1 or 0
function! s:oPath.CompareTo(path) dict
    let thisPath = self.GetLastPathComponent(1)
    let thatPath = a:path.GetLastPathComponent(1)

    "if the paths are the same then clearly we return 0
    if thisPath == thatPath
        return 0
    endif

    let thisSS = self.GetSortOrderIndex()
    let thatSS = a:path.GetSortOrderIndex()

    "compare the sort sequences, if they are different then the return
    "value is easy
    if thisSS < thatSS
        return -1
    elseif thisSS > thatSS
        return 1
    else
        "if the sort sequences are the same then compare the paths
        "alphabetically
        let pathCompare = g:NERDTreeCaseSensitiveSort ? thisPath <# thatPath : thisPath <? thatPath
        if pathCompare
            return -1
        else
            return 1
        endif
    endif
endfunction

"FUNCTION: oPath.Create(fullpath) {{{3
"
"Factory method.
"
"Creates a path object with the given path. The path is also created on the
"filesystem. If the path already exists, a NERDTree.Path.Exists exception is
"thrown. If any other errors occur, a NERDTree.Path exception is thrown.
"
"Args:
"fullpath: the full filesystem path to the file/dir to create
function! s:oPath.Create(fullpath) dict
    "bail if the a:fullpath already exists
    if isdirectory(a:fullpath) || filereadable(a:fullpath)
        throw "NERDTree.Path.Exists Exception: Directory Exists: '" . a:fullpath . "'"
    endif

    try

        "if it ends with a slash, assume its a dir create it
        if a:fullpath =~ '\(\\\|\/\)$'
            "whack the trailing slash off the end if it exists
            let fullpath = substitute(a:fullpath, '\(\\\|\/\)$', '', '')

            call mkdir(fullpath, 'p')

        "assume its a file and create
        else
            call writefile([], a:fullpath)
        endif
    catch /.*/
        throw "NERDTree.Path Exception: Could not create path: '" . a:fullpath . "'"
    endtry

    return s:oPath.New(a:fullpath)
endfunction

"FUNCTION: oPath.Copy(dest) {{{3
"
"Copies the file/dir represented by this Path to the given location
"
"Args:
"dest: the location to copy this dir/file to
function! s:oPath.Copy(dest) dict
    if !s:oPath.CopyingSupported()
        throw "NERDTree.Path.CopyingNotSupported Exception: Copying is not supported on this OS"
    endif

    let dest = s:oPath.WinToUnixPath(a:dest)

    let cmd = g:NERDTreeCopyCmd . " " . self.StrForOS(0) . " " . dest
    let success = system(cmd)
    if success != 0
        throw "NERDTree.Path Exception: Could not copy ''". self.StrForOS(0) ."'' to: '" . a:dest . "'"
    endif
endfunction

"FUNCTION: oPath.CopyingSupported() {{{3
"
"returns 1 if copying is supported for this OS
function! s:oPath.CopyingSupported() dict
    return exists('g:NERDTreeCopyCmd')
endfunction


"FUNCTION: oPath.CopyingWillOverwrite(dest) {{{3
"
"returns 1 if copy this path to the given location will cause files to
"overwritten
"
"Args:
"dest: the location this path will be copied to
function! s:oPath.CopyingWillOverwrite(dest) dict
    if filereadable(a:dest)
        return 1
    endif

    if isdirectory(a:dest)
        let path = s:oPath.JoinPathStrings(a:dest, self.GetLastPathComponent(0))
        if filereadable(path)
            return 1
        endif
    endif
endfunction

"FUNCTION: oPath.Delete() {{{3
"
"Deletes the file represented by this path.
"Deletion of directories is not supported
"
"Throws NERDTree.Path.Deletion exceptions
function! s:oPath.Delete() dict
    if self.isDirectory

        let cmd = ""
        if s:running_windows
            "if we are runnnig windows then put quotes around the pathstring
            let cmd = g:NERDTreeRemoveDirCmd . self.StrForOS(1)
        else
            let cmd = g:NERDTreeRemoveDirCmd . self.StrForOS(1)
        endif
        let success = system(cmd)

        if v:shell_error != 0
            throw "NERDTree.Path.Deletion Exception: Could not delete directory: '" . self.StrForOS(0) . "'"
        endif
    else
        let success = delete(self.StrForOS(0))
        if success != 0
            throw "NERDTree.Path.Deletion Exception: Could not delete file: '" . self.Str(0) . "'"
        endif
    endif

    "delete all bookmarks for this path
    for i in self.BookmarkNames()
        let bookmark = s:oBookmark.BookmarkFor(i)
        call bookmark.Delete()
    endfor
endfunction

"FUNCTION: oPath.ExtractDriveLetter(fullpath) {{{3
"
"If running windows, cache the drive letter for this path
function! s:oPath.ExtractDriveLetter(fullpath) dict
    if s:running_windows
        let self.drive = substitute(a:fullpath, '\(^[a-zA-Z]:\).*', '\1', '')
    else
        let self.drive = ''
    endif

endfunction
"FUNCTION: oPath.Exists() {{{3
"return 1 if this path points to a location that is readable or is a directory
function! s:oPath.Exists() dict
    return filereadable(self.StrForOS(0)) || isdirectory(self.StrForOS(0))
endfunction
"FUNCTION: oPath.GetDir() {{{3
"
"Returns this path if it is a directory, else this paths parent.
"
"Return:
"a Path object
function! s:oPath.GetDir() dict
    if self.isDirectory
        return self
    else
        return self.GetParent()
    endif
endfunction


"FUNCTION: oPath.GetParent() {{{3
"
"Returns a new path object for this paths parent
"
"Return:
"a new Path object
function! s:oPath.GetParent() dict
    let path = '/'. join(self.pathSegments[0:-2], '/')
    return s:oPath.New(path)
endfunction
"FUNCTION: oPath.GetLastPathComponent(dirSlash) {{{3
"
"Gets the last part of this path.
"
"Args:
"dirSlash: if 1 then a trailing slash will be added to the returned value for
"directory nodes.
function! s:oPath.GetLastPathComponent(dirSlash) dict
    if empty(self.pathSegments)
        return ''
    endif
    let toReturn = self.pathSegments[-1]
    if a:dirSlash && self.isDirectory
        let toReturn = toReturn . '/'
    endif
    return toReturn
endfunction

"FUNCTION: oPath.GetPathTrunk() {{{3
"Gets the path without the last segment on the end.
function! s:oPath.GetPathTrunk() dict
    return s:oPath.New(self.StrTrunk())
endfunction

"FUNCTION: oPath.GetSortOrderIndex() {{{3
"returns the index of the pattern in g:NERDTreeSortOrder that this path matches
function! s:oPath.GetSortOrderIndex() dict
    let i = 0
    while i < len(g:NERDTreeSortOrder)
        if  self.GetLastPathComponent(1) =~ g:NERDTreeSortOrder[i]
            return i
        endif
        let i = i + 1
    endwhile
    return s:NERDTreeSortStarIndex
endfunction

"FUNCTION: oPath.Ignore() {{{3
"returns true if this path should be ignored
function! s:oPath.Ignore() dict
    let lastPathComponent = self.GetLastPathComponent(0)

    "filter out the user specified paths to ignore
    if t:NERDTreeIgnoreEnabled
        for i in g:NERDTreeIgnore
            if lastPathComponent =~ i
                return 1
            endif
        endfor
    endif

    "dont show hidden files unless instructed to
    if t:NERDTreeShowHidden == 0 && lastPathComponent =~ '^\.'
        return 1
    endif

    if t:NERDTreeShowFiles == 0 && self.isDirectory == 0
        return 1
    endif

    return 0
endfunction

"FUNCTION: oPath.JoinPathStrings(...) {{{3
function! s:oPath.JoinPathStrings(...) dict
    let components = []
    for i in a:000
        let components = extend(components, split(i, '/'))
    endfor
    return '/' . join(components, '/')
endfunction

"FUNCTION: oPath.Equals() {{{3
"
"Determines whether 2 path objects are "equal".
"They are equal if the paths they represent are the same
"
"Args:
"path: the other path obj to compare this with
function! s:oPath.Equals(path) dict
    return self.Str(0) == a:path.Str(0)
endfunction

"FUNCTION: oPath.New() {{{3
"
"The Constructor for the Path object
"Throws NERDTree.Path.InvalidArguments exception.
function! s:oPath.New(fullpath) dict
    let newPath = copy(self)

    call newPath.ReadInfoFromDisk(a:fullpath)

    let newPath.cachedDisplayString = ""

    return newPath
endfunction

"FUNCTION: oPath.ReadInfoFromDisk(fullpath) {{{3
"
"
"Throws NERDTree.Path.InvalidArguments exception.
function! s:oPath.ReadInfoFromDisk(fullpath) dict
    call self.ExtractDriveLetter(a:fullpath)

    let fullpath = s:oPath.WinToUnixPath(a:fullpath)

    if getftype(fullpath) == "fifo"
        throw "NERDTree.Path.InvalidFiletype Exception: Cant handle FIFO files: " . a:fullpath
    endif

    let self.pathSegments = split(fullpath, '/')


    let self.isReadOnly = 0
    if isdirectory(a:fullpath)
        let self.isDirectory = 1
    elseif filereadable(a:fullpath)
        let self.isDirectory = 0
        let self.isReadOnly = filewritable(a:fullpath) == 0
    else
        throw "NERDTree.Path.InvalidArguments Exception: Invalid path = " . a:fullpath
    endif

    let self.isExecutable = 0
    if !self.isDirectory
        let self.isExecutable = getfperm(a:fullpath) =~ 'x'
    endif

    "grab the last part of the path (minus the trailing slash)
    let lastPathComponent = self.GetLastPathComponent(0)

    "get the path to the new node with the parent dir fully resolved
    let hardPath = resolve(self.StrTrunk()) . '/' . lastPathComponent

    "if  the last part of the path is a symlink then flag it as such
    let self.isSymLink = (resolve(hardPath) != hardPath)
    if self.isSymLink
        let self.symLinkDest = resolve(fullpath)

        "if the link is a dir then slap a / on the end of its dest
        if isdirectory(self.symLinkDest)

            "we always wanna treat MS windows shortcuts as files for
            "simplicity
            if hardPath !~ '\.lnk$'

                let self.symLinkDest = self.symLinkDest . '/'
            endif
        endif
    endif
endfunction

"FUNCTION: oPath.Refresh() {{{3
function! s:oPath.Refresh() dict
    call self.ReadInfoFromDisk(self.StrForOS(0))
    call self.CacheDisplayString()
endfunction

"FUNCTION: oPath.Rename() {{{3
"
"Renames this node on the filesystem
function! s:oPath.Rename(newPath) dict
    if a:newPath == ''
        throw "NERDTree.Path.InvalidArguments exception. Invalid newPath for renaming = ". a:newPath
    endif

    let success =  rename(self.StrForOS(0), a:newPath)
    if success != 0
        throw "NERDTree.Path.Rename Exception: Could not rename: '" . self.StrForOS(0) . "'" . 'to:' . a:newPath
    endif
    call self.ReadInfoFromDisk(a:newPath)

    for i in self.BookmarkNames()
        let b = s:oBookmark.BookmarkFor(i)
        call b.SetPath(copy(self))
    endfor
    call s:oBookmark.Write()
endfunction

"FUNCTION: oPath.Str(esc) {{{3
"
"Gets the actual string path that this obj represents.
"
"Args:
"esc: if 1 then all the tricky chars in the returned string will be escaped
function! s:oPath.Str(esc) dict
    let toReturn = '/' . join(self.pathSegments, '/')
    if self.isDirectory && toReturn != '/'
        let toReturn  = toReturn . '/'
    endif

    if a:esc
        let toReturn = escape(toReturn, s:escape_chars)
    endif
    return toReturn
endfunction

"FUNCTION: oPath.StrAbs() {{{3
"
"Returns a string representing this path with all the symlinks resolved
"
"Return:
"string
function! s:oPath.StrAbs() dict
    return resolve(self.Str(1))
endfunction

"FUNCTION: oPath.StrForCd() {{{3
"
" returns a string that can be used with :cd
"
"Return:
"a string that can be used in the view to represent this path
function! s:oPath.StrForCd() dict
    if s:running_windows
        return self.StrForOS(0)
    else
        return self.StrForOS(1)
    endif
endfunction
"FUNCTION: oPath.StrDisplay() {{{3
"
"Returns a string that specifies how the path should be represented as a
"string
"
"Return:
"a string that can be used in the view to represent this path
function! s:oPath.StrDisplay() dict
    if self.cachedDisplayString == ""
        call self.CacheDisplayString()
    endif

    return self.cachedDisplayString
endfunction

"FUNCTION: oPath.StrForEditCmd() {{{3
"
"Return: the string for this path that is suitable to be used with the :edit
"command
function! s:oPath.StrForEditCmd() dict
    if s:running_windows
        return self.StrForOS(0)
    else
        return self.Str(1)
    endif

endfunction
"FUNCTION: oPath.StrForGlob() {{{3
function! s:oPath.StrForGlob() dict
    let lead = s:os_slash

    "if we are running windows then slap a drive letter on the front
    if s:running_windows
        let lead = self.drive . '\'
    endif

    let toReturn = lead . join(self.pathSegments, s:os_slash)

    if !s:running_windows
        let toReturn = escape(toReturn, s:escape_chars)
    endif
    return toReturn
endfunction
"FUNCTION: oPath.StrForOS(esc) {{{3
"
"Gets the string path for this path object that is appropriate for the OS.
"EG, in windows c:\foo\bar
"    in *nix  /foo/bar
"
"Args:
"esc: if 1 then all the tricky chars in the returned string will be
" escaped. If we are running windows then the str is double quoted instead.
function! s:oPath.StrForOS(esc) dict
    let lead = s:os_slash

    "if we are running windows then slap a drive letter on the front
    if s:running_windows
        let lead = self.drive . '\'
    endif

    let toReturn = lead . join(self.pathSegments, s:os_slash)

    if a:esc
        if s:running_windows
            let toReturn = '"' .  toReturn . '"'
        else
            let toReturn = escape(toReturn, s:escape_chars)
        endif
    endif
    return toReturn
endfunction

"FUNCTION: oPath.StrTrunk() {{{3
"Gets the path without the last segment on the end.
function! s:oPath.StrTrunk() dict
    return self.drive . '/' . join(self.pathSegments[0:-2], '/')
endfunction

"FUNCTION: oPath.WinToUnixPath(pathstr){{{3
"Takes in a windows path and returns the unix equiv
"
"A class level method
"
"Args:
"pathstr: the windows path to convert
function! s:oPath.WinToUnixPath(pathstr) dict
    if !s:running_windows
        return a:pathstr
    endif

    let toReturn = a:pathstr

    "remove the x:\ of the front
    let toReturn = substitute(toReturn, '^.*:\(\\\|/\)\?', '/', "")

    "convert all \ chars to /
    let toReturn = substitute(toReturn, '\', '/', "g")

    return toReturn
endfunction

" SECTION: General Functions {{{1
"============================================================
"FUNCTION: s:Abs(num){{{2
"returns the absolute value of the input
function! s:Abs(num)
    if a:num > 0
        return a:num
    else
        return 0 - a:num
    end
endfunction
"FUNCTION: s:AbsoluteTreeRoot(){{{2
" returns the highest cached ancestor of the current root
function! s:AbsoluteTreeRoot()
    let currentNode = t:NERDTreeRoot
    while currentNode.parent != {}
        let currentNode = currentNode.parent
    endwhile
    return currentNode
endfunction
"FUNCTION: s:BufInWindows(bnum){{{2
"[[STOLEN FROM VTREEEXPLORER.VIM]]
"Determine the number of windows open to this buffer number.
"Care of Yegappan Lakshman.  Thanks!
"
"Args:
"bnum: the subject buffers buffer number
function! s:BufInWindows(bnum)
    let cnt = 0
    let winnum = 1
    while 1
        let bufnum = winbufnr(winnum)
        if bufnum < 0
            break
        endif
        if bufnum == a:bnum
            let cnt = cnt + 1
        endif
        let winnum = winnum + 1
    endwhile

    return cnt
endfunction " >>>

"FUNCTION: CompareBookmarks(first, second) {{{2
"Compares two bookmarks
function! s:CompareBookmarks(first, second)
    return a:first.CompareTo(a:second)
endfunction

" FUNCTION: s:CompleteBookmarks(A,L,P) {{{2
" completion function for the bookmark commands
function! s:CompleteBookmarks(A,L,P)
    return filter(s:oBookmark.BookmarkNames(), 'v:val =~ "^' . a:A . '"')
endfunction
"FUNCTION: s:InitNerdTree(name) {{{2
"Initialise the nerd tree for this tab. The tree will start in either the
"given directory, or the directory associated with the given bookmark
"
"Args:
"name: the name of a bookmark or a directory
function! s:InitNerdTree(name)
    let path = {}
    if s:oBookmark.BookmarkExistsFor(a:name)
        let path = s:oBookmark.BookmarkFor(a:name).path
    else
        let dir = a:name == '' ? expand('%:p:h') : a:name
        let dir = resolve(dir)
        try
            let path = s:oPath.New(dir)
        catch /NERDTree.Path.InvalidArguments/
            call s:Echo("No bookmark or directory found for: " . a:name)
            return
        endtry
    endif
    if !path.isDirectory
        let path = path.GetParent()
    endif

    "if instructed to, then change the vim CWD to the dir the NERDTree is
    "inited in
    if g:NERDTreeChDirMode != 0
        exec 'cd ' . path.StrForCd()
    endif

    let t:treeShowHelp = 0
    let t:NERDTreeIgnoreEnabled = 1
    let t:NERDTreeShowFiles = g:NERDTreeShowFiles
    let t:NERDTreeShowHidden = g:NERDTreeShowHidden
    let t:NERDTreeShowBookmarks = g:NERDTreeShowBookmarks

    if s:TreeExistsForTab()
        if s:IsTreeOpen()
            call s:CloseTree()
        endif
        unlet t:NERDTreeRoot
    endif

    let t:NERDTreeRoot = s:oTreeDirNode.New(path)
    call t:NERDTreeRoot.Open()

    call s:CreateTreeWin()
    call s:RenderView()
    call s:PutCursorOnNode(t:NERDTreeRoot, 0, 0)
endfunction
" Function: s:TreeExistsForTab()   {{{2
" Returns 1 if a nerd tree root exists in the current tab
function! s:TreeExistsForTab()
    return exists("t:NERDTreeRoot")
endfunction
" SECTION: Public Functions {{{1
"============================================================
"Returns the node that the cursor is currently on.
"
"If the cursor is not in the NERDTree window, it is temporarily put there.
"
"If no NERD tree window exists for the current tab, a NERDTree.NoTreeForTab
"exception is thrown.
"
"If the cursor is not on a node then an empty dictionary {} is returned.
function! NERDTreeGetCurrentNode()
    if !s:TreeExistsForTab() || !s:IsTreeOpen()
        throw "NERDTree.NoTreeForTab exception: there is no NERD tree open for the current tab"
    endif

    let winnr = winnr()
    if winnr != s:GetTreeWinNum()
        call s:PutCursorInTreeWin()
    endif

    let treenode = s:GetSelectedNode()

    if winnr != winnr()
        wincmd w
    endif

    return treenode
endfunction

"Returns the path object for the current node.
"
"Subject to the same conditions as NERDTreeGetCurrentNode
function! NERDTreeGetCurrentPath()
    let node = NERDTreeGetCurrentNode()
    if node != {}
        return node.path
    else
        return {}
    endif
endfunction

" SECTION: View Functions {{{1
"============================================================
" FUNCTION: s:BookmarkToRoot(name) {{{2
" Make the node for the given bookmark the new tree root
function! s:BookmarkToRoot(name)
    let bookmark = s:oBookmark.BookmarkFor(a:name)
    if s:ValidateBookmark(bookmark)
        try
            let targetNode = s:oBookmark.GetNodeForName(a:name, 1)
        catch /NERDTree.BookmarkedNodeNotFound/
            let targetNode = s:oTreeFileNode.New(s:oBookmark.BookmarkFor(a:name).path)
        endtry
        call targetNode.MakeRoot()
        call s:RenderView()
        call s:PutCursorOnNode(targetNode, 0, 0)
    endif
endfunction
"FUNCTION: s:CenterView() {{{2
"centers the nerd tree window around the cursor (provided the nerd tree
"options permit)
function! s:CenterView()
    if g:NERDTreeAutoCenter
        let current_line = winline()
        let lines_to_top = current_line
        let lines_to_bottom = winheight(s:GetTreeWinNum()) - current_line
        if lines_to_top < g:NERDTreeAutoCenterThreshold || lines_to_bottom < g:NERDTreeAutoCenterThreshold
            normal! zz
        endif
    endif
endfunction
"FUNCTION: s:CloseTree() {{{2
"Closes the NERD tree window
function! s:CloseTree()
    if !s:IsTreeOpen()
        throw "NERDTree.view.CloseTree exception: no NERDTree is open"
    endif

    if winnr("$") != 1
        execute s:GetTreeWinNum() . " wincmd w"
        close
        execute "wincmd p"
    else
        :q
    endif
endfunction

"FUNCTION: s:CloseTreeIfOpen() {{{2
"Closes the NERD tree window if it is open
function! s:CloseTreeIfOpen()
   if s:IsTreeOpen()
      call s:CloseTree()
   endif
endfunction
"FUNCTION: s:CloseTreeIfQuitOnOpen() {{{2
"Closes the NERD tree window if the close on open option is set
function! s:CloseTreeIfQuitOnOpen()
    if g:NERDTreeQuitOnOpen
        call s:CloseTree()
    endif
endfunction
"FUNCTION: s:CreateTreeWin() {{{2
"Inits the NERD tree window. ie. opens it, sizes it, sets all the local
"options etc
function! s:CreateTreeWin()
    "create the nerd tree window
    let splitLocation = (g:NERDTreeWinPos == "top" || g:NERDTreeWinPos == "left") ? "topleft " : "botright "
    let splitMode = s:ShouldSplitVertically() ? "vertical " : ""
    let splitSize = g:NERDTreeWinSize
    let t:NERDTreeWinName = localtime() . s:NERDTreeWinName
    let cmd = splitLocation . splitMode . splitSize . ' new ' . t:NERDTreeWinName
    silent! execute cmd

    setlocal winfixwidth

    "throwaway buffer options
    setlocal noswapfile
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal nowrap
    setlocal foldcolumn=0
    setlocal nobuflisted
    setlocal nospell
    if g:NERDTreeShowLineNumbers
        setlocal nu
    else
        setlocal nonu
    endif

    iabc <buffer>

    if g:NERDTreeHighlightCursorline
        setlocal cursorline
    endif


    " for line continuation
    let cpo_save1 = &cpo
    set cpo&vim

    call s:BindMappings()
    setfiletype nerdtree
    " syntax highlighting
    if has("syntax") && exists("g:syntax_on") && !has("syntax_items")
        call s:SetupSyntaxHighlighting()
    endif
endfunction

"FUNCTION: s:DrawTree {{{2
"Draws the given node recursively
"
"Args:
"curNode: the node that is being rendered with this call
"depth: the current depth in the tree for this call
"drawText: 1 if we should actually draw the line for this node (if 0 then the
"child nodes are rendered only)
"vertMap: a binary array that indicates whether a vertical bar should be draw
"for each depth in the tree
"isLastChild:true if this curNode is the last child of its parent
function! s:DrawTree(curNode, depth, drawText, vertMap, isLastChild)
    if a:drawText == 1

        let treeParts = ''

        "get all the leading spaces and vertical tree parts for this line
        if a:depth > 1
            for j in a:vertMap[0:-2]
                if j == 1
                    let treeParts = treeParts . '| '
                else
                    let treeParts = treeParts . '  '
                endif
            endfor
        endif

        "get the last vertical tree part for this line which will be different
        "if this node is the last child of its parent
        if a:isLastChild
            let treeParts = treeParts . '`'
        else
            let treeParts = treeParts . '|'
        endif


        "smack the appropriate dir/file symbol on the line before the file/dir
        "name itself
        if a:curNode.path.isDirectory
            if a:curNode.isOpen
                let treeParts = treeParts . '~'
            else
                let treeParts = treeParts . '+'
            endif
        else
            let treeParts = treeParts . '-'
        endif
        let line = treeParts . a:curNode.StrDisplay()

        call setline(line(".")+1, line)
        call cursor(line(".")+1, col("."))
    endif

    "if the node is an open dir, draw its children
    if a:curNode.path.isDirectory == 1 && a:curNode.isOpen == 1

        let childNodesToDraw = a:curNode.GetVisibleChildren()
        if len(childNodesToDraw) > 0

            "draw all the nodes children except the last
            let lastIndx = len(childNodesToDraw)-1
            if lastIndx > 0
                for i in childNodesToDraw[0:lastIndx-1]
                    call s:DrawTree(i, a:depth + 1, 1, add(copy(a:vertMap), 1), 0)
                endfor
            endif

            "draw the last child, indicating that it IS the last
            call s:DrawTree(childNodesToDraw[lastIndx], a:depth + 1, 1, add(copy(a:vertMap), 0), 1)
        endif
    endif
endfunction


"FUNCTION: s:DumpHelp  {{{2
"prints out the quick help
function! s:DumpHelp()
    let old_h = @h
    if t:treeShowHelp == 1
        let @h=   "\" NERD tree (" . s:NERD_tree_version . ") quickhelp~\n"
        let @h=@h."\" ============================\n"
        let @h=@h."\" File node mappings~\n"
        let @h=@h."\" ". (g:NERDTreeMouseMode == 3 ? "single" : "double") ."-click,\n"
        let @h=@h."\" ". g:NERDTreeMapActivateNode .": open in prev window\n"
        let @h=@h."\" ". g:NERDTreeMapPreview .": preview\n"
        let @h=@h."\" ". g:NERDTreeMapOpenInTab.": open in new tab\n"
        let @h=@h."\" ". g:NERDTreeMapOpenInTabSilent .": open in new tab silently\n"
        let @h=@h."\" middle-click,\n"
        let @h=@h."\" ". g:NERDTreeMapOpenSplit .": open split\n"
        let @h=@h."\" ". g:NERDTreeMapPreviewSplit .": preview split\n"
        let @h=@h."\" ". g:NERDTreeMapExecute.": Execute file\n"

        let @h=@h."\"\n\" ----------------------------\n"
        let @h=@h."\" Directory node mappings~\n"
        let @h=@h."\" ". (g:NERDTreeMouseMode == 1 ? "double" : "single") ."-click,\n"
        let @h=@h."\" ". g:NERDTreeMapActivateNode .": open & close node\n"
        let @h=@h."\" ". g:NERDTreeMapOpenRecursively .": recursively open node\n"
        let @h=@h."\" ". g:NERDTreeMapCloseDir .": close parent of node\n"
        let @h=@h."\" ". g:NERDTreeMapCloseChildren .": close all child nodes of\n"
        let @h=@h."\"    current node recursively\n"
        let @h=@h."\" middle-click,\n"
        let @h=@h."\" ". g:NERDTreeMapOpenExpl.": Open netrw for selected\n"
        let @h=@h."\"    node\n"

        let @h=@h."\"\n\" ----------------------------\n"
        let @h=@h."\" Bookmark table mappings~\n"
        let @h=@h."\" double-click,\n"
        let @h=@h."\" ". g:NERDTreeMapActivateNode .": open bookmark\n"
        let @h=@h."\" ". g:NERDTreeMapOpenInTab.": open in new tab\n"
        let @h=@h."\" ". g:NERDTreeMapOpenInTabSilent .": open in new tab silently\n"

        let @h=@h."\"\n\" ----------------------------\n"
        let @h=@h."\" Tree navigation mappings~\n"
        let @h=@h."\" ". g:NERDTreeMapJumpRoot .": go to root\n"
        let @h=@h."\" ". g:NERDTreeMapJumpParent .": go to parent\n"
        let @h=@h."\" ". g:NERDTreeMapJumpFirstChild  .": go to first child\n"
        let @h=@h."\" ". g:NERDTreeMapJumpLastChild   .": go to last child\n"
        let @h=@h."\" ". g:NERDTreeMapJumpNextSibling .": go to next sibling\n"
        let @h=@h."\" ". g:NERDTreeMapJumpPrevSibling .": go to prev sibling\n"

        let @h=@h."\"\n\" ----------------------------\n"
        let @h=@h."\" Filesystem mappings~\n"
        let @h=@h."\" ". g:NERDTreeMapChangeRoot .": change tree root to the\n"
        let @h=@h."\"    selected dir\n"
        let @h=@h."\" ". g:NERDTreeMapUpdir .": move tree root up a dir\n"
        let @h=@h."\" ". g:NERDTreeMapUpdirKeepOpen .": move tree root up a dir\n"
        let @h=@h."\"    but leave old root open\n"
        let @h=@h."\" ". g:NERDTreeMapRefresh .": refresh cursor dir\n"
        let @h=@h."\" ". g:NERDTreeMapRefreshRoot .": refresh current root\n"
        let @h=@h."\" ". g:NERDTreeMapFilesystemMenu .": Show filesystem menu\n"
        let @h=@h."\" ". g:NERDTreeMapChdir .":change the CWD to the\n"
        let @h=@h."\"    selected dir\n"

        let @h=@h."\"\n\" ----------------------------\n"
        let @h=@h."\" Tree filtering mappings~\n"
        let @h=@h."\" ". g:NERDTreeMapToggleHidden .": hidden files (" . (t:NERDTreeShowHidden ? "on" : "off") . ")\n"
        let @h=@h."\" ". g:NERDTreeMapToggleFilters .": file filters (" . (t:NERDTreeIgnoreEnabled ? "on" : "off") . ")\n"
        let @h=@h."\" ". g:NERDTreeMapToggleFiles .": files (" . (t:NERDTreeShowFiles ? "on" : "off") . ")\n"
        let @h=@h."\" ". g:NERDTreeMapToggleBookmarks .": bookmarks (" . (t:NERDTreeShowBookmarks ? "on" : "off") . ")\n"

        let @h=@h."\"\n\" ----------------------------\n"
        let @h=@h."\" Other mappings~\n"
        let @h=@h."\" ". g:NERDTreeMapQuit .": Close the NERDTree window\n"
        let @h=@h."\" ". g:NERDTreeMapHelp .": toggle help\n"
        let @h=@h."\"\n\" ----------------------------\n"
        let @h=@h."\" Bookmark commands~\n"
        let @h=@h."\" :Bookmark <name>\n"
        let @h=@h."\" :BookmarkToRoot <name>\n"
        let @h=@h."\" :RevealBookmark <name>\n"
        let @h=@h."\" :OpenBookmark <name>\n"
        let @h=@h."\" :ClearBookmarks [<names>]\n"
        let @h=@h."\" :ClearAllBookmarks\n"
    else
        let @h="\" Press ". g:NERDTreeMapHelp ." for help\n"
    endif

    silent! put h

    let @h = old_h
endfunction
"FUNCTION: s:Echo  {{{2
"A wrapper for :echo. Appends 'NERDTree:' on the front of all messages
"
"Args:
"msg: the message to echo
function! s:Echo(msg)
    redraw
    echomsg "NERDTree: " . a:msg
endfunction
"FUNCTION: s:EchoWarning {{{2
"Wrapper for s:Echo, sets the message type to warningmsg for this message
"Args:
"msg: the message to echo
function! s:EchoWarning(msg)
    echohl warningmsg
    call s:Echo(a:msg)
    echohl normal
endfunction
"FUNCTION: s:EchoError {{{2
"Wrapper for s:Echo, sets the message type to errormsg for this message
"Args:
"msg: the message to echo
function! s:EchoError(msg)
    echohl errormsg
    call s:Echo(a:msg)
    echohl normal
endfunction
"FUNCTION: s:FindNodeLineNumber(treenode){{{2
"Finds the line number for the given tree node
"
"Args:
"treenode: the node to find the line no. for
function! s:FindNodeLineNumber(treenode)
    "if the node is the root then return the root line no.
    if a:treenode.IsRoot()
        return s:FindRootNodeLineNumber()
    endif

    let totalLines = line("$")

    "the path components we have matched so far
    let pathcomponents = [substitute(t:NERDTreeRoot.path.Str(0), '/ *$', '', '')]
    "the index of the component we are searching for
    let curPathComponent = 1

    let fullpath = a:treenode.path.Str(0)


    let lnum = s:FindRootNodeLineNumber()
    while lnum > 0
        let lnum = lnum + 1
        "have we reached the bottom of the tree?
        if lnum == totalLines+1
            return -1
        endif

        let curLine = getline(lnum)

        let indent = match(curLine,s:tree_markup_reg_neg) / s:tree_wid
        if indent == curPathComponent
            let curLine = s:StripMarkupFromLine(curLine, 1)

            let curPath =  join(pathcomponents, '/') . '/' . curLine
            if stridx(fullpath, curPath, 0) == 0
                if fullpath == curPath || strpart(fullpath, len(curPath)-1,1) == '/'
                    let curLine = substitute(curLine, '/ *$', '', '')
                    call add(pathcomponents, curLine)
                    let curPathComponent = curPathComponent + 1

                    if fullpath == curPath
                        return lnum
                    endif
                endif
            endif
        endif
    endwhile
    return -1
endfunction

"FUNCTION: s:FindRootNodeLineNumber(){{{2
"Finds the line number of the root node
function! s:FindRootNodeLineNumber()
    let rootLine = 1
    while getline(rootLine) !~ '^/'
        let rootLine = rootLine + 1
    endwhile
    return rootLine
endfunction

"FUNCTION: s:GetPath(ln) {{{2
"Gets the full path to the node that is rendered on the given line number
"
"Args:
"ln: the line number to get the path for
"
"Return:
"A path if a node was selected, {} if nothing is selected.
"If the 'up a dir' line was selected then the path to the parent of the
"current root is returned
function! s:GetPath(ln)
    let line = getline(a:ln)

    "check to see if we have the root node
    if line =~ '^\/'
        return t:NERDTreeRoot.path
    endif

    " in case called from outside the tree
    if line !~ '^ *[|`]' || line =~ '^$'
        return {}
    endif

    if line == s:tree_up_dir_line
        return t:NERDTreeRoot.path.GetParent()
    endif

    "get the indent level for the file (i.e. how deep in the tree it is)
    let indent = match(line, s:tree_markup_reg_neg) / s:tree_wid


    "remove the tree parts and the leading space
    let curFile = s:StripMarkupFromLine(line, 0)

    let wasdir = 0
    if curFile =~ '/$'
        let wasdir = 1
        let curFile = substitute(curFile, '/\?$', '/', "")
    endif


    let dir = ""
    let lnum = a:ln
    while lnum > 0
        let lnum = lnum - 1
        let curLine = getline(lnum)
        let curLineStripped = s:StripMarkupFromLine(curLine, 1)

        "have we reached the top of the tree?
        if curLine =~ '^/'
            let dir = substitute (curLine, ' *$', "", "") . dir
            break
        endif
        if curLineStripped =~ '/$'
            let lpindent = match(curLine,s:tree_markup_reg_neg) / s:tree_wid
            if lpindent < indent
                let indent = indent - 1

                let dir = substitute (curLineStripped,'^\\', "", "") . dir
                continue
            endif
        endif
    endwhile
    let curFile = t:NERDTreeRoot.path.drive . dir . curFile
    let toReturn = s:oPath.New(curFile)
    return toReturn
endfunction

"FUNCTION: s:GetSelectedBookmark() {{{2
"Returns the current node if it is a dir node, or else returns the current
"nodes parent
function! s:GetSelectedBookmark()
    let line = getline(".")
    let name = substitute(line, '^>\(.\{-}\) \[.*\]$', '\1', '')
    if name != line
        try
            return s:oBookmark.BookmarkFor(name)
        catch /NERDTree.BookmarkNotFound/
            return {}
        endtry
    endif
endfunction

"FUNCTION: s:GetSelectedDir() {{{2
"Returns the current node if it is a dir node, or else returns the current
"nodes parent
function! s:GetSelectedDir()
    let currentDir = s:GetSelectedNode()
    if currentDir != {} && !currentDir.IsRoot()
        if currentDir.path.isDirectory == 0
            let currentDir = currentDir.parent
        endif
    endif
    return currentDir
endfunction
"FUNCTION: s:GetSelectedNode() {{{2
"gets the treenode that the cursor is currently over
function! s:GetSelectedNode()
    try
        let path = s:GetPath(line("."))
        if path == {}
            return {}
        endif
        return t:NERDTreeRoot.FindNode(path)
    catch /^NERDTree/
        return {}
    endtry
endfunction
"FUNCTION: s:GetTreeBufNum() {{{2
"gets the nerd tree buffer number for this tab
function! s:GetTreeBufNum()
    if exists("t:NERDTreeWinName")
        return bufnr(t:NERDTreeWinName)
    else
        return -1
    endif
endfunction
"FUNCTION: s:GetTreeWinNum() {{{2
"gets the nerd tree window number for this tab
function! s:GetTreeWinNum()
    if exists("t:NERDTreeWinName")
        return bufwinnr(t:NERDTreeWinName)
    else
        return -1
    endif
endfunction

"FUNCTION: s:IsTreeOpen() {{{2
function! s:IsTreeOpen()
    return s:GetTreeWinNum() != -1
endfunction

" FUNCTION: s:JumpToChild(direction) {{{2
" Args:
" direction: 0 if going to first child, 1 if going to last
function! s:JumpToChild(direction)
    let currentNode = s:GetSelectedNode()
    if currentNode == {} || currentNode.IsRoot()
        call s:Echo("cannot jump to " . (a:direction ? "last" : "first") .  " child")
        return
    end
    let dirNode = currentNode.parent
    let childNodes = dirNode.GetVisibleChildren()

    let targetNode = childNodes[0]
    if a:direction
        let targetNode = childNodes[len(childNodes) - 1]
    endif

    if targetNode.Equals(currentNode)
        let siblingDir = currentNode.parent.FindOpenDirSiblingWithChildren(a:direction)
        if siblingDir != {}
            let indx = a:direction ? siblingDir.GetVisibleChildCount()-1 : 0
            let targetNode = siblingDir.GetChildByIndex(indx, 1)
        endif
    endif

    call s:PutCursorOnNode(targetNode, 1, 0)

    call s:CenterView()
endfunction


"FUNCTION: s:OpenDirNodeSplit(treenode) {{{2
"Open the file represented by the given node in a new window.
"No action is taken for file nodes
"
"ARGS:
"treenode: file node to open
function! s:OpenDirNodeSplit(treenode)
    if a:treenode.path.isDirectory == 1
        call s:OpenNodeSplit(a:treenode)
    endif
endfunction

" FUNCTION: s:OpenExplorerFor(treenode) {{{2
" opens a netrw window for the given dir treenode
function! s:OpenExplorerFor(treenode)
    let oldwin = winnr()
    wincmd p
    if oldwin == winnr() || (&modified && s:BufInWindows(winbufnr(winnr())) < 2)
        wincmd p
        call s:OpenDirNodeSplit(a:treenode)
    else
        exec ("silent edit " . a:treenode.path.StrForEditCmd())
    endif
endfunction
"FUNCTION: s:OpenFileNode(treenode) {{{2
"Open the file represented by the given node in the current window, splitting
"the window if needed
"
"ARGS:
"treenode: file node to open
function! s:OpenFileNode(treenode)
    call s:PutCursorInTreeWin()

    "if the file is already open in this tab then just stick the cursor in it
    let winnr = bufwinnr('^' . a:treenode.path.StrForOS(0) . '$')
    if winnr != -1
        exec winnr . "wincmd w"

    elseif s:ShouldSplitToOpen(winnr("#"))
        call s:OpenFileNodeSplit(a:treenode)
    else
        try
            wincmd p
            exec ("edit " . a:treenode.path.StrForEditCmd())
        catch /^Vim\%((\a\+)\)\=:E37/
            call s:PutCursorInTreeWin()
            call s:Echo("Cannot open file, it is already open and modified")
        catch /^Vim\%((\a\+)\)\=:/
            echo v:exception
        endtry
    endif
endfunction

"FUNCTION: s:OpenFileNodeSplit(treenode) {{{2
"Open the file represented by the given node in a new window.
"No action is taken for dir nodes
"
"ARGS:
"treenode: file node to open
function! s:OpenFileNodeSplit(treenode)
    if a:treenode.path.isDirectory == 0
        try
            call s:OpenNodeSplit(a:treenode)
        catch /^NERDTree.view.FileOpen/
            call s:Echo("Cannot open file, it is already open and modified" )
        endtry
    endif
endfunction

"FUNCTION: s:OpenNodeSplit(treenode) {{{2
"Open the file/dir represented by the given node in a new window
"
"ARGS:
"treenode: file node to open
function! s:OpenNodeSplit(treenode)
    call s:PutCursorInTreeWin()

    " Save the user's settings for splitbelow and splitright
    let savesplitbelow=&splitbelow
    let savesplitright=&splitright

    " Figure out how to do the split based on the user's preferences.
    " We want to split to the (left,right,top,bottom) of the explorer
    " window, but we want to extract the screen real-estate from the
    " window next to the explorer if possible.
    "
    " 'there' will be set to a command to move from the split window
    " back to the explorer window
    "
    " 'back' will be set to a command to move from the explorer window
    " back to the newly split window
    "
    " 'right' and 'below' will be set to the settings needed for
    " splitbelow and splitright IF the explorer is the only window.
    "
    if s:ShouldSplitVertically()
        let there= g:NERDTreeWinPos == "left" ? "wincmd h" : "wincmd l"
        let back = g:NERDTreeWinPos == "left" ? "wincmd l" : "wincmd h"
        let right= g:NERDTreeWinPos == "left"
        let below=0
    else
        let there= g:NERDTreeWinPos == "top" ? "wincmd k" : "wincmd j"
        let back = g:NERDTreeWinPos == "top" ? "wincmd j" : "wincmd k"
        let below= g:NERDTreeWinPos == "top"
        let right=0
    endif

    " Attempt to go to adjacent window
    exec(back)

    let onlyOneWin = (winnr() == s:GetTreeWinNum())

    " If no adjacent window, set splitright and splitbelow appropriately
    if onlyOneWin
        let &splitright=right
        let &splitbelow=below
    else
        " found adjacent window - invert split direction
        let &splitright=!right
        let &splitbelow=!below
    endif

    " Create a variable to use if splitting vertically
    let splitMode = ""
    if (onlyOneWin && s:ShouldSplitVertically()) || (!onlyOneWin && !s:ShouldSplitVertically())
        let splitMode = "vertical"
    endif

    echomsg splitMode

    " Open the new window
    try
        exec(splitMode." sp " . a:treenode.path.StrForEditCmd())
    catch /^Vim\%((\a\+)\)\=:E37/
        call s:PutCursorInTreeWin()
        throw "NERDTree.view.FileOpen exception: ". a:treenode.path.Str(0) ." is already open and modified."
    catch /^Vim\%((\a\+)\)\=:/
        "do nothing
    endtry

    "resize the tree window if no other window was open before
    if onlyOneWin
        let size = exists("t:NERDTreeOldWindowSize") ? t:NERDTreeOldWindowSize : g:NERDTreeWinSize
        exec(there)
        exec("silent ". splitMode ." resize ". size)
        wincmd p
    endif

    " Restore splitmode settings
    let &splitbelow=savesplitbelow
    let &splitright=savesplitright
endfunction

"FUNCTION: s:PromptToDelBuffer(bufnum, msg){{{2
"prints out the given msg and, if the user responds by pushing 'y' then the
"buffer with the given bufnum is deleted
"
"Args:
"bufnum: the buffer that may be deleted
"msg: a message that will be echoed to the user asking them if they wish to
"     del the buffer
function! s:PromptToDelBuffer(bufnum, msg)
    echo a:msg
    if nr2char(getchar()) == 'y'
        exec "silent bdelete! " . a:bufnum
    endif
endfunction

"FUNCTION: s:PutCursorOnBookmarkTable(){{{2
"Places the cursor at the top of the bookmarks table
function! s:PutCursorOnBookmarkTable()
    if !t:NERDTreeShowBookmarks
        throw "NERDTree.IllegalOperation exception: cant find bookmark table, bookmarks arent active"
    endif

    let rootNodeLine = s:FindRootNodeLineNumber()

    let line = 1
    while getline(line) !~ '^>-\+Bookmarks-\+$'
        let line = line + 1
        if line >= rootNodeLine
            throw "NERDTree.BookmarkTableNotFound exception: didnt find the bookmarks table"
        endif
    endwhile
    call cursor(line, 0)
endfunction

"FUNCTION: s:PutCursorOnNode(treenode, isJump, recurseUpward){{{2
"Places the cursor on the line number representing the given node
"
"Args:
"treenode: the node to put the cursor on
"isJump: 1 if this cursor movement should be counted as a jump by vim
"recurseUpward: try to put the cursor on the parent if the this node isnt
"visible
function! s:PutCursorOnNode(treenode, isJump, recurseUpward)
    let ln = s:FindNodeLineNumber(a:treenode)
    if ln != -1
        if a:isJump
            mark '
        endif
        call cursor(ln, col("."))
    else
        if a:recurseUpward
            let node = a:treenode
            while s:FindNodeLineNumber(node) == -1 && node != {}
                let node = node.parent
                call node.Open()
            endwhile
            call s:RenderView()
            call s:PutCursorOnNode(a:treenode, a:isJump, 0)
        endif
    endif
endfunction

"FUNCTION: s:PutCursorInTreeWin(){{{2
"Places the cursor in the nerd tree window
function! s:PutCursorInTreeWin()
    if !s:IsTreeOpen()
        throw "NERDTree.view.InvalidOperation Exception: No NERD tree window exists"
    endif

    exec s:GetTreeWinNum() . "wincmd w"
endfunction

"FUNCTION: s:RenderBookmarks {{{2
function! s:RenderBookmarks()

    call setline(line(".")+1, ">----------Bookmarks----------")
    call cursor(line(".")+1, col("."))

    for i in s:oBookmark.Bookmarks()
        call setline(line(".")+1, i.Str())
        call cursor(line(".")+1, col("."))
    endfor

    call setline(line(".")+1, '')
    call cursor(line(".")+1, col("."))
endfunction
"FUNCTION: s:RenderView {{{2
"The entry function for rendering the tree. Renders the root then calls
"s:DrawTree to draw the children of the root
"
"Args:
function! s:RenderView()
    execute s:GetTreeWinNum() . "wincmd w"

    setlocal modifiable

    "remember the top line of the buffer and the current line so we can
    "restore the view exactly how it was
    let curLine = line(".")
    let curCol = col(".")
    let topLine = line("w0")

    "delete all lines in the buffer (being careful not to clobber a register)
    silent 1,$delete _

    call s:DumpHelp()

    "delete the blank line before the help and add one after it
    call setline(line(".")+1, "")
    call cursor(line(".")+1, col("."))

    if t:NERDTreeShowBookmarks
        call s:RenderBookmarks()
    endif

    "add the 'up a dir' line
    call setline(line(".")+1, s:tree_up_dir_line)
    call cursor(line(".")+1, col("."))

    "draw the header line
    call setline(line(".")+1, t:NERDTreeRoot.path.Str(0))
    call cursor(line(".")+1, col("."))

    "draw the tree
    call s:DrawTree(t:NERDTreeRoot, 0, 0, [], t:NERDTreeRoot.GetChildCount() == 1)

    "delete the blank line at the top of the buffer
    silent 1,1delete _

    "restore the view
    let old_scrolloff=&scrolloff
    let &scrolloff=0
    call cursor(topLine, 1)
    normal! zt
    call cursor(curLine, curCol)
    let &scrolloff = old_scrolloff

    setlocal nomodifiable
endfunction

"FUNCTION: s:RenderViewSavingPosition {{{2
"Renders the tree and ensures the cursor stays on the current node or the
"current nodes parent if it is no longer available upon re-rendering
function! s:RenderViewSavingPosition()
    let currentNode = s:GetSelectedNode()

    "go up the tree till we find a node that will be visible or till we run
    "out of nodes
    while currentNode != {} && !currentNode.IsVisible() && !currentNode.IsRoot()
        let currentNode = currentNode.parent
    endwhile

    call s:RenderView()

    if currentNode != {}
        call s:PutCursorOnNode(currentNode, 0, 0)
    endif
endfunction
"FUNCTION: s:RestoreScreenState() {{{2
"
"Sets the screen state back to what it was when s:SaveScreenState was last
"called.
"
"Assumes the cursor is in the NERDTree window
function! s:RestoreScreenState()
    if !exists("t:NERDTreeOldTopLine") || !exists("t:NERDTreeOldPos") || !exists("t:NERDTreeOldWindowSize")
        return
    endif
    exec("silent ". (s:ShouldSplitVertically() ? "vertical" : "") ." resize ".t:NERDTreeOldWindowSize)

    let old_scrolloff=&scrolloff
    let &scrolloff=0
    call cursor(t:NERDTreeOldTopLine, 0)
    normal! zt
    call setpos(".", t:NERDTreeOldPos)
    let &scrolloff=old_scrolloff
endfunction

"FUNCTION: s:SaveScreenState() {{{2
"Saves the current cursor position in the current buffer and the window
"scroll position
"
"Assumes the cursor is in the NERDTree window
function! s:SaveScreenState()
    let t:NERDTreeOldPos = getpos(".")
    let t:NERDTreeOldTopLine = line("w0")
    let t:NERDTreeOldWindowSize = s:ShouldSplitVertically() ? winwidth("") : winheight("")
endfunction

"FUNCTION: s:SetupSyntaxHighlighting() {{{2
function! s:SetupSyntaxHighlighting()
    "treeFlags are syntax items that should be invisible, but give clues as to
    "how things should be highlighted
    syn match treeFlag #\~#
    syn match treeFlag #\[RO\]#

    "highlighting for the .. (up dir) line at the top of the tree
    execute "syn match treeUp #". s:tree_up_dir_line ."#"

    "highlighting for the ~/+ symbols for the directory nodes
    syn match treeClosable #\~\<#
    syn match treeClosable #\~\.#
    syn match treeOpenable #+\<#
    syn match treeOpenable #+\.#he=e-1

    "highlighting for the tree structural parts
    syn match treePart #|#
    syn match treePart #`#
    syn match treePartFile #[|`]-#hs=s+1 contains=treePart

    "quickhelp syntax elements
    syn match treeHelpKey #" \{1,2\}[^ ]*:#hs=s+2,he=e-1
    syn match treeHelpKey #" \{1,2\}[^ ]*,#hs=s+2,he=e-1
    syn match treeHelpTitle #" .*\~#hs=s+2,he=e-1 contains=treeFlag
    syn match treeToggleOn #".*(on)#hs=e-2,he=e-1 contains=treeHelpKey
    syn match treeToggleOff #".*(off)#hs=e-3,he=e-1 contains=treeHelpKey
    syn match treeHelpCommand #" :.\{-}\>#hs=s+3
    syn match treeHelp  #^".*# contains=treeHelpKey,treeHelpTitle,treeFlag,treeToggleOff,treeToggleOn,treeHelpCommand

    "highlighting for readonly files
    syn match treeRO #[\/0-9a-zA-Z]\+.*\[RO\]# contains=treeFlag,treeBookmark

    "highlighting for sym links
    syn match treeLink #[^-| `].* -> # contains=treeBookmark,treeOpenable,treeClosable,treeDirSlash

    "highlighing for directory nodes and file nodes
    syn match treeDirSlash #/#
    syn match treeDir #[^-| `].*/# contains=treeLink,treeDirSlash,treeOpenable,treeClosable
    syn match treeExecFile  #[|`]-.*\*\($\| \)# contains=treeLink,treePart,treeRO,treePartFile,treeBookmark
    syn match treeFile  #|-.*# contains=treeLink,treePart,treeRO,treePartFile,treeBookmark,treeExecFile
    syn match treeFile  #`-.*# contains=treeLink,treePart,treeRO,treePartFile,treeBookmark,treeExecFile
    syn match treeCWD #^/.*$#

    "highlighting for bookmarks
    syn match treeBookmark # {.*}#hs=s+1

    "highlighting for the bookmarks table
    syn match treeBookmarksLeader #^>#
    syn match treeBookmarksHeader #^>-\+Bookmarks-\+$# contains=treeBookmarksLeader
    syn match treeBookmarkName #^>.\{-} #he=e-1 contains=treeBookmarksLeader
    syn match treeBookmark #^>.*$# contains=treeBookmarksLeader,treeBookmarkName,treeBookmarksHeader

    if g:NERDChristmasTree
        hi def link treePart Special
        hi def link treePartFile Type
        hi def link treeFile Normal
        hi def link treeExecFile Title
        hi def link treeDirSlash Identifier
        hi def link treeClosable Type
    else
        hi def link treePart Normal
        hi def link treePartFile Normal
        hi def link treeFile Normal
        hi def link treeClosable Title
    endif

    hi def link treeBookmarksHeader statement
    hi def link treeBookmarksLeader ignore
    hi def link treeBookmarkName Identifier
    hi def link treeBookmark normal

    hi def link treeHelp String
    hi def link treeHelpKey Identifier
    hi def link treeHelpCommand Identifier
    hi def link treeHelpTitle Macro
    hi def link treeToggleOn Question
    hi def link treeToggleOff WarningMsg

    hi def link treeDir Directory
    hi def link treeUp Directory
    hi def link treeCWD Statement
    hi def link treeLink Macro
    hi def link treeOpenable Title
    hi def link treeFlag ignore
    hi def link treeRO WarningMsg
    hi def link treeBookmark Statement

    hi def link NERDTreeCurrentNode Search
endfunction

"FUNCTION: s:ShouldSplitToOpen() {{{2
"Returns 1 if opening a file from the tree in the given window requires it to
"be split
"
"Args:
"winnumber: the number of the window in question
function! s:ShouldSplitToOpen(winnumber)
    "gotta split if theres only one window (i.e. the NERD tree)
    if winnr("$") == 1
        return 1
    endif

    let oldwinnr = winnr()
    exec a:winnumber . "wincmd p"
    let specialWindow = getbufvar("%", '&buftype') != '' || getwinvar('%', '&previewwindow')
    let modified = &modified
    exec oldwinnr . "wincmd p"

    "if its a special window e.g. quickfix or another explorer plugin then we
    "have to split
    if specialWindow
        return 1
    endif

    if &hidden
        return 0
    endif

    return modified && s:BufInWindows(winbufnr(a:winnumber)) < 2
endfunction

" Function: s:ShouldSplitVertically()   {{{2
" Returns 1 if g:NERDTreeWinPos is 'left' or 'right'
function! s:ShouldSplitVertically()
    return g:NERDTreeWinPos == 'left' || g:NERDTreeWinPos == 'right'
endfunction
"FUNCTION: s:StripMarkupFromLine(line, removeLeadingSpaces){{{2
"returns the given line with all the tree parts stripped off
"
"Args:
"line: the subject line
"removeLeadingSpaces: 1 if leading spaces are to be removed (leading spaces =
"any spaces before the actual text of the node)
function! s:StripMarkupFromLine(line, removeLeadingSpaces)
    let line = a:line
    "remove the tree parts and the leading space
    let line = substitute (line,"^" . s:tree_markup_reg . "*","","")

    "strip off any read only flag
    let line = substitute (line, ' \[RO\]', "","")

    "strip off any bookmark flags
    let line = substitute (line, ' {[^}]*}', "","")

    "strip off any executable flags
    let line = substitute (line, '*\ze\($\| \)', "","")

    let wasdir = 0
    if line =~ '/$'
        let wasdir = 1
    endif
    let line = substitute (line,' -> .*',"","") " remove link to
    if wasdir == 1
        let line = substitute (line, '/\?$', '/', "")
    endif

    if a:removeLeadingSpaces
        let line = substitute (line, '^ *', '', '')
    endif

    return line
endfunction

"FUNCTION: s:Toggle(dir) {{{2
"Toggles the NERD tree. I.e the NERD tree is open, it is closed, if it is
"closed it is restored or initialized (if it doesnt exist)
"
"Args:
"dir: the full path for the root node (is only used if the NERD tree is being
"initialized.
function! s:Toggle(dir)
    if s:TreeExistsForTab()
        if !s:IsTreeOpen()
            call s:CreateTreeWin()
            call s:RenderView()

            call s:RestoreScreenState()
        else
            call s:CloseTree()
        endif
    else
        call s:InitNerdTree(a:dir)
    endif
endfunction

"FUNCTION: s:ValidateBookmark(bookmark) {{{2
function! s:ValidateBookmark(bookmark)
    try
        call a:bookmark.MustExist()
        return 1
    catch /NERDTree.BookmarkPointsToInvalidLocation/
        call s:RenderView()
        call s:Echo(a:bookmark.name . "now points to an invalid location. See :help NERDTreeInvalidBookmarks for info.")
    endtry
endfunction

"SECTION: Interface bindings {{{1
"============================================================
"FUNCTION: s:ActivateNode(forceKeepWindowOpen) {{{2
"If the current node is a file, open it in the previous window (or a new one
"if the previous is modified). If it is a directory then it is opened.
"
"args:
"forceKeepWindowOpen - dont close the window even if NERDTreeQuitOnOpen is set
function! s:ActivateNode(forceKeepWindowOpen)
    if getline(".") == s:tree_up_dir_line
        return s:UpDir(0)
    endif

    let treenode = s:GetSelectedNode()
    if treenode != {}
        if treenode.path.isDirectory
            call treenode.ToggleOpen()
            call s:RenderView()
            call s:PutCursorOnNode(treenode, 0, 0)
        else
            call s:OpenFileNode(treenode)
            if !a:forceKeepWindowOpen
                call s:CloseTreeIfQuitOnOpen()
            end
        endif
    else
        let bookmark = s:GetSelectedBookmark()
        if !empty(bookmark)
            if bookmark.path.isDirectory
                call s:BookmarkToRoot(bookmark.name)
            else
                if s:ValidateBookmark(bookmark)
                    call s:OpenFileNode(s:oTreeFileNode.New(bookmark.path))
                endif
            endif
        endif
    endif
endfunction

"FUNCTION: s:BindMappings() {{{2
function! s:BindMappings()
    " set up mappings and commands for this buffer
    nnoremap <silent> <buffer> <middlerelease> :call <SID>HandleMiddleMouse()<cr>
    nnoremap <silent> <buffer> <leftrelease> <leftrelease>:call <SID>CheckForActivate()<cr>
    nnoremap <silent> <buffer> <2-leftmouse> :call <SID>ActivateNode(0)<cr>

    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapActivateNode . " :call <SID>ActivateNode(0)<cr>"
    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapOpenSplit ." :call <SID>OpenEntrySplit(0)<cr>"

    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapPreview ." :call <SID>PreviewNode(0)<cr>"
    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapPreviewSplit ." :call <SID>PreviewNode(1)<cr>"


    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapExecute ." :call <SID>ExecuteNode()<cr>"

    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapOpenRecursively ." :call <SID>OpenNodeRecursively()<cr>"

    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapUpdirKeepOpen ." :call <SID>UpDir(1)<cr>"
    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapUpdir ." :call <SID>UpDir(0)<cr>"
    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapChangeRoot ." :call <SID>ChRoot()<cr>"

    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapChdir ." :call <SID>ChCwd()<cr>"

    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapQuit ." :NERDTreeToggle<cr>"

    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapRefreshRoot ." :call <SID>RefreshRoot()<cr>"
    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapRefresh ." :call <SID>RefreshCurrent()<cr>"

    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapHelp ." :call <SID>DisplayHelp()<cr>"
    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapToggleHidden ." :call <SID>ToggleShowHidden()<cr>"
    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapToggleFilters ." :call <SID>ToggleIgnoreFilter()<cr>"
    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapToggleFiles ." :call <SID>ToggleShowFiles()<cr>"
    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapToggleBookmarks ." :call <SID>ToggleShowBookmarks()<cr>"

    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapCloseDir ." :call <SID>CloseCurrentDir()<cr>"
    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapCloseChildren ." :call <SID>CloseChildren()<cr>"

    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapFilesystemMenu ." :call <SID>ShowFileSystemMenu()<cr>"

    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapJumpParent ." :call <SID>JumpToParent()<cr>"
    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapJumpNextSibling ." :call <SID>JumpToSibling(1)<cr>"
    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapJumpPrevSibling ." :call <SID>JumpToSibling(0)<cr>"
    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapJumpFirstChild ." :call <SID>JumpToFirstChild()<cr>"
    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapJumpLastChild ." :call <SID>JumpToLastChild()<cr>"
    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapJumpRoot ." :call <SID>JumpToRoot()<cr>"

    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapOpenInTab ." :call <SID>OpenInNewTab(0)<cr>"
    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapOpenInTabSilent ." :call <SID>OpenInNewTab(1)<cr>"

    exec "nnoremap <silent> <buffer> ". g:NERDTreeMapOpenExpl ." :call <SID>OpenExplorer()<cr>"

    command! -buffer -nargs=1 Bookmark :call <SID>BookmarkNode('<args>')
    command! -buffer -complete=customlist,s:CompleteBookmarks -nargs=1 RevealBookmark :call <SID>RevealBookmark('<args>')
    command! -buffer -complete=customlist,s:CompleteBookmarks -nargs=1 OpenBookmark :call <SID>OpenBookmark('<args>')
    command! -buffer -complete=customlist,s:CompleteBookmarks -nargs=* ClearBookmarks call <SID>ClearBookmarks('<args>')
    command! -buffer -complete=customlist,s:CompleteBookmarks -nargs=+ BookmarkToRoot call <SID>BookmarkToRoot('<args>')
    command! -buffer -nargs=0 ClearAllBookmarks call s:oBookmark.ClearAll() <bar> call <SID>RenderView()
    command! -buffer -nargs=0 ReadBookmarks call s:oBookmark.CacheBookmarks(0) <bar> call <SID>RenderView()
    command! -buffer -nargs=0 WriteBookmarks call s:oBookmark.Write()
endfunction

" FUNCTION: s:BookmarkNode(name) {{{2
" Associate the current node with the given name
function! s:BookmarkNode(name)
    let currentNode = s:GetSelectedNode()
    if currentNode != {}
        try
            call currentNode.Bookmark(a:name)
            call s:RenderView()
        catch /NERDTree.IllegalBookmarkName/
            call s:Echo("bookmark names must not contain spaces")
        endtry
    else
        call s:Echo("select a node first")
    endif
endfunction
"FUNCTION: s:CheckForActivate() {{{2
"Checks if the click should open the current node, if so then activate() is
"called (directories are automatically opened if the symbol beside them is
"clicked)
function! s:CheckForActivate()
    let currentNode = s:GetSelectedNode()
    if currentNode != {}
        let startToCur = strpart(getline(line(".")), 0, col("."))
        let char = strpart(startToCur, strlen(startToCur)-1, 1)

        "if they clicked a dir, check if they clicked on the + or ~ sign
        "beside it
        if currentNode.path.isDirectory
            let reg = '^' . s:tree_markup_reg .'*[~+]$'
            if startToCur =~ reg
                call s:ActivateNode(0)
                return
            endif
        endif

        if (g:NERDTreeMouseMode == 2 && currentNode.path.isDirectory) || g:NERDTreeMouseMode == 3
            if char !~ s:tree_markup_reg && startToCur !~ '\/$'
                call s:ActivateNode(0)
                return
            endif
        endif
    endif
endfunction

" FUNCTION: s:ChCwd() {{{2
function! s:ChCwd()
    let treenode = s:GetSelectedNode()
    if treenode == {}
        call s:Echo("Select a node first")
        return
    endif

    try
        call treenode.path.ChangeToDir()
    catch /^NERDTree.Path.Change/
        call s:EchoWarning("could not change cwd")
    endtry
endfunction

" FUNCTION: s:ChRoot() {{{2
" changes the current root to the selected one
function! s:ChRoot()
    let treenode = s:GetSelectedNode()
    if treenode == {}
        call s:Echo("Select a node first")
        return
    endif

    call treenode.MakeRoot()
    call s:RenderView()
    call s:PutCursorOnNode(t:NERDTreeRoot, 0, 0)
endfunction

" FUNCTION: s:ClearBookmarks(bookmarks) {{{2
function! s:ClearBookmarks(bookmarks)
    if a:bookmarks == ''
        let currentNode = s:GetSelectedNode()
        if currentNode != {}
            call currentNode.ClearBookmarks()
        endif
    else
        for name in split(a:bookmarks, ' ')
            let bookmark = s:oBookmark.BookmarkFor(name)
            call bookmark.Delete()
        endfor
    endif
    call s:RenderView()
endfunction
" FUNCTION: s:CloseChildren() {{{2
" closes all childnodes of the current node
function! s:CloseChildren()
    let currentNode = s:GetSelectedDir()
    if currentNode == {}
        call s:Echo("Select a node first")
        return
    endif

    call currentNode.CloseChildren()
    call s:RenderView()
    call s:PutCursorOnNode(currentNode, 0, 0)
endfunction
" FUNCTION: s:CloseCurrentDir() {{{2
" closes the parent dir of the current node
function! s:CloseCurrentDir()
    let treenode = s:GetSelectedNode()
    if treenode == {}
        call s:Echo("Select a node first")
        return
    endif

    let parent = treenode.parent
    if parent.IsRoot()
        call s:Echo("cannot close tree root")
    else
        call treenode.parent.Close()
        call s:RenderView()
        call s:PutCursorOnNode(treenode.parent, 0, 0)
    endif
endfunction

" FUNCTION: s:CopyNode() {{{2
function! s:CopyNode()
    let currentNode = s:GetSelectedNode()
    if currentNode == {}
        call s:Echo("Put the cursor on a file node first")
        return
    endif

    let newNodePath = input("Copy the current node\n" .
                          \ "==========================================================\n" .
                          \ "Enter the new path to copy the node to:                   \n" .
                          \ "", currentNode.path.Str(0))

    if newNodePath != ""
        "strip trailing slash
        let newNodePath = substitute(newNodePath, '\/$', '', '')

        let confirmed = 1
        if currentNode.path.CopyingWillOverwrite(newNodePath)
            call s:Echo("\nWarning: copying may overwrite files! Continue? (yN)")
            let choice = nr2char(getchar())
            let confirmed = choice == 'y'
        endif

        if confirmed
            try
                let newNode = currentNode.Copy(newNodePath)
                call s:RenderView()
                call s:PutCursorOnNode(newNode, 0, 0)
            catch /^NERDTree/
                call s:EchoWarning("Could not copy node")
            endtry
        endif
    else
        call s:Echo("Copy aborted.")
    endif
    redraw
endfunction

" FUNCTION: s:DeleteNode() {{{2
" if the current node is a file, pops up a dialog giving the user the option
" to delete it
function! s:DeleteNode()
    let currentNode = s:GetSelectedNode()
    if currentNode == {}
        call s:Echo("Put the cursor on a file node first")
        return
    endif

    let confirmed = 0

    if currentNode.path.isDirectory
        let choice =input("Delete the current node\n" .
                         \ "==========================================================\n" .
                         \ "STOP! To delete this entire directory, type 'yes'\n" .
                         \ "" . currentNode.path.StrForOS(0) . ": ")
        let confirmed = choice == 'yes'
    else
        echo "Delete the current node\n" .
           \ "==========================================================\n".
           \ "Are you sure you wish to delete the node:\n" .
           \ "" . currentNode.path.StrForOS(0) . " (yN):"
        let choice = nr2char(getchar())
        let confirmed = choice == 'y'
    endif


    if confirmed
        try
            call currentNode.Delete()
            call s:RenderView()

            "if the node is open in a buffer, ask the user if they want to
            "close that buffer
            let bufnum = bufnr(currentNode.path.Str(0))
            if buflisted(bufnum)
                let prompt = "\nNode deleted.\n\nThe file is open in buffer ". bufnum . (bufwinnr(bufnum) == -1 ? " (hidden)" : "") .". Delete this buffer? (yN)"
                call s:PromptToDelBuffer(bufnum, prompt)
            endif

            redraw
        catch /^NERDTree/
            call s:EchoWarning("Could not remove node")
        endtry
    else
        call s:Echo("delete aborted" )
    endif

endfunction

" FUNCTION: s:DisplayHelp() {{{2
" toggles the help display
function! s:DisplayHelp()
    let t:treeShowHelp = t:treeShowHelp ? 0 : 1
    call s:RenderView()
    call s:CenterView()
endfunction

" FUNCTION: s:ExecuteNode() {{{2
function! s:ExecuteNode()
    let treenode = s:GetSelectedNode()
    if treenode == {} || treenode.path.isDirectory
        call s:Echo("Select an executable file node first" )
    else
        echo "NERDTree executor\n" .
           \ "==========================================================\n".
           \ "Complete the command to execute (add arguments etc): \n\n"
        let cmd = treenode.path.StrForOS(1)
        let cmd = input(':!', cmd . ' ')

        if cmd != ''
            exec ':!' . cmd
        else
            call s:Echo("command aborted")
        endif
    endif
endfunction

" FUNCTION: s:HandleMiddleMouse() {{{2
function! s:HandleMiddleMouse()
    let curNode = s:GetSelectedNode()
    if curNode == {}
        call s:Echo("Put the cursor on a node first" )
        return
    endif

    if curNode.path.isDirectory
        call s:OpenExplorer()
    else
        call s:OpenEntrySplit(0)
    endif
endfunction


" FUNCTION: s:InsertNewNode() {{{2
" Adds a new node to the filesystem and then into the tree
function! s:InsertNewNode()
    let curDirNode = s:GetSelectedDir()
    if curDirNode == {}
        call s:Echo("Put the cursor on a node first" )
        return
    endif

    let newNodeName = input("Add a childnode\n".
                          \ "==========================================================\n".
                          \ "Enter the dir/file name to be created. Dirs end with a '/'\n" .
                          \ "", curDirNode.path.StrForGlob() . s:os_slash)

    if newNodeName == ''
        call s:Echo("Node Creation Aborted.")
        return
    endif

    try
        let newPath = s:oPath.Create(newNodeName)
        let parentNode = t:NERDTreeRoot.FindNode(newPath.GetPathTrunk())

        let newTreeNode = s:oTreeFileNode.New(newPath)
        if parentNode.isOpen || !empty(parentNode.children)
            call parentNode.AddChild(newTreeNode, 1)
            call s:RenderView()
            call s:PutCursorOnNode(newTreeNode, 1, 0)
        endif
    catch /^NERDTree/
        call s:EchoWarning("Node Not Created.")
    endtry
endfunction

" FUNCTION: s:JumpToFirstChild() {{{2
" wrapper for the jump to child method
function! s:JumpToFirstChild()
    call s:JumpToChild(0)
endfunction

" FUNCTION: s:JumpToLastChild() {{{2
" wrapper for the jump to child method
function! s:JumpToLastChild()
    call s:JumpToChild(1)
endfunction

" FUNCTION: s:JumpToParent() {{{2
" moves the cursor to the parent of the current node
function! s:JumpToParent()
    let currentNode = s:GetSelectedNode()
    if !empty(currentNode)
        if !empty(currentNode.parent)
            call s:PutCursorOnNode(currentNode.parent, 1, 0)
            call s:CenterView()
        else
            call s:Echo("cannot jump to parent")
        endif
    else
        call s:Echo("put the cursor on a node first")
    endif
endfunction

" FUNCTION: s:JumpToRoot() {{{2
" moves the cursor to the root node
function! s:JumpToRoot()
    call s:PutCursorOnNode(t:NERDTreeRoot, 1, 0)
    call s:CenterView()
endfunction

" FUNCTION: s:JumpToSibling() {{{2
" moves the cursor to the sibling of the current node in the given direction
"
" Args:
" forward: 1 if the cursor should move to the next sibling, 0 if it should
" move back to the previous sibling
function! s:JumpToSibling(forward)
    let currentNode = s:GetSelectedNode()
    if !empty(currentNode)
        let sibling = currentNode.FindSibling(a:forward)

        if !empty(sibling)
            call s:PutCursorOnNode(sibling, 1, 0)
            call s:CenterView()
        endif
    else
        call s:Echo("put the cursor on a node first")
    endif
endfunction

" FUNCTION: s:OpenBookmark(name) {{{2
" put the cursor on the given bookmark and, if its a file, open it
function! s:OpenBookmark(name)
    try
        let targetNode = s:oBookmark.GetNodeForName(a:name, 0)
        call s:PutCursorOnNode(targetNode, 0, 1)
        redraw!
    catch /NERDTree.BookmarkedNodeNotFound/
        call s:Echo("note - target node is not cached")
        let bookmark = s:oBookmark.BookmarkFor(a:name)
        let targetNode = s:oTreeFileNode.New(bookmark.path)
    endtry
    if targetNode.path.isDirectory
        call s:OpenExplorerFor(targetNode)
    else
        call s:OpenFileNode(targetNode)
    endif
endfunction
" FUNCTION: s:OpenEntrySplit(forceKeepWindowOpen) {{{2
"Opens the currently selected file from the explorer in a
"new window
"
"args:
"forceKeepWindowOpen - dont close the window even if NERDTreeQuitOnOpen is set
function! s:OpenEntrySplit(forceKeepWindowOpen)
    let treenode = s:GetSelectedNode()
    if treenode != {}
        call s:OpenFileNodeSplit(treenode)
        if !a:forceKeepWindowOpen
            call s:CloseTreeIfQuitOnOpen()
        endif
    else
        call s:Echo("select a node first")
    endif
endfunction

" FUNCTION: s:OpenExplorer() {{{2
function! s:OpenExplorer()
    let treenode = s:GetSelectedDir()
    if treenode != {}
        call s:OpenExplorerFor(treenode)
    else
        call s:Echo("select a node first")
    endif
endfunction

" FUNCTION: s:OpenInNewTab(stayCurrentTab) {{{2
" Opens the selected node or bookmark in a new tab
" Args:
" stayCurrentTab: if 1 then vim will stay in the current tab, if 0 then vim
" will go to the tab where the new file is opened
function! s:OpenInNewTab(stayCurrentTab)
    let currentTab = tabpagenr()

    let treenode = s:GetSelectedNode()
    if treenode != {}
        if treenode.path.isDirectory
            tabnew
            call s:InitNerdTree(treenode.path.StrForOS(0))
        else
            exec "tabedit " . treenode.path.StrForEditCmd()
        endif
    else
        let bookmark = s:GetSelectedBookmark()
        if bookmark != {}
            if bookmark.path.isDirectory
                tabnew
                call s:InitNerdTree(bookmark.name)
            else
                exec "tabedit " . bookmark.path.StrForEditCmd()
            endif
        endif
    endif
    if a:stayCurrentTab
        exec "tabnext " . currentTab
    endif
endfunction

" FUNCTION: s:OpenNodeRecursively() {{{2
function! s:OpenNodeRecursively()
    let treenode = s:GetSelectedNode()
    if treenode == {} || treenode.path.isDirectory == 0
        call s:Echo("Select a directory node first" )
    else
        call s:Echo("Recursively opening node. Please wait...")
        call treenode.OpenRecursively()
        call s:RenderView()
        redraw
        call s:Echo("Recursively opening node. Please wait... DONE")
    endif

endfunction

"FUNCTION: s:PreviewNode() {{{2
function! s:PreviewNode(openNewWin)
    if a:openNewWin
        call s:OpenEntrySplit(1)
    else
        call s:ActivateNode(1)
    end
    call s:PutCursorInTreeWin()
endfunction

" FUNCTION: s:RevealBookmark(name) {{{2
" put the cursor on the node associate with the given name
function! s:RevealBookmark(name)
    try
        let targetNode = s:oBookmark.GetNodeForName(a:name, 0)
        call s:PutCursorOnNode(targetNode, 0, 1)
    catch /NERDTree.BookmarkDoesntExist/
        call s:Echo("Bookmark isnt cached under the current root")
    endtry
endfunction
" FUNCTION: s:RefreshRoot() {{{2
" Reloads the current root. All nodes below this will be lost and the root dir
" will be reloaded.
function! s:RefreshRoot()
    call s:Echo("Refreshing the root node. This could take a while...")
    call t:NERDTreeRoot.Refresh()
    call s:RenderView()
    redraw
    call s:Echo("Refreshing the root node. This could take a while... DONE")
endfunction

" FUNCTION: s:RefreshCurrent() {{{2
" refreshes the root for the current node
function! s:RefreshCurrent()
    let treenode = s:GetSelectedDir()
    if treenode == {}
        call s:Echo("Refresh failed. Select a node first")
        return
    endif

    call s:Echo("Refreshing node. This could take a while...")
    call treenode.Refresh()
    call s:RenderView()
    redraw
    call s:Echo("Refreshing node. This could take a while... DONE")
endfunction
" FUNCTION: s:RenameCurrent() {{{2
" allows the user to rename the current node
function! s:RenameCurrent()
    let curNode = s:GetSelectedNode()
    if curNode == {}
        call s:Echo("Put the cursor on a node first" )
        return
    endif

    let newNodePath = input("Rename the current node\n" .
                          \ "==========================================================\n" .
                          \ "Enter the new path for the node:                          \n" .
                          \ "", curNode.path.StrForOS(0))

    if newNodePath == ''
        call s:Echo("Node Renaming Aborted.")
        return
    endif

    try
        let bufnum = bufnr(curNode.path.Str(0))

        call curNode.Rename(newNodePath)
        call s:RenderView()

        "if the node is open in a buffer, ask the user if they want to
        "close that buffer
        if bufnum != -1
            let prompt = "\nNode renamed.\n\nThe old file is open in buffer ". bufnum . (bufwinnr(bufnum) == -1 ? " (hidden)" : "") .". Delete this buffer? (yN)"
            call s:PromptToDelBuffer(bufnum, prompt)
        endif

        call s:PutCursorOnNode(curNode, 1, 0)

        redraw
    catch /^NERDTree/
        call s:EchoWarning("Node Not Renamed.")
    endtry
endfunction

" FUNCTION: s:ShowFileSystemMenu() {{{2
function! s:ShowFileSystemMenu()
    let curNode = s:GetSelectedNode()
    if curNode == {}
        call s:Echo("Put the cursor on a node first" )
        return
    endif


    let prompt = "NERDTree Filesystem Menu\n" .
       \ "==========================================================\n".
       \ "Select the desired operation:                             \n" .
       \ " (a)dd a childnode\n".
       \ " (m)ove the current node\n".
       \ " (d)elete the current node\n"
    if s:oPath.CopyingSupported()
        let prompt = prompt . " (c)opy the current node\n\n"
    else
        let prompt = prompt . " \n"
    endif

    echo prompt

    let choice = nr2char(getchar())

    if choice ==? "a"
        call s:InsertNewNode()
    elseif choice ==? "m"
        call s:RenameCurrent()
    elseif choice ==? "d"
        call s:DeleteNode()
    elseif choice ==? "c" && s:oPath.CopyingSupported()
        call s:CopyNode()
    endif
endfunction

" FUNCTION: s:ToggleIgnoreFilter() {{{2
" toggles the use of the NERDTreeIgnore option
function! s:ToggleIgnoreFilter()
    let t:NERDTreeIgnoreEnabled = !t:NERDTreeIgnoreEnabled
    call s:RenderViewSavingPosition()
    call s:CenterView()
endfunction

" FUNCTION: s:ToggleShowBookmarks() {{{2
" toggles the display of bookmarks
function! s:ToggleShowBookmarks()
    let t:NERDTreeShowBookmarks = !t:NERDTreeShowBookmarks
    if t:NERDTreeShowBookmarks
        call s:RenderView()
        call s:PutCursorOnBookmarkTable()
    else
        call s:RenderViewSavingPosition()
    endif
    call s:CenterView()
endfunction
" FUNCTION: s:ToggleShowFiles() {{{2
" toggles the display of hidden files
function! s:ToggleShowFiles()
    let t:NERDTreeShowFiles = !t:NERDTreeShowFiles
    call s:RenderViewSavingPosition()
    call s:CenterView()
endfunction

" FUNCTION: s:ToggleShowHidden() {{{2
" toggles the display of hidden files
function! s:ToggleShowHidden()
    let t:NERDTreeShowHidden = !t:NERDTreeShowHidden
    call s:RenderViewSavingPosition()
    call s:CenterView()
endfunction

"FUNCTION: s:UpDir(keepState) {{{2
"moves the tree up a level
"
"Args:
"keepState: 1 if the current root should be left open when the tree is
"re-rendered
function! s:UpDir(keepState)
    let cwd = t:NERDTreeRoot.path.Str(0)
    if cwd == "/" || cwd =~ '^[^/]..$'
        call s:Echo("already at top dir")
    else
        if !a:keepState
            call t:NERDTreeRoot.Close()
        endif

        let oldRoot = t:NERDTreeRoot

        if empty(t:NERDTreeRoot.parent)
            let path = t:NERDTreeRoot.path.GetPathTrunk()
            let newRoot = s:oTreeDirNode.New(path)
            call newRoot.Open()
            call newRoot.TransplantChild(t:NERDTreeRoot)
            let t:NERDTreeRoot = newRoot
        else
            let t:NERDTreeRoot = t:NERDTreeRoot.parent

        endif

        call s:RenderView()
        call s:PutCursorOnNode(oldRoot, 0, 0)
    endif
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
