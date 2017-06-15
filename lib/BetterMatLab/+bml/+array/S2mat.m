function varargout = S2mat(varargin)
% S2mat: Concatenates vector in a struct vector into a S x v matrix.
%
% m = S2mat(S, f)
%
% Example:
%
% >> aa(1).b = [1 2 3];
% >> aa(2).b = [1 2 3]+10;
% >> S2mat(aa, 'b')
% ans = 
%      1     2     3
%     11    12    13
[varargout{1:nargout}] = S2mat(varargin{:});