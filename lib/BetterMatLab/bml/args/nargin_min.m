function n = nargin_min(f, nargin_provided)
% nargin_min  Determines number of arguments to pass.
%
% n = nargin_min(f, nargin_provided)
%
% f
% : Function handle.
%
% nargin_provided
% : Maximum number of arguments that can be passed.
%   Typically, nargin or length(varargin) in the caller.
%
% n
% : Number of arguments that can be passed to f.
%
% EXAMPLE:
% function res = test_nargin_min(varargin)
%   f_1 = @(a) a;
%   f_2 = @(a,b) a + b;
%   f_v = @(varargin) sum(cell2mat(varargin));
% 
%   res(1) = f_1(varargin{1 : nargin_min(f_1, nargin)});
%   res(2) = f_2(varargin{1 : nargin_min(f_2, nargin)});
%   res(3) = f_v(varargin{1 : nargin_min(f_v, nargin)});
% end
%
% >> test_nargin(1000, 100, 10, 1)
% ans =
%         1000        1100        1111
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

n = nargin(f);
if n < 0 % varargin is at the end, so the function can handle many outputs.
    n = nargin_provided;
else
    n = min(n, nargin_provided);
end