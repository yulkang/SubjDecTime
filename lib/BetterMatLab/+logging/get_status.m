function [anyChange, toAdd, toStage, toCommit, status, allOutput] = get_status(inDir_src, verbose)
% get_status  Return status of Git repos.
%
% [anyChange, toAdd, toStage, toCommit, status, allOutput] = get_status(inDir, verbose)
%
% See also logging, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

import Ext.git

if ~exist('verbose', 'var'), verbose = false; end

prevDir = pwd;

if nargin == 0, inDir_src = pwd; end
inDir = arg2cell(inDir_src);

status(length(inDir)) = ...
    struct('anyChange', [], 'toAdd', [], 'toStage', [], 'toCommit', [], 'allOutput', []);

for ii = 1:length(inDir)
    cd(inDir{ii});
    
    allOutput = git('status');
    if verbose
        fprintf(fullfile(inDir{ii}, 'git status\n'));
        fprintf('%s\n', allOutput);
    end

    toAdd     = ~isempty(strfind(allOutput, 'Untracked files:'));
    toStage   = ~isempty(strfind(allOutput, 'Changes not staged for commit:'));
    toCommit  = ~isempty(strfind(allOutput, 'Changes to be committed:'));

    anyChange = toAdd || toStage || toCommit;
    
    status(ii) = packStruct(anyChange, toAdd, toStage, toCommit, allOutput);
    
    cd(prevDir); 
end

anyChange = [status.anyChange];
toAdd     = [status.toAdd];
toStage   = [status.toStage];
toCommit  = [status.toCommit];
allOutput = {status.allOutput};
end