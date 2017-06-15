function varargout = files2ds(varargin)
% lst = files2ds(files, cols, varargin)
%
% cols: {columnName, funHandle}
% funHandle
% : @() 
% : @(L)   L: loaded variables and previously calculated columns
% : @(L,f) f: outputs from filepartsCell2.
% 
% OPTIONS
% -------
% 'loadOpt',      {}
% 'cachePth',     'Data/files2ds/cache'
% 'cache',        'cache'
% 'skipOld',      true
% 'removeLoaded', true      % true, false, or cell array
%
% OUTPUT
% lst.file_ : relative path to the file
% lst.date_ : date modified.
%
% See also filepartsCell2.
[varargout{1:nargout}] = files2ds(varargin{:});