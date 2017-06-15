function args = varargin2A(args_in, args)
% varargin2A  Replace initial part of a cell array with another cell array.
%
% EXAMPLE:
% varargin2A({'a'}, {'A', 'B'})
% ans = 
%     'a'    'B'
% 
% varargin2A({'a', 'b', 'c'}, {'A', 'B'})
% ans = 
%     'a'    'b'    'c'
% 
% varargin2A({'a', 'b', 'c'})
% ans = 
%     'a'    'b'    'c'
% 
% varargin2A({}, {'A', 'B'})
% ans = 
%     'A'    'B'
%
% See also varargin2V, varargin2S, varargin2C, varargin2fields, arg

if ~exist('args', 'var'), args = {}; end

args(1:length(args_in)) = args_in;