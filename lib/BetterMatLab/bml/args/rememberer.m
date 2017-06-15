function varargout = rememberer(fun, args)
% varargout = rememberer(fun, args)
%
% fun: function handle
% args = {arg1, arg2, ...}
%
% 2013-2015 (c) Yul Kang. hk2699 at columbia dot edu.
    
persistent cache % containers.Map of {n, [in, out]}

if isempty(cache)
    cache = containers.Map;
end

fun_str = func2str(fun);
n_argout = max(nargout, 1);

if isKey(cache, fun_str)
    cached = cache(fun_str);
    n = size(cached, 1);
    
    for ii = 1:n
        if isequaln(cached{ii,1}, args)
            if n_argout <= numel(cached{ii, 2})
                % if found,
                varargout = cached{ii, 2};
                return;
            end
        end
    end
    
else
    cached = {};
end

% If not found
[varargout{1:n_argout}] = fun(args{:});
cache(fun_str) = [cached; {args, varargout}];
