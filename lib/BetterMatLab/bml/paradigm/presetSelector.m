function [P, nam] = presetSelector(f, nam)
% [P, nam] = presetSelector(f, nam)
%
% f: (1) a directory containing preset.json.txt and params.json.txt, or
%    (2) a cell array {presets, params}, where each is either a path to the file or a struct.

if nargin < 2, nam = ''; end

if ischar(f)
    f = {fullfile(f, 'presets.json.txt'), fullfile(f, 'params.json.txt')};
    [P, nam] = presetSelector(f, nam);
    return;
elseif iscell(f)
    for ii = 1:length(f)
        if ischar(f{ii})
            f{ii} = loadpreset(f{ii}); % Load the struct
        end
    end
else
    error('The first argument should be either a directory or a cell array {presets, params}!');
end    

%% Choose among existing presets
nams = fieldnames(presets);
n    = length(nams);

if n > 0
    for ii = 1:n
        fprintf('  %3d: %s\n', ii, nams{ii});
    end

    ix = nan;
    while ~isinteger(ix) || ix < 0 || ix > n
        ix = input('Choose a preset (0=new): ');
    end 
else
    ix = 0;
end

if ix > 0
    nam = nams{ix};
    P   = presets.(nam);
else
    % Make a new preset
    [P, nam] = paramSelector;
end
end

%% Loadpreset
function loadpreset(f)
    if exist(f, 'file')
        loadjson(f);
    else
        d = fileparts(f);
        if ~exist(d, 'dir')
            mkdir(d);
        end
        
        presets = struct;
        savejson('', presets, f);
    end
end
