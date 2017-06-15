function [v sCont] = optStop(f, P, c, d, toPlot, nIter)
% OPTSTOP Optimal stopping strategy for a Markov chain
%
% [v sCont sStop] = optStop(f, P, [c=0, d=1, toPlot=true, nIter=100])
%
% f      : n-vector of the payoff of each state.
% P      : n-by-n transition matrix.
%          P(i,j) is the probability of transition from state i to j.
% c      : cost of continuing from each state. 
%          Scalar or n-vector. Defaults to zero.
% d      : scalar discount factor. Defaults to 1.
% toPlot : whether to plot on each iteration. Defaults to true.
% nIter  : maximum number of iterations. Defaults to 100.
%
% v      : n-vector of optimal expected payoff starting from each state.
% sCont  : logical n-vector continuing region. True if continue.
%
% Coded by Yul Kang 2013. hk2699 at columbia dot edu.
% Reference:
%   Lawler 2006, Introduction to Stochastic Processes, 2nd ed., Chapter 4.

f = f(:);
n = length(f);

if ~exist('c', 'var')
    c = zeros(n,1);
elseif length(c) == 1 % Expand if scalar.
    c = zeros(n,1) + c;
else
    c = c(:);
end
if ~exist('d', 'var'),      d      = 1;    end
if ~exist('toPlot', 'var'), toPlot = true; end
if ~exist('nIter', 'var'),  nIter  = 100;  end

%% Initialize v
% Something that we're sure that is superharmonic, i.e., v >= P*v 
v       = zeros(n,1) + max(f);

% Absorbing states have the same expected payoff as its own payoff.
sAbs    = arrayfun(@(ii) P(ii,ii)==1, 1:n); 
v(sAbs) = f(sAbs); 

%% Iterate
for ii = 0:nIter
    if ii > 0
        % Find out the minimum v that is superharmonic.
        v = max(d*P*v - c, f);
    end
    
    if toPlot
        plot((1:n)', v, 'b.-', (1:n)', f, 'r.-');
        tt = input('Continue (enter) / Finish (q): ', 's');
        commandwindow;
        if tt == 'q', break; end
    end
end

% Continue if the expected payoff of continuing is greater than 
% the current state's payoff.
sCont = v > f;

%% Display
if toPlot
    fprintf('After %d iteration:\n', ii);
    disp(v');
    disp(sCont');
end
