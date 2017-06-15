function files = copyIfNone(files, toSubFolder)
% files = copyIfNone(files, toSubFolder)

for ii = 1:length(files)
    resFile = replaceFolder(files{ii}, toSubFolder);
    
    if ~exist(resFile, 'file')
        if ~exist(fileparts(resFile), 'dir')
            mkdir(fileparts(resFile));
            fprintf('Made folder %s\n', fileparts(resFile));
        end
        
        copyfile(files{ii}, resFile);
        fprintf('Copied %s to %s.\n', files{ii}, resFile);
    end
    
    files{ii} = resFile;
end
