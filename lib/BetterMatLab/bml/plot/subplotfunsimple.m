function subplotfunsimple(f, h, common_args, varargin)
% subplotfunsimple(f, h, common_args, varargin)

n = numel(f);
if nargin < 3, common_args = {}; end

for ii = 1:n
    axes(h(ii));
    f{ii}(common_args{:});
end