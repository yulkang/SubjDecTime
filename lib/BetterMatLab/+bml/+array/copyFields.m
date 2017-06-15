function varargout = copyFields(varargin)
% COPYFIELDS : Copies the latter's properties or fields to the former.
%
% obj = copyFields(obj, structOrObjOrDataset)
% obj = copyFields(obj, structOrObjOrDataset, {fieldName1, fieldName2, ...}, 
%                  suppressError=false, excludeFields=false)
% obj = copyFieldsIx(obj, ix, src, fieldNames, suppressError, excludeFields)
%
% If no field names are specified, copies all fields.
%
% If excludeFields = false, copy only the specified fields.
% If excludeFields = true,  copy all fields except the specified fields.
%
% suppressError: 0: rethrow; 1: warn; 2: ignore
%
% See also: copy_fields, data, PsyLib
%
% 2013-2014 (c) Yul Kang. See help PsyLib for the license.
[varargout{1:nargout}] = copyFields(varargin{:});