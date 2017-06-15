function h = shade(x0, c0, varargin)
S = varargin2S(varargin, {
    'y', ylim
    'color', bml.plot.color_lines('b')
    });

if ischar(S.color)
    S.color = bml.plot.color_lines(S.color);
end

assert(isvector(x0));
n = length(x0);

assert(isvector(c0));
assert(length(c0) == n);

x = [x0(:); flipud(x0(:))];

color = rep2fit(S.color, [n * 2, 3]);
alpha = [c0(:); flipud(c0(:))];

y = [S.y(1) + zeros(n, 1); S.y(2) + zeros(n, 1)];

h = patch( 'XData', x, 'YData', y, ...
    ... x, y, S.color, ...
    'FaceVertexCData', color, ...
    'FaceVertexAlphaData', alpha, ...
    'FaceColor', 'interp', 'FaceAlpha', 'interp', 'EdgeColor', 'none');

end