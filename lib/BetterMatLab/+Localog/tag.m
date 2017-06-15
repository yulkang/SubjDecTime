function dst = tag(files, tg, op, varargin)
if nargin < 3 || isempty(op)
    op = 'set';
else
    op = 'get';
end

%% Choose files
if nargin < 1 || isempty(files) || (ischar(files) && exist(files, 'dir'))
    if ischar(files) && exist(files, 'dir')
        filt = files;
    else
        filt = 'Data';
    end
    
    switch op
        case 'set'
            prompt = 'Choose files in _bak folder to tag';
        case 'get'
            prompt = 'Choose files in _tag folder to retrieve';
    end
    
    [nams, pth] = uigetfile(filt, prompt);
    files = fullfile(pth, nams);
else
    assert(iscellstr(files), 'Give empty, common dir, or a cellstr of files!');
    [pth, nams, ext] = filepartsAll(files);
    pth = pth{1};
    nams = cellfun(@(nm, ex) [nm, ex], nams, ext, 'UniformOutput', false);
end

%% Show existing tags
tag_root = fullfile(pth, '../_tag');
if ~exist(tag_root, 'dir')
    mkdir(tag_root);
end

try
    d = rdir(tag_root, @(d) d.isdir);
    fprintf('Existing tags:\n');
    cfprintf('%s\n', {d.name});
catch
    fprintf('No existing tags found in %s/../_tag folder.\n', pth);
end

%% Determine tag
if nargin < 2 || isempty(tg)
    tg = input_def('Tag');
end
   
%%
switch op
    case 'set'
        while isempty(tg)
            if exist(fullfile(tag_root, tg), 'dir')
                if ~inputYN_def(sprintf('Overwrite %s', tg), false)
                    tg = '';
                end
            end
        end
        
        %% Copy files into the tag folder
        src_pth = pth;
        src_hdr = fullfile(src_pth, '_hdr');
        dst_pth = fullfile(tag_root, tg);
        dst_hdr = fullfile(dst_pth, '_header');

        n = numel(files);
        dst = cell(size(files));
        for ii = 1:n
            dst{ii} = fullfile(dst_pth, nams{ii});            
            fprintf('%s to %s\n', files{ii}, dst{ii}); % DEBUG
%             copyfile2(files{ii}, dst{ii}, true);

            src_hdr_file = fullfile(src_hdr, [nams{ii}, '.json.txt']);
            dst_hdr_file = fullfile(dst_hdr, [nams{ii}, '.json.txt']);
            fprintf('%s to %s\n', src_hdr_file, dst_hdr_file); % DEBUG
%             copyfile2(src_hdr_file, dst_hdr_file, true);
        end
        
    case 'get'
        while isempty(tg)
            if ~exist(fullfile(tag_root, tg), 'dir')
                tg = '';
            end
        end
        
        %% Copy files into the main folder
        dst_pth = fullfile(tag_root, '..');

        n = numel(files);
        dst = cell(size(files));
        for ii = 1:n
            dst{ii} = fullfile(dst_pth, Localog.truncate_from_datestr(nams{ii}));
            fprintf('%s to %s\n', files{ii}, dst{ii}); % DEBUG
%             copyfile2(files{ii}, dst{ii}, true);
        end
end

