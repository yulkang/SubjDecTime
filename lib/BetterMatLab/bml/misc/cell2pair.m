function p = cell2pair(v, f)
% Get value and names, and returns value-name pair, all in cell arrays.
%
% p = cell2pair(v, f)
%
% All are row cell vectors.
%
% See also cell2struct, S2C, varargin2S

p = hVec([f(:)'; v(:)']);