function h = plotcircle(h, ctr, r, c, op, penwidth, varargin)
% h = plotcircle(h=[], [ctr_x1, ctr_y1; ...], [r_x, r_y], [r1, g1, b1; ...], op='fill'|'frame', penwidth=0.1, [args, ...])
%
% See also: plotrect
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

n = size(ctr,1);
r = rep2fit(r, [n, 2]);
c = rep2fit(c, [n, 3]);

if nargin < 4, op = 'frame'; end
if nargin < 5, penwidth = 0.1; end

if isempty(h)
    h = ghandles(1,n);
end
gh = ghandles;

th      = linspace(0, 2*pi);
th_flip = fliplr(th);
    
C = varargin2C(varargin, {
    'LineStyle', 'none'
    });

for ii = 1:n
    switch op
        case 'fill'
            dx = cos(th) * r(ii,1);
            dy = sin(th) * r(ii,2);
        case 'frame'
            dx = [cos(th) * (r(ii,1) + penwidth/2), cos(th_flip) * (r(ii,1) - penwidth/2)];
            dy = [sin(th) * (r(ii,2) + penwidth/2), sin(th_flip) * (r(ii,2) - penwidth/2)];
    end
    x = ctr(ii,1) + dx;
    y = ctr(ii,2) + dy;

    if isequal(h(ii), gh)
        h(ii) = patch(x, y, c(ii,:), C{:});
    else
        set(h(ii), 'XData', x, 'YData', y, 'FaceColor', c(ii,:), C{:});
    end
end

