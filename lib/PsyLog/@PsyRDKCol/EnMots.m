function [MEsum mME cME succEv MFilt] = EnMots(src, varargin)
% [MEsum mME cME succEv MFilt] = EnMots(src, ['objName', 'RDKCol', ...])
%
% src: Cell array of trial file names.
% objName: Defaults to 'RDKCol'.
%
% MEsum: N x 1 vector of summed motion energy
% mME  : N x F matrix of momentary motion energy
% cME  : N x F matrix of cumulative motion energy
% succEv: Whether calculating motion energy succeeded.
% MFilt : A PsyMotionFilter object that can be reused for another calculation.
%
% See also PsyRDKCol.EnMot.

tic;
n = length(src);
succEv = false(n,1);

objName = 'RDKCol';
varargin2V(objName);

%% Parallelize
try
    matlabpool open
catch lastErr
    warning(err_msg(lastErr));
end

%% First successful trial
succSt = false;
for st = 1:n
    try
        S = load(src{st}, objName);

        MFilt = PsyMotionFilter(S.(objName));
        
        [cMESum, cMME, cCME] = S.(objName).EnMot(MFilt);
        
        if isnan(cMESum) || isempty(cMME) || isempty(cCME)
            error('Unfeasible results.');
        end
        
        MEsum  = zeros(n,1);
        mMEs   = cell(n,1);
        cMEs   = cell(n,1);
        
        fprintf('Will use %s as a template.\n', src{st});
        succSt = true;
        
        break;
    catch
        fprintf('Error calculating ME from %s\n', src{st});
    end
end

if ~succSt
    error('No trial was feasible for calculating ME!');
end

%% Subsequent trials
parfor ii = st:n
    try
        S = load(src{ii}, objName);
        
        [cMESum, cMME, cCME] = S.(objName).EnMot(MFilt);
        
        if isnan(cMESum) || isempty(cMME) || isempty(cCME)
            error('Unfeasible results.');
        end
        
        MEsum(ii) = cMESum;
        mMEs{ii}  = hVec(cMME);
        cMEs{ii}  = hVec(cCME);
        
        succEv(ii) = true;
        fprintf('Succeeded calculating ME from %s\n', src{ii});
        
    catch
        warning('Error calculating ME from %s\n', src{ii});
    end
end

%% Tidy up results
maxLen = max(cellfun(@length, mMEs));
mME = zeros(n, maxLen);
cME = zeros(n, maxLen);

for ii = 1:n
    mME(ii, 1:length(mMEs{ii})) = mMEs{ii};
    cME(ii, 1:length(cMEs{ii})) = cMEs{ii};
end

%% Summarize results
fprintf('Calculated ME from %d trials out of %d trials in %1.3fs.', ...
    nnz(succEv), n, toc);
