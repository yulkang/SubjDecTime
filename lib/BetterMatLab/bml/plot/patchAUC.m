function h = patchAUC(x, y, c, t, varargin)
% PATCHAUC Patch showing area under curve.
%
% h = patchAUC(x, y, c, t, varargin)

if ~exist('t', 'var'), t = 0.5; end

S = varargin2S(varargin, {'EdgeAlpha', 1, 'EdgeColor', [0 0 0]});
C = S2C(S);

h = patch([x(:); x(end); x(1)], [y(:); 0; 0], c, ...
    'FaceAlpha', t, C{:});
end