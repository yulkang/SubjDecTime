function file = paste_file
% file = paste_file

found = false;

while ~found
    file = clipboard('paste');
    
    if exist(file, 'file')
        fprintf('Pasted %s\n', file);
        found = true;
    else
        warning('Not found: %s\n', file);
        input('Copy full path to the file and press enter: ', 's');
    end
end