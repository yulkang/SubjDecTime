function rgb = lines_muted(varargin)
% LINES_MUTED - Muted RGB
%
% rgb = lines_muted(ix=':', to_cell=false)
%
% Give 1:n to get MATLAB's colormap.
%
% See also colormap, lines_rep

rgb_rep = ...
    [1.0 0.0 0.0
     0.0 0.7 0.2
     0.0 0.0 1.0
     0.5 0.0 0.5
     0.5 0.5 0.0];
 
rgb = lines_rep(rgb_rep, varargin{:});