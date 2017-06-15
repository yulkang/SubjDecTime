function [p, LLRn, LLRt, histCount, histX] = fisher3D(N, T, tail, nRep, toPlot)
% fisher3D: examines 3-way interaction in a 2x2x2 contingency table.
% 
% [p, LLRn, LLRt, histCount, histX] = fisher3D(m, tail, nRep)
%
% N        : the null distribution, [a b; c d].
% T        : the distribution of interest (Data), [A B; C D].
% tail     : 'l', 'r', or 'b', comparing log-likelihood ratio of the
%             data to the null.
% nRep     : the number of repetitions in simulation (Defaults to 1e6).
% toPlot   : set true to plot (defaults to true).
% 
% p        : the probability of observing log-likelihood ratio at least
%             as extreme as the data.
% LLRn     : the log-odds ratio of the null, log((d/c)/(b/a)).
% LLRt     : the log-odds ratio of the data, log((D/C)/(B/A)).
% histCount: count of the histogram
% histX    : center of each bin

if nargin < 3
    tail = 'b';
end
if nargin < 4
    nRep = 1000000;
end
if nargin < 5
    toPlot = true;
end

nT   = sum(T(:)); % Total number of trials in target.

% Null distribution
cumN = cumsum(N(:))./sum(N(:));

% Simulation.
simT = squeeze( ...                 % nRep x nT of 1..4.
        sum( ...                    % nRep x 1 x nT of 1..4
         bsxfun(@le, ...            % [1 0 0 0], [1 1 0 0], [1 1 1 0], or [1 1 1 1].
           rand(nRep, 1, nT), ...   % one 0..1 number per simulation per total number of trials in target.
           cumN(:)'), ...           % compare to cumN on 2nd dimension
         2));

nSimT = zeros(nRep,4);
for ii = 1:4
    nSimT(:,ii) = sum(simT == ii,2); % Count 1..4.
end
nSimT = reshape(nSimT, [nRep, 2, 2]);

% calculate LLRn
LLRn = (log(N(2,2)) - log(N(2,1))) - (log(N(1,2)) - log(N(1,1)));
LLRs = (log(nSimT(:,2,2)) - log(nSimT(:,2,1))) ...
     - (log(nSimT(:,1,2)) - log(nSimT(:,1,1)));
LLRt = (log(T(2,2)) - log(T(2,1))) ...
     - (log(T(1,2)) - log(T(1,1)));

switch tail
    case 'b'
        p = nnz(abs(LLRs-LLRn) >= abs(LLRt-LLRn)) / nRep;
        
    case 'l'
        p = nnz(LLRs <= LLRt) / nRep;
        
    case 'r'
        p = nnz(LLRs >= LLRt) / nRep;
end

if toPlot
    histLLRs = LLRs;
    histLLRs(LLRs== inf) = max(histLLRs(isfinite(histLLRs)));
    histLLRs(LLRs==-inf) = min(histLLRs(isfinite(histLLRs)));

    if nargout>=4
        [histCount, histX] = hist(histLLRs, 40);
    else
        hist(histLLRs, 40);
        vertLine(LLRn, 'k-');
        vertLine(LLRt, 'b-');
    end
end