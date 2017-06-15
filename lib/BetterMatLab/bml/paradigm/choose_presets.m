function [todos, prst] = choose_presets(selections, varargin)
% todos: cell vector of structs (P's)

S = varargin2S(varargin, {
    'rootdir', 'Data/presets_'
    'subdir', 'default'
    });

dirPreset = fullfile(S.rootdir, S.subdir, 'presets_');

if exist(dirPreset, 'dir')
    presets = dirfiles(dirPreset);
    [~,presetNams] = filepartsAll(presets);
else
    presets = {};
    presetNams = {};
end

if ischar(selections)
    fileSel = fullfile(S.rootdir, S.subdir, 'selections.mat');
    selections = load(fileSel, '-struct');
else
    assert('selections must be a struct or a file name!');
end
    
%%
prst = input_defs('Choose one or more preset(s)', ...
    'choices', [presetNams(:); {'new_'}]);

n = length(prst);
todos = cell(1,n);

for ii = 1:n
    if strcmp(prst{ii}, 'new_')
        fprintf('Making a preset #%d\n', ii);
        if inputYN_def('Copy an existing preset', ~isempty(presets))
            [~,pIx] = input_defs('Choose a preset', presetNams, 'maxN', 1);
            pFile = presets{pIx};
            P = load(pFile, 'P', '-struct');
        else
            P = struct;
        end
        todos{ii} = make_selections(selections, P);
    else
        todos{ii} = selections.(prst{ii});
    end
end

function P = make_selections(selections, P)
% P = make_selections(selections, P)

if nargin < 2 || isempty(P), P = struct; end

sels = fieldnames(selections)';

selIncl = {'init_'};
while ~isequal(selIncl, {'finish_'})
    selIncl = input_defs('Choose selections to make', ['inspect_', 'finish_', sels(:)]);
    nselIncl = length(selIncl);
    
    for isel = 1:nselIncl
        cselNam = selIncl{isel};
        csel = selections.(cselNam);
        
        if strcmp('inspect_', cselNam)
            openvar(selections);
            continue;
        end
        if strcmp('finish_', cselNam)
            selIncl = {'finish_'};
            break;
        end
    
        choices = setdiff(fieldnames(csel), 'default_');
        if isfield(csel, 'default_')
            def = csel.default_;
        else
            def = nan;
        end
        ch = input_defs(cselNam, choices, 'maxN', 1, 'def', def);
        
        P = varargin2S(P, csel.(ch));
    end
end

f_prs = @(nam) fullfile(S.rootDir, S.subdir, '_presets_', [nam '.mat']);

pNam = [];
while isempty(pNam) || exist(f_prs(pNam), 'file')
    pNam = input_def('Enter a unique name for the new preset');
end
save(f_prs(pNam), 'P', '-struct');
end
end