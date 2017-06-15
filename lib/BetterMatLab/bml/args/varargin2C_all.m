function Cs = varargin2C_all(args, defaults)
% Cs = varargin2C_all(args, defaults)
assert(iscell(args));
assert(all(cellfun(@iscell, args(:))));
n = numel(args);

if ~exist('defaults', 'var')
    defaults = {};
end

Cs = cell(size(args));
for ii = 1:n
    Cs{ii} = varargin2C(args{ii}, defaults);
end
