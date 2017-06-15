function varargout = circWrap(varargin)
% CIRCWRAP  Wraps horizontally to the edge on the other side of the circle.
%
% To use an arbitrary motion direction, use rotational transform before and
% after the wrapping.
%
% x = circWrap(x, py, signDx, th, rAp)
%
% x       : previous x position. Will be updated.
% py      : previous y position.
% signDx  : sign of dx.
% th      : newly sampled theta. Returned by CIRCRND.
% rAp     : radius of the aperture.
%
% See also: CIRCRND
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = circWrap(varargin{:});