function [CEsum mCE cCE succEv LLR] = EnCols(src, propRep, objName)
% [CEsum mCE cCE succEv LLR] = EnCols(src, propRep, objName)
%
% src: Cell array of trial file names.
% propRep: A repertoire of color proportions.
% objName: Defaults to 'RDKCol'.
%
% CEsum: N x 1 vector of summed color energy
% mCE  : N x F matrix of momentary color energy
% cCE  : N x F matrix of cumulative color energy
% succEv: Whether calculating color energy succeeded.
% LLR  : Used repeatedly for CE computation.
%
% See also PsyRDKCol.EnCol.

tic;
n = length(src);
succEv = false(n,1);

if ~exist('objName', 'var'), objName = 'RDKCol'; end

%% Parallelize
try
    matlabpool open
catch lastErr
    warning(lastErr.message);
end

%% First successful trial
succSt = false;
for st = 1:n
%     try
        S = load(src{st}, objName);
        
        [cCESum, cMCE, cCCE, ~, LLR] = S.(objName).EnCol([], propRep);
        
        if isnan(cCESum) || isempty(cMCE) || isempty(cCCE)
            error('Unfeasible results.');
        end 
        
        CEsum  = zeros(n,1);
        mCEs   = cell(n,1);
        cCEs   = cell(n,1);
        
        fprintf('Will use %s as a template.\n', src{st});
        succSt = true;
        
        break;
%     catch
%         fprintf('Error calculating CE from %s\n', src{st});
%     end
end

if ~succSt
    error('No trial was feasible for calculating CE!');
end

%% Subsequent trials
parfor ii = st:n
%     try
        S = load(src{ii}, objName);
        
        [cCESum, cMCE, cCCE] = S.(objName).EnCol(LLR, propRep);
        
        if isnan(cCESum) || isempty(cMCE) || isempty(cCCE)
            error('Unfeasible results.');
        end
        
        CEsum(ii) = cCESum;
        mCEs{ii}  = hVec(cMCE);
        cCEs{ii}  = hVec(cCCE);
        
        succEv(ii) = true;
        fprintf('Succeeded calculating CE from %s\n', src{ii});
        
%     catch
%         warning('Error calculating CE from %s\n', src{ii});
%     end
end

%% Tidy up results
maxLen = max(cellfun(@length, mCEs));
mCE = zeros(n, maxLen);
cCE = zeros(n, maxLen);

for ii = 1:n
    mCE(ii, 1:length(mCEs{ii})) = mCEs{ii};
    cCE(ii, 1:length(cCEs{ii})) = cCEs{ii};
end

%% Summarize results
fprintf('Calculated CE from %d trials out of %d trials in %1.3fs.', ...
    nnz(succEv), n, toc);
