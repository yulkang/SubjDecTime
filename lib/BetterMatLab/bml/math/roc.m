function [AUC FPR TPR thres] = roc(v, resp, toPlot)
% ROC   Area under curve of receiver operating characteristic curve.
%
% [AUC FPR TPR] = roc(v, resp, [toPlot=false])

if ~exist('toPlot', 'var'), toPlot = false; end
if numel(v) ~= numel(resp), error('v and resp should match in size!'); end

[~, ix] = sort(v);
resp    = hVec(resp(ix));

n       = length(resp);
nPos    = nnz(resp);
nNeg    = n-nPos;

% true positive rate
TPR     = [1, (nPos - cumsum(resp)) ./ nPos];

% false postivie rate
FPR     = [1, (nNeg - cumsum(~resp)) ./ nNeg];

% area under curve
AUC     = -intNonuni(FPR, TPR); % Minus because FPR decreases with threshold.

% threshold
thres   = [-inf, v];

% plot
if toPlot,
    plot(FPR, TPR);
    xlim([0 1]); xlabel('False Positive Rate');
    ylim([0 1]); ylabel('True Positive Rate');
end

