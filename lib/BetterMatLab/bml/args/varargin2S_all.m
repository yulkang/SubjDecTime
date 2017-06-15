function Ss = varargin2S_all(args, defaults)
% Ss = varargin2S_all({args1, args2, ...}, defaults)
assert(iscell(args));

n = numel(args);
Ss = cell(size(args));

if ~exist('defaults', 'var')
    defaults = {};
end

for ii = 1:n
    Ss{ii} = varargin2S(args{ii}, defaults);
end
