function cl = file2class(file)
% cl = file2class(file)
%
% Unlike file2pkg, gives the class name even if the file is within 
% the class's folder.

if isempty(file)
    cl = '';
    return;
end
cl = file2pkg(file);

dirs = filepartsCell(file);
if ~isempty(dirs) && (dirs{end}(1) == '@')
    ix_dot = find(cl == '.', 1, 'last');
    cl = cl(1:(ix_dot - 1));
end
end