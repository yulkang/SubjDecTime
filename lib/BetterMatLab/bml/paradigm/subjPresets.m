function [P, nam] = subjPresets(subj)

% Find among existing
if exist('Data/subjects.csv', 'file')
    dsSubj = dataset('Data/subjects.csv', 'File', 'delimiter', ',');
else
    cdatestr = datestr(now, 'yyyymmddTHHMMSS.FFF');
    dsSubj = cell2ds2({
            'subj', 'parad', 'first', 'last'
            subj,   '',      cdatestr, cdatestr});
end

% 
if any(strcmp(subj, dsSubj.subj))
else
end

% Make sure the subject's directory exists.
if ~exist(subj, 'dir')
    mkdir(subj);
end

% Get subdirs.
d       = dir(subj);
subdirs = {d.name};
subdirs = subdirs([d.isdir]);

% Get existing preset names.
if exist('presets.json.txt', 'file')
    presets = loadjson('presets.json.txt');
else
    try
        presets = initPresets;
    catch
        disp('Supply initPresets in the pwd or on the MATLBA path following paramSelectorExample.');
        presets = struct;
    end
end
preset_names = fieldnames(presets);

% Choose among presets recorded for the subject.
subdirs = intersect(preset_names, subdirs, 'stable'); % Follow the order of preset_names.
if ~isempty(subdirs)
    nam = input_def('Choose among existing presets for %s. Too choose/make a new one, choose ''new_''', ...
        'choices', [subdirs(:)', {'new_'}], ...
        'default', subdirs{end});
    
    if ~strcmp(nam, 'new_')
        P   = evalfields(presets.(nam));
        return;
    end
end

% Choose a new preset for the subject.
[P, nam] = presetSelector('Data');
