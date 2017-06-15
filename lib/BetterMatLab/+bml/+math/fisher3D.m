function varargout = fisher3D(varargin)
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
[varargout{1:nargout}] = fisher3D(varargin{:});