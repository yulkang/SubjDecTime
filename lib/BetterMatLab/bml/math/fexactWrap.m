function varargout = fexactWrap(tf1, tf2, varargin)
% [p a K C] = fexactWrap(tf1, tf2, varargin)
%
% Comments copied from FEXACT:
%
% a(i) is the upper left square of the contingency
%     corresponding to the ith column of X crosstabulated by y. 
% K is a vector containing a+b for the ith column of X.
% C is a lookup table for CDFs that can be used in subsequent calls
%     to fexact to further improve performance.
%     C( x(i)+1, K(i)+1) is the cdf for the tail specified in
%     options. 
%     NB. this lookup table is only for the given M and N values
%
% See also FEXACT

a = nnz(tf1 & tf2);
M = length(tf1);
K = nnz(tf1);
N = nnz(tf2);

[varargout{1:nargout}] = fexact(a, M, K, N, varargin{:});
end