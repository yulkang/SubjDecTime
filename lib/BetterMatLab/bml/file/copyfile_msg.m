function varargout = copyfile_msg(a, b, msg, varargin)
% copyfile with message.
% 
% varargout = copyfile_msg(a, b, msg='Copying', varargin)
%
% EXAMPLE:
% >> copyfile_msg('a.mat', 'b.mat')
% Copying a.mat to b.mat

if ~exist('msg', 'var'), msg = 'Copying'; end

varargout = cell(1,nargout);

fprintf('%s %s to %s\n', msg, a, b);

[varargout{:}] = copyfile(a, b, varargin{:});