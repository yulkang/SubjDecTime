function files = savefigtags(h, prefix, postfix, varargin)
% files = savefigtags(h, prefix, postfix, varargin)

if nargin < 2, prefix = ''; end
if nargin < 3, postfix = ''; end

n = numel(h);
if iscell(h)
    tags = h;
    clear h
    for ii = n:-1:1
        h(ii) = fig_tag(tags{ii});
    end
else
    for ii = n:-1:1
        tags{ii} = get(h(ii), 'Tag');
    end
end

files = {};
for ii = 1:n
    file = [prefix, tags{ii}, postfix];
    C = varargin2C({'h_fig', h(ii)}, varargin);
    cFiles = savefigs(file, C{:});
    files = [files; cFiles]; %#ok<AGROW>
end
end