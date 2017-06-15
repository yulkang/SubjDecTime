classdef IteratorInWorkspace < DeepCopyable
    % Evaluate fun(ws, item) - Under construction.
    % May just use ws2S and function handle.
properties 
    ws
    pos
    list
    fun
end
methods
    function Iter = IteratorInWorkspace(iter)
    end
    function reset(Iter)
    end
    function tf = has_next(Iter)
    end
    function v = get_next(Iter)
    end
end
end