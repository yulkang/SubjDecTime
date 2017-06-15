function varargout = sepfun(f, sep, v, varargin)
% [y, x] = sepfun(f, sep, v, ...)
% [y1, y2, ..., x] = sepfun(f, sep, v, ...)
%
% OPTIONS
% -------
% 'UniformOutput',  true
% 'nargout',        max(1, nargout-1)
%
% EXAMPLE
% -------
% >> [y, x] = sepfun(@mean, [1 1 2 2 2], [10 10 10 20 20])
% y =
%    10.0000   16.6667
% x =
%      1     2
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'UniformOutput',    true
    'nargout',          max(1, nargout-1)
    });

% Get x
x   = unique(sep);
n_x = length(x);

% Prepare input
if ~iscell(v), v = {v}; end
n_v = length(v);
c_v = cell(1, n_v);

% Prepare output
c_argout = cell(n_x, S.nargout + 1);

% Loop over unique values of x
for i_sep = 1:n_x
    c_sep = x(i_sep);
    filt_sep = sep == c_sep;
    
    for i_v = 1:n_v
        c_v{i_v} = v{i_v}(filt_sep);
    end
    
    [c_argout{i_sep, 1:S.nargout}] = f(c_v{:});
end

% Give output
siz       = size(x);
varargout = cell(1, S.nargout + 1);

for i_argout = 1:S.nargout
    if S.UniformOutput
        varargout{i_argout} = reshape(cell2mat(c_argout(:,i_argout)), siz);
    else
        varargout{i_argout} = reshape(c_argout(:,i_argout), siz);
    end
end
varargout{S.nargout+1} = x;