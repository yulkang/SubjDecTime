function [lim1 lim2] = sameScale(h, xy)
% [lim1 lim2] = sameScale(h, xy='x'|'y'|'xy')

if ~exist('xy', 'var'), xy = 'xy'; end

lim1 = [inf -inf];
lim2 = [inf -inf];

switch xy
    case 'xy'
        lim1 = sameScale(h, 'x');
        lim2 = sameScale(h, 'y');
        return;
        
    case 'x'
        fLim = @(cArg) xlim(cArg);
        
    case 'y'
        fLim = @(cArg) ylim(cArg);        
end

for cH = h(:)'
    cLim = fLim(cH);
    lim1(1) = min(lim1(1), cLim(1));
    lim2(2) = max(lim1(2), cLim(2));
end

for cH = h(:)'
    fLim(cH, cLim);
end
