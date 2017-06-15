function[y] = randperg(x,varargin)
% RANDPERG   Random within-group permutation 
% INPUTS   : x - n*1 or 1*n data vector
%            c - n*1 or 1*n group-asignment vector, where c(i) is group
%                of x(i). Groups are identified by distinct values in c
%                (including NaNs). x's are rearranged separately within
%                each  group. RANDPERM is called  if c is omitted. Each
%                group's indexes  in x  are preserved in y; permutation 
%                is thus 'partial'. (But can be made 'full' by adding a
%                RANDPERM call).
% EXAMPLE  : x = rand(5,1)
%            c = unidrnd(2,5,1)
%            y = randperg(x,c)
% SEE ALSO : RANDPERM; PARTPERM (File Exchange)
% AUTHOR   : Dimitri Shvorob, dimitri.shvorob@vanderbilt.edu, 3/25/07

if nargin < 1
   error('Input argument "x" is undefined')
end
if ~isvector(x)
   error('Input argument "x" must be a vector')
end  
if nargin < 2
   i = randperm(length(x));
   y = x(i); 
else
   c = varargin{1}; 
   if ~isvector(c)
      error('Input argument "c" must be a vector')
   end   
   if length(x) ~= length(c)
      error('Input arguments "x" and "c" must be vectors of the same length')
   end   
   u = unique(c);
   m = length(u);
   y = nan*x;
   for j = 1:m
       ij = find(c == u(j));
       ik = randperm(length(ij));
       y(ij) = x(ij(ik));
   end
end   