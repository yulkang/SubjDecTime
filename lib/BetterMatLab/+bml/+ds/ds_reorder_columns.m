function varargout = ds_reorder_columns(varargin)
% ds = ds_reorder_columns(ds, src, dst, [is_bef = true])
%
% EXAMPLE:
%
% >> ds = dataset({1, 'a'}, {'B', 'b'}, {3, 'c'}, {4, 'd'})
% ds = 
%     a    b    c    d
%     1    B    3    4
% 
% >> ds = ds_reorder_columns(ds, 'b', 'd')
% ds = 
%     a    c    b    d
%     1    3    B    4
% 
% >> ds = ds_reorder_columns(ds, {'a', 'b'}, '_end')
% ds = 
%     c    d    a    b
%     3    4    1    B
% 
% >> ds = ds_reorder_columns(ds, {'a', 'd'}, '_begin') 
% ds = 
%     a    d    c    b
%     1    4    3    B
[varargout{1:nargout}] = ds_reorder_columns(varargin{:});