function col = colormap_extreme(n_half, varargin)
S = varargin2S(varargin, {
    'orig', @parula
    'mid_prop', 0.5 % Remove center portion
    'mid_color', [] % 
    'mid_size', 1
    });

if ~exist('n_half', 'var') || isempty(n_half)
    n_half = 128; 
end
if isempty(S.mid_color)
    S.mid_color = S.orig(3);
    S.mid_color = S.mid_color(2,:);
end

n = ceil(n_half * (1 + S.mid_prop) * 2);
col0 = S.orig(n);
col = [
    col0(1:n_half, :)
    repmat(S.mid_color, [S.mid_size, 1])
    col0((end - n_half + 1):end, :)
    ];

