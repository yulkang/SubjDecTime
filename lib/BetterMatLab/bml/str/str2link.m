function s = str2link(link, msg)
% s = str2link(link, msg=link)

if nargin < 2, msg = link; end
s = sprintf('<a href="%s">%s</a>', link, msg);