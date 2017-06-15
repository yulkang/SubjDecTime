function res = test_nargin_min(varargin)
% EXAMPLE:
% >> test_nargin(1000, 100, 10, 1)
% ans =
%         1000        1100        1111
%
% See also nargin_min

  f_1 = @(a) a;
  f_2 = @(a,b) a + b;
  f_v = @(varargin) sum(cell2mat(varargin));

  res(1) = f_1(varargin{1 : nargin_min(f_1, nargin)});
  res(2) = f_2(varargin{1 : nargin_min(f_2, nargin)});
  res(3) = f_v(varargin{1 : nargin_min(f_v, nargin)});
end
