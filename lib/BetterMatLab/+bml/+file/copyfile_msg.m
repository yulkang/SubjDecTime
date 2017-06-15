function varargout = copyfile_msg(varargin)
% copyfile with message.
% 
% varargout = copyfile_msg(a, b, msg='Copying', varargin)
%
% EXAMPLE:
% >> copyfile_msg('a.mat', 'b.mat')
% Copying a.mat to b.mat
[varargout{1:nargout}] = copyfile_msg(varargin{:});