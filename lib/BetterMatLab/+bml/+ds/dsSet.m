function varargout = dsSet(varargin)
% DSSET Sets dataset values with another dataset without checking key variables.
%       Useful for initialization.
%
% DS = dsSet(DS, DAT, [VARNAME1, VARNAME2, ...])
%
% DS      : Dataset.
% DAT     : Scalar, row or column vector matching ds's size, or matrix.
% VARNAME : Optional. Give all or none. If omitted, all varNames of DS is used.
%
% tt = dataset({nan(0,2), 'a', 'b'})
% tt = 
%    empty 0-by-2 dataset
% 
% tt = dsSet(tt, nan(5,1))
% Warning: Observations with default values added to dataset variables. 
% > In dataset.subsasgn at 584
%   In dsSet at 26 
% tt = 
%     a      b  
%     NaN    NaN
%     NaN    NaN
%     NaN    NaN
%     NaN    NaN
%     NaN    NaN
%
% See also: JOIN, REPLACEDATA, ds_set
[varargout{1:nargout}] = dsSet(varargin{:});