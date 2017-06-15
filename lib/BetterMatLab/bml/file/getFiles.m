function files = getFiles(datFolder, fromFile, toFile, verbose)
% files = getFiles(datFolder, [fromFile, toFile])

if strcmp(datFolder((end-3):end), '.mat')
    filt   = datFolder;
else
    filt   = fullfile(datFolder, '*.mat');
end
files      = dirCell(filt);

if exist('fromFile', 'var') && ~isempty(fromFile)
    ixRange    = strfinds(files, fromFile, 'from');
    files      = files(ixRange);
end

if exist('toFile', 'var') && ~isempty(toFile)
    ixRange    = strfinds(files, toFile, 'to');
    files      = files(ixRange);
end

if ~exist('verbose', 'var') || verbose
    fprintf('Trials collected: %d\n', length(files));
end
