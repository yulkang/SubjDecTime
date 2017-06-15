function h = imagesc3(x0, y0, v, varargin)
% h = imagesc3(x, y, v, varargin)
%
% 'plane', 'xy' % 'xy' | 'xz'
% 'origin', [0 0 0]
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'plane', 'xy' % 'xy' | 'xz'
    'origin', [0 0 0]
    });

switch S.plane
    case 'xy'
        x = x0 + S.origin(1);
        y = y0 + S.origin(2);
        z = [-1, 0, 1] + S.origin(3);

        xi = [];
        yi = [];
        zi = S.origin(3);

        v = repmat(permute(v, [2, 1, 3]), [1, 1, 3]);

    case 'xz'
        x = x0 + S.origin(1);
        y = [-1, 0, 1] + S.origin(2);
        z = y0 + S.origin(3);

        xi = [];
        yi = S.origin(2);
        zi = [];

        v = repmat(permute(v, [3, 1, 2]), [3, 1, 1]);

    otherwise
        error('plane=%s is not implemented yet!\n', plane);
end

h = slice(x, y, z, v, xi, yi, zi);
set(h, 'EdgeColor', 'none');
set(gca, 'CLim', [min(v(:)), max(v(:))]);

axis xy;
end