function [out, succ, errs] = batch_fun(fun, inp, varargin)
% [out, succ, errs] = batch_fun(fun, {{inp1_1, inp1_2, ...}, {inp2_1, ...}, ...}, varargin)
%
% OPTIONS
% -------
% 'use_parfor',   false
% 'out_names',    {}
% 'nargout',      1
% 'catch',        false

S = varargin2S(varargin, {
    'use_parfor',   false
    'out_names',    {}
    'nargout',      1
    'catch',        false
    });

if ~isempty(S.out_names)
    S.nargout = length(S.out_names);
end

S.n  = length(inp);
out  = cell(S.n, S.nargout);
succ = false(S.n, 1);
errs = cell(S.n, 1);

if S.use_parfor
    parfor ii = 1:S.n
        [out(ii,:), succ(ii), errs{ii}] = run_batch(fun, inp{ii}, S);
    end
else
    for ii = 1:S.n
        [out(ii,:), succ(ii), errs{ii}] = run_batch(fun, inp{ii}, S);
    end
end

if ~isempty(S.out_names)
    out = cell2struct(out, S.out_names, 2);
end
end


function [c_out, c_succ, c_err] = run_batch(fun, inp, S)
% [c_out, c_succ] = run_batch(fun, inp, S)

c_out  = cell(1, S.nargout);
c_succ = true;
c_err  = [];

if S.catch
    try
        [c_out{:}] = fun(inp{:});
    catch err
        c_succ = false;
        warning(err_msg(err));
        c_err = err;
    end
else
    [c_out{:}] = fun(inp{:});
end
end