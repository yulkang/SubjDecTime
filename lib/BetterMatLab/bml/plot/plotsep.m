function h = plotsep(x, y, colors, args, varargin)
% h = plotsep(x, y, colors, args, varargin)
%
% x, y: vector, matrix, or a cell array of vectors.
% colors: a matrix, each row corresponding to [r g b] triplet, or a function handle.
% args: cell array of additional inputs to plot(). Only name-value pairs are allowed.
%
% OPTIONS
% -------
% 'sep', [] % If provided, groups x and y.
%
% h: cell array.
%
% See also: errorbarsep

S = varargin2S(varargin, {
    'sep', []
    'sepFilt', []
    });

x = enforceCell(x, S.sep);
y = enforceCell(y, S.sep);
n = max(size(x,2), size(y,2));
x = rep2fit(x, [1, n]);
y = rep2fit(y, [1, n]);

if nargin < 3 || isempty(colors), colors = @hsv2; end
if isa(colors, 'function_handle')
    colors = colors(n);
elseif isnumeric(colors)
    colors = rep2fit(colors, [n, 3]);
else
    error('colors must be a function handle, 1 x 3 vector, or n x 3 matrix!');
end
if nargin < 4, args = {}; end

if isempty(S.sepFilt)
    sepIncl = 1:n;
else
    sepIncl = sort(ix2py(S.sepFilt, n));
end

h = cell(1, max(sepIncl));
for ii = sepIncl;
    cArgs = varargin2C(args, {
        'Color', colors(ii,:)
        'MarkerFaceColor', colors(ii,:)
        });
    
    h{ii} = plot(x{ii}, y{ii}, cArgs{:});
    hold on;
end
hold off;
end

function v = enforceCell(v, sep)
if isempty(sep)
    if ~iscell(v)
        if isrow(v) && numel(v) > 1, v = v'; end 
        v = col2cell(v);
    end
else
    [~,~,sep] = unique(sep);
    nsep = max(sep);
    v0 = v;
    v = cell(1,nsep);
    for isep = 1:nsep
        v{isep} = v0(sep == isep);
    end
end
end