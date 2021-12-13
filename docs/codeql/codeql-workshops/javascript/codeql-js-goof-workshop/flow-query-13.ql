import javascript

// 1. The sink is any argumnent[i], i >= 1, to  _.merge(message, req.body.message,...)
predicate mergeCallArg(MethodCallExpr call, Expr sink) {
    // Identify the call
    call.getReceiver().toString() = "_" and
    call.getMethodName() = "merge" and
    // Pick any argument -- even the first, although not quite correct
    call.getAnArgument() = sink
}

// 2. The source is the `req` argument in the definition of `exports.chat.add(req, res)`
// Start simple, found 11 results; narrow via the signature; add the source.
predicate chatHandler(FunctionExpr func, Expr source) {
    func.getName() = "add" and
    // 2 parameters
    func.getNumParameter() = 2 and
    // body not empty
    func.getBody().getNumChild() > 0 and
    // the source argument
    source = func.getParameter(0)
}

// 3. Local flow between the source and sink
// Introduce explicit predicates for the source and sink Nodes
predicate chatHandler(DataFlow::Node sourceparam) { chatHandler(_, sourceparam.getAstNode()) }

predicate mergeCallArg(DataFlow::Node sinkargument) {
    exists(Expr sink, ASTNode child |
        mergeCallArg(_, sink) and 
        child = sink.getAChild*() and
        child = sinkargument.getAstNode()
    )
}

from DataFlow::Node sinkargument, DataFlow::Node sourceparam
where
    // specify the flow
    sourceparam.getASuccessor+() = sinkargument and
    // specify source
    chatHandler(sourceparam) and
    // specify sink
    mergeCallArg(sinkargument)
select sourceparam, sinkargument
