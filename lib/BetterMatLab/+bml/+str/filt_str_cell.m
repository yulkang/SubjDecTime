function varargout = filt_str_cell(varargin)
% [res, filtered] = filt_str_cell(str_cell, filt, filt_in)
%
% str_cell : cell of strings to filter
% filt     : cell of string patterns
% filt_in  : if false (default), filters out strings containing any of filt.
% res      : filtered strings.
% filtered : logical index of filtered strings, such that res = str_cell(filtered).
[varargout{1:nargout}] = filt_str_cell(varargin{:});