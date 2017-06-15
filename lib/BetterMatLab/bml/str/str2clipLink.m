function l = str2clipLink(s, msg)
% l = str2clipLink(s, msg)

if nargin < 2, msg = s; end

% l = link4copy(s, msg);

l = sprintf('clipboard(''copy'', ''%s'');', s);
l = cmd2link(l, msg);