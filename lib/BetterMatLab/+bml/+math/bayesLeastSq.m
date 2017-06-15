function varargout = bayesLeastSq(varargin)
% est = bayesLeastSq(src, varargin)
%
% Implements a variant of Jazayeri & Shadlen 2010's Bayes least square.
% Assumes bayesLeastSq in the sensory estimation, and MAP in the motor production.
% 
% 2015. Implemented by YK.
[varargout{1:nargout}] = bayesLeastSq(varargin{:});