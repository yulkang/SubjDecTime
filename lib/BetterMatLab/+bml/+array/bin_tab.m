function varargout = bin_tab(varargin)
% BIN_TAB - Returns a dataset of T/F with colums of unique entries in C.
%
% ds = bin_tab(c)
%
% EXAMPLE:
% >> bin_tab({'a', 'b', 'c', 'a'})
% ans = 
%     a        b        c    
%     true     false    false
%     false    true     false
%     false    false    true 
%     true     false    false
[varargout{1:nargout}] = bin_tab(varargin{:});