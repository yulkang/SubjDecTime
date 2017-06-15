function tf = bsxStrcmp(c, ptn)
% Many-to-many comparison of strings.
% Performance is better when ptn contains fewer strings.
%
% tf = bsxStrcmp(c, ptn)
%
% c, ptn  : a cell vector of strings.
% tf(k,m) = strcmp(c{k}, ptn{m})
% op = 'raw' (default), 'any', 'all'
%
% See also bsxStrcmp

if nargin < 3, op = 'raw'; end

c   = c(:);

siz = [length(c), length(ptn)];
tf  = false(siz);

for ii = 1:siz(2)
    tf(:,ii) = strcmp(ptn{ii}, c);
end

switch op
    case 'any'
        tf = any(tf, 2);
    case 'all'
        tf = all(tf, 2);
end