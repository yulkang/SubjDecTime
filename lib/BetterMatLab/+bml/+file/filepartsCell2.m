function varargout = filepartsCell2(varargin)
% pathCell = filepartsCell(src)
%
% pathCell{1} : file name.
% pathCell{2} : extension.
% pathCell{3:end}: path.
%
% See also: file, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.
[varargout{1:nargout}] = filepartsCell2(varargin{:});