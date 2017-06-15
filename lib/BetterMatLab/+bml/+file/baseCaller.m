function varargout = baseCaller(varargin)
% [res, callStack, ix, res_name_only, readable_full, readable_name] = baseCaller([exclude_names], ['opt1', opt1, ...])
% exclude_names : files/functions not to consider as a baseCaller.
%
% OPTIONS:
% -----------------------
% 'base_fallback', 'base', ... % 'pwd', 'guess', 'base' ('guess': guess from current editor file)
%
% See also: file, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.
[varargout{1:nargout}] = baseCaller(varargin{:});