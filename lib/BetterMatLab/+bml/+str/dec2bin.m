function varargout = dec2bin(varargin)
%DEC2BIN Convert decimal integer to a binary string.
%   DEC2BIN(D) returns the binary representation of D as a string.
%   D must be a non-negative integer smaller than 2^52.
%
%   DEC2BIN(D,N) produces a binary representation with at least
%   N bits.
%
%   Example
%      dec2bin(23) returns '10111'
%
%   See also BIN2DEC, DEC2HEX, DEC2BASE.
[varargout{1:nargout}] = dec2bin(varargin{:});