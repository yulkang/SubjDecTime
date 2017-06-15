function varargout = errorbarShade(varargin)
% [hLine, hPatch] = errorbarShade(x, y, e, spec, [alpha = 0.5], specLine, specPatch)
%
% x : always a vector.
% y : vector or matrix. If matrix, one column per curve.
% e : vector or matrix. If matrix, one or two columns per curve (le, ue)
%
% spec      : either a string (like 'b.-'), a ColorSpec (like [0 0.5 0.5]), 
%             or a matrix of rgb triplets on each row.
% specLine  : {propertyName1, propertyValue1, ...}
%             as in plot(,...).
% specPatch : {propertyName1, propertyValue1, ...}
%             as in patch(,...).
%
% 2013 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = errorbarShade(varargin{:});