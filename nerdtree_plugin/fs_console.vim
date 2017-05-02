"adds new keymaps for add and delete nodes
let opts = {'key': 'a', 'quickhelpText': 'add new node', 'callback': 'NERDTreeAddNode'}
call NERDTreeAddKeyMap(opts)
let opts = {'key': 'd', 'quickhelpText': 'delete node', 'callback': 'NERDTreeDeleteNode'}
call NERDTreeAddKeyMap(opts)
let opts = {'key': 'm', 'quickhelpText': 'move node', 'callback': 'NERDTreeMoveNode'}
call NERDTreeAddKeyMap(opts)
let opts = {'key': 'c', 'quickhelpText': 'copy node', 'callback': 'NERDTreeCopyNode'}
call NERDTreeAddKeyMap(opts)
