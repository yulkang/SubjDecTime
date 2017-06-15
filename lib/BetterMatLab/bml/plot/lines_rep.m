function rgb = lines_rep(rgb_rep, ix, to_cell)
% LINES_REP - repeat rgb rows for requested indices
%
% rgb = lines_rep(rgb_rep, ix=':', to_cell=false)

if ~exist('ix', 'var') || (ischar(ix) && strcmp(ix, ':'))
    ix = 1:size(rgb_rep, 1); 
end
if ~exist('to_cell', 'var'), to_cell = false; end

n_rep = size(rgb_rep,1);
 
rgb = rgb_rep(mod(ix-1, n_rep)+1, :);

if to_cell
    rgb = mat2cell(rgb, ones(1, length(ix)));
end