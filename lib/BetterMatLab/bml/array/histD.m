function [c, x, hbar, y] = histD(d, varargin)
% histD Counts occurence of unique values, and plot histogram.
% 
% [c, x, h, y] = histD(d, ['opt1', opt1, ...])
%
% d     Data.
% c     Count.
% x     Unique values.
% h     Handle of the plot.
% y     Category index, such that all(x(y) == d) == true.
%
% Options:
%
% 'x'        : Unique values to look for. Defaults to unique(d).
% 'w'        : Weight to each data point.
% 'to_plot'  : Defaults to true.
% 'normalize', false
% 'to_print',  false
% 'h',        []
% 'remove_empty', true
%
% 2013 (c) Yul Kang.

% Input
S = varargin2S(varargin, {
    'to_plot',  nargout == 0
    'x',        []
    'w',        []
    'normalize', false
    'to_print',  false
    'h',        []
    'hori_plot', []
    'remove_empty', true
    }, true);
hax = S.h;
if S.to_plot && isempty(hax), hax = gca; end

% Find out unique repertoire, if not given.
if isempty(S.x)
    S.x = unique(d);
    
    if S.remove_empty && iscell(S.x) && ischar(S.x{1})
        S.x = setdiff(S.x, '');
    end
end
if isempty(S.hori_plot)
    S.hori_plot = iscell(S.x);
end

% Prepare category vector y    
if ~iscell(S.x)
    y = bsxFind(d, S.x); % Categorize.
else
    y = zeros(length(d), 1);
    
    for ii = 1:length(S.x)
        ix = vVec(strcmp(S.x{ii}, d));
        y(ix) = ii;
    end
end
    
% Initialize count
c = zeros(1,length(S.x));

% Unweighted
if isempty(S.w)
    for cx = 1:length(S.x)
        c(cx) = nnz(y==cx);
    end
    
% Weighted
else
    for cx = 1:length(S.x)
        c(cx) = sum(S.w(y==cx));
    end
end

% Normalization
cnorm = c / sum(c);

% Plot
if S.to_plot
    if S.hori_plot
        hbar = barh(hax, 1:length(S.x), c);
        labelname = 'YTickLabel';
    else
        hbar = bar(hax, 1:length(S.x), c);
        labelname = 'XTickLabel';
    end
    
    if verLessThan('matlab', '8.4') || S.hori_plot
        nl = ' ';
    else
        nl = '\\newline';
    end
    
    if isnumeric(S.x)
        set(hax, labelname, csprintf(['%g' nl '(%1.2f%%)'], S.x, cnorm*100));
    else
        set(hax, labelname, csprintf(['%s' nl '(%1.2f%%)'], strrep(S.x, '_', '-'), cnorm*100));
    end
else hbar = [];
end

% Print
if S.to_print
    for ii = 1:length(c)
        if isnumeric(S.x)
            fprintf('%g: ', S.x(ii));
        else
            fprintf('%s: ', S.x{ii});
        end
        fprintf('%d (%1.2f%%)\n', c(ii), cnorm(ii)*100);
    end
end

% Output
if nargout >= 2
    x = S.x;
end