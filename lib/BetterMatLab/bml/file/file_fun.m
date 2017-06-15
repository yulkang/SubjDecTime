function res = file_fun(fun, files, varargin)
% FILE_FUN - runs a function on files
%
% res = file_fun(fun, files, varargin)
%
% vars      : variable names in a cell array

S = varargin2S(varargin, {...
    'vars', {}, ...
    'UniformOutput', true, ...
    'default_res', nan, ...
    'rethrow', true});

n = length(files);

if S.UniformOutput
    res = repmat(S.default_res, [1 n]);
else
    res = repmat({S.default_res}, [1 n]);
end

for ii = 1:n
    try
        L = load(files{ii}, S.vars{:});

        if S.UniformOutput
            res(ii) = fun(L);
        else
            res{ii} = fun(L);
        end
    catch err
        if S.rethrow
            rethrow(err);
        else
            fprintf('Error while processing %s :\n', files{ii});
            warning(err_msg(err));
            fprintf('\n');
        end
    end
end
