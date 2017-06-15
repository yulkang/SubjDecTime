function area3(x0, y0, varargin)
% area3(x, y, varargin)
%
% 'base', 0
% 'plane', 'xy'
% 'origin', [0 0 0]
% 'z_offset', 0 % Positive is closer to the viewer at -x, -y, +z.
% 'Color', 'k'
% 'FaceAlpha', 0.25
% 'opt_patch', {}
% 'opt_plot', {}
% 
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'base', 0
    'plane', 'xy'
    'origin', [0 0 0]
    'z_offset', 0 % Positive is closer to the viewer at -x, -y, +z.
    'Color', 'k'
    'FaceAlpha', 0.25
    'opt_patch', {}
    'opt_plot', {}
    });
S.opt_patch = varargin2C(S.opt_patch, {
    'FaceColor', S.Color
    'FaceAlpha', S.FaceAlpha
    'EdgeColor', 'none'
    });
S.opt_plot = varargin2C(S.opt_plot, {
    'Color', S.Color
    });

assert(isvector(x0));
assert(isvector(y0));
x0 = x0(:);
y0 = y0(:);

switch S.plane
    case 'xy'
        base = S.base + S.origin(2);

        x = x0(:) + S.origin(1);
        y = base + y0;
        z = S.origin(3) + zeros(size(x)) + S.z_offset;

        x_patch = x([1, 1:end, end]);
        y_patch = [base; y; base];
        z_patch = z([1, 1:end, end]);

    case 'xz'
        base = S.base + S.origin(3);

        x = x0(:) + S.origin(1);
        y = S.origin(2) + zeros(size(x)) - S.z_offset;
        z = base + y0;

        x_patch = x([1, 1:end, end]);
        y_patch = y([1, 1:end, end]);
        z_patch = [base; z; base];
end

patch( ...
    'XData', x_patch, ...
    'YData', y_patch, ...
    'ZData', z_patch, ...
    S.opt_patch{:});
hold on;

plot3(x, y, z, S.opt_plot{:});
hold off;