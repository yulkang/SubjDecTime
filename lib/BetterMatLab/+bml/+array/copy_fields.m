function varargout = copy_fields(varargin)
% copy_fields  Copy fields of a struct or a dataset.
%
% dst = copy_fields(dst, src, 'all_recursive') (default)
% dst = copy_fields(dst, src, 'all', [fields])
% dst = copy_fields(dst, src, 'except_existing', [fields])
% dst = copy_fields(dst, src, 'existing_only', [fields])
% ... = copy_fields(..., [catch_error = false])
%
% 2013 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = copy_fields(varargin{:});