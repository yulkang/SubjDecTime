function tf = bsxStrcmpi(c, ptn, op)
% Many-to-many comparison of strings.
% Performance is better when ptn contains fewer strings.
%
% tf = bsxStrcmpi(c, ptn, [op])
%
% c, ptn  : a cell vector of strings.
% tf(k,m) = strcmpi(c{k}, ptn{m})
% op = 'raw' (default), 'any', 'all'
%
% See also bsxStrcmp

if nargin < 3, op = 'raw'; end

c   = c(:);

siz = [length(c), length(ptn)];
tf  = false(siz);

for ii = 1:siz(2)
    tf(:,ii) = strcmpi(ptn{ii}, c);
end

switch op
    case 'any'
        tf = any(tf, 2);
    case 'all'
        tf = all(tf, 2);
end