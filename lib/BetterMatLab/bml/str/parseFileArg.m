function [file, fShort] = parseFileArg(fileArg)
% [file, fShort] = parseFileArg(fileArg)
%
% fileArg: Any of
%   'name'
%   'path/name'
%   'path/name_yyyymmddTHHMMSS'
%   {'', 'name'}
%   {'path1', 'path2', ..., 'name'}
%   {'path1', 'path2', ..., 'name', now}
%   {'path1', 'path2', ..., 'name', datestr}
%
% It is then converted to
%
%   file   = path1/path2.../basecallerName_name_yymmddTHHMMSS
%   fShort = name
%
% See also: SAVELOG, PRINTLOG, BASECALLER, DATESTR, ISDATESTR.

if ischar(fileArg)
    [filePath, fShort] = fileparts(fileArg);
    
    if isempty(regexp(fShort, '.*d\{8,8}T\d{6,6}', 'once'))
        filePost = sprintf('%s_%s', fShort, datestr(now, 'yymmddTHHMMSS'));
    else
        filePost = fShort;
    end

elseif iscell(fileArg)
    if isnumeric(fileArg{end})
        fileTime = datestr(fileArg{3}, 'yymmddTHHMMSS');
        dateArg  = 1;
        
    elseif isdatestr(fileArg{end}, 'post')
        fileTime = fileArg{3};
        dateArg  = 1;
        
    else
        fileTime = datestr(now, 'yymmddTHHMMSS');
        dateArg  = 0;
        
    end
    filePath    = fullfile(fileArg{1:(end-1-dateArg)});
    fShort      = fileArg{end-dateArg};
    
    filePost = sprintf('%s_%s', fShort, fileTime);
else
    error('saveLog:WrongPostFix', 'Unparseable file name!');
end

[basePath, baseFName] = fileparts(baseCaller);

% If the path is unspecified, use basecaller's path.
if isempty(filePath)
    outPath = basePath;
else
    outPath = filePath;
end
outFile = fullfile(outPath, baseFName);

% Make the folder if absent.
if ~exist(outPath, 'dir'), mkdir(outPath); end

% Compile file name.
file = sprintf('%s_%s', outFile, filePost);
end