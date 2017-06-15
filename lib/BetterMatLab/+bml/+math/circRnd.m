function varargout = circRnd(varargin)
% CIRCRND  Sample x, y, r, and th, uniformly within a circle 
%
% [xy, rt] = circRnd(nDot, rAp, r, rApIn)
%
% r:  precomputed random numbers in [0,1]. A 2 x nDot matrix.
%
% xy: (x,y)     x nDot matrix
% rt: (r,theta) x nDot matrix
%
% See also: TESTCIRCRND, CIRCWRAP.
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = circRnd(varargin{:});