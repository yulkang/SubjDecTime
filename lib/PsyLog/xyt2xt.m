function [x y t] = xyt2xt(xyt, toPlot, plotArgs)
% [x y t] = xyt2xt(xyt, toPlot, {plotArgs}, yMin, yMax)
%
% xyt    : 2 x nDot x T
% yBin   : 1 x nBinY, ending at max(y). -inf is appended to the left.
% toPlot : true to plot.
%
% x      : T x nDot double.
% t      : T x nDot double.

if isempty(xyt)
    warning('Empty xyt!');
    x = [];
    t = [];
    return;
end

if ~exist('toPlot', 'var'), toPlot = true; end
if ~exist('plotArgs', 'var')
    plotArgs = {};
end

nDot    = size(xyt, 2);
T       = size(xyt, 3);
x       = squeeze(permute(xyt(1,:,:), [3 2 1])); % now t x dot
y       = squeeze(permute(xyt(1,:,:), [3 2 1])); % now t x dot
    
t       = repmat((1:T)', [1 nDot]);

if toPlot
    plot(x, t, 'k.', plotArgs{:});
    
    [ixT ixX] = find(diff(y, 1, 1) == 0);
    
    ind0 = sub2ind(size(x), ixT, ixX);
    ind1 = sub2ind(size(x), ixT+1, ixX);
    
    xPair = [reshape(x(ind0), 1, []); reshape(x(ind1), 1, [])];
    tPair = [reshape(t(ind0), 1, []); reshape(t(ind1), 1, [])];
    plot(xPair, tPair, 'k-', plotArgs{:});
end
    