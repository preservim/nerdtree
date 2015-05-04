"CLASS: Evaluator
"============================================================
let s:Evaluator = {}

function! s:Evaluator.AddEvaluator(event, funcname)
    let evaluators = s:Evaluator.GetEvaluatorsForEvent(a:event)
    if evaluators == []
        let evaluatorsMap = s:Evaluator.GetEvaluatorsMap()
        let evaluatorsMap[a:event] = evaluators
    endif
    call add(evaluators, a:funcname)
endfunction

function! s:Evaluator.EvaluateEvaluators(event, path, params)
    let event = g:NERDTreeEvent.New(b:NERDTree, a:path, a:event, a:params)

    let value = 0
    for evaluator in s:Evaluator.GetEvaluatorsForEvent(a:event)
        let value = {evaluator}(event, value)
    endfor
    return value
endfunction

function! s:Evaluator.GetEvaluatorsMap()
    if !exists("s:EvaluatorsMap")
        let s:EvaluatorsMap = {}
    endif
    return s:EvaluatorsMap
endfunction

function! s:Evaluator.GetEvaluatorsForEvent(name)
    let evaluatorsMap = s:Evaluator.GetEvaluatorsMap()
    return get(evaluatorsMap, a:name, [])
endfunction

let g:NERDTreePathEvaluator = deepcopy(s:Evaluator)

