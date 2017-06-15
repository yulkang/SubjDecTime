function [diaryFile programName] = beginDiary(folder, programName)
% diaryFile = beginDiary(folder, programName)

if ~exist('programName', 'var') || isempty(programName)
    [~, programName] = fileparts(baseCaller);
    
    if strcmp(programName, 'baseCaller') || ...
            strcmp(programName, 'beginDiary')
        programName = ''; 
    end
end

diaryFile  = fullfile(folder, sprintf('diary_%s_%s.txt', ...
    programName, datestr(now, 'yyyymmddTHHMMSS')));

fprintf('Keeping diary to %s\n', diaryFile);

if ~exist(fileparts(diaryFile), 'dir')
    mkdir(fileparts(diaryFile));
end

diary(diaryFile);
