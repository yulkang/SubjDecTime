function out = cfg_run_file_move(job)

% Move files to another directory or delete them, if no directory is
% specified. Special treatment to move .img/.hdr/.mat pairs of files
% together.
%
% This code is part of a batch job configuration system for MATLAB. See
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id$

rev = '$Rev$'; %#ok

action = fieldnames(job.action);
action = action{1};
if strcmp(action, 'delete')
    for k = 1:numel(job.files)
        [p n e v] = fileparts(job.files{k});
        delete(job.files{k});
        if strcmp(e,'.img') || strcmp(e,'.nii')
            try
                delete(fullfile(p,[n '.hdr']));
                delete(fullfile(p,[n '.mat']));
            end
        end
    end
    out = [];
else
    % copy or move
    if any(strcmp(action, {'copyto','copyren'}))
        cmd = @copyfile;
        if strcmp(action,'copyto')
            tgt = job.action.copyto{1};
        else
            tgt = job.action.(action).copyto{1};
        end
    else
        cmd = @movefile;
        if strcmp(action,'moveto')
            tgt = job.action.moveto{1};
        else
            tgt = job.action.(action).moveto{1};
        end
    end
    if any(strcmp(action, {'copyren','moveren'}))
        patrep = struct2cell(job.action.(action).patrep(:)); % patrep{1,:} holds patterns, patrep{2,:} replacements
        if job.action.(action).unique
            nw = floor(log10(numel(job.files))+1);
        end
    end
    out.files = {};
    for k = 1:numel(job.files)
        [p n e v] = fileparts(job.files{k});
        if numel(e)>=4 && any(strcmp(e(1:4), {'.nii','.img'}))
            try
                [p n e v] = spm_fileparts(job.files{k});
                v = '';
            end
        end
        if any(strcmp(action, {'copyren','moveren'}))
            on = regexprep(n, patrep{1,:}, patrep{2,:});
            if job.action.(action).unique
                on = sprintf('%s_%0*d', on, nw, k);
            end
        else
            on = n;
        end
        nam = {[n e v]};
        onam = {[on e v]};
        if any(strcmp(e, {'.nii','.img'}))
            nam{2}  = [n  '.hdr'];
            onam{2} = [on '.hdr'];
            nam{3}  = [n  '.mat'];
            onam{3} = [on '.mat'];
        end
        for l = 1:numel(nam)
            try
                feval(cmd, fullfile(p, nam{l}), fullfile(tgt, onam{l}));
                out.files{end+1} = fullfile(tgt, onam{l});
            end
        end
    end
end
