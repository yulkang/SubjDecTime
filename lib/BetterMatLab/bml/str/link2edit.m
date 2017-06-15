function s = link2edit(file)
% Return link string to edit the file.
%
% EXAMPLE:
% disp(link2edit('link2edit'));
s = cmd2link(sprintf('edit(''%s'');', file), file);