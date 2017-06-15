function h = plotrect(h, ctr, wh, c, op, penwidth, varargin)
% h = plotrect(h=[], [ctr_x1, ctr_y1; ...], [r_x, r_y], [r1, g1, b1; ...], op='fill'|'frame', penwidth=0.1, [args, ...])
%
% See also: plotcircle
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'th', 0
    });

n   = size(ctr,1);
wh  = rep2fit(wh, [n, 2]);
c   = rep2fit(c,  [n, 3]);

if nargin < 4, op = 'frame'; end
if nargin < 5, penwidth = 0.1; end

if isempty(h)
    h = ghandles(1,n);
end
gh = ghandles;

C = varargin2C(varargin, {
    'EdgeColor',    'none'
    });

for ii = 1:n
    switch op
        case 'fill'
            x = ctr(ii,1) + wh(ii,1) * [-1,  1,  1, -1, -1];
            y = ctr(ii,2) + wh(ii,2) * [-1, -1,  1,  1, -1];
            
        case 'frame'
            dx      = [-1,  1,  1, -1, -1];
            dx_flip = fliplr(dx);
            dy      = [-1, -1,  1,  1, -1];
            dy_flip = fliplr(dy);
            
            x = ctr(ii,1) + [(wh(ii,1) + penwidth/2) * dx, (wh(ii,1) - penwidth/2) * dx_flip];
            y = ctr(ii,2) + [(wh(ii,2) + penwidth/2) * dy, (wh(ii,2) - penwidth/2) * dy_flip];
            
            x = [x, x(1)]; %#ok<AGROW>
            y = [y, y(1)]; %#ok<AGROW>
    end
    
    if isequal(h(ii), gh)
        h(ii) = patch(x, y, c(ii,:), C{:});
    else
        set(h(ii), 'XData', x, 'YData', y, 'FaceColor', c(ii,:), C{:});
    end
end

