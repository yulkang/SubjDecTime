function cLim = xylim_robust_auto(varargin)
% lim_aft = xylim_robust_auto(varargin)
%
% 'h', []
% % method:
% % 'std': mean +- std * fac
% % 'dif': [min - range * margin(1), max + range * margin(2)]
% 'method', 'std' 
% 'axis', 'y'
% 'margin', [0, 0.1]
% 'fac', [3 3]
% 'lim0', [-eps, eps]
    
S = varargin2S(varargin, {
    'h', []
    % method:
    % 'std': mean +- std * fac
    % 'dif': [min - range * margin(1), max + range * margin(2)]
    'method', 'std' 
    'axis', 'y'
    'margin', [0, 0.1]
    'fac', [3 3]
    'lim0', [-eps, eps]
    });

if isempty(S.h), S.h = gca; end

%%
l = findobj(S.h, 'Type', 'Line');
cLim = S.lim0;
switch S.axis
    case 'x'
        oLim = ylim;
        cSrc = get(l, 'XData');
        oSrc = get(l, 'YData');
    case 'y'
        oLim = xlim;
        cSrc = get(l, 'YData');
        oSrc = get(l, 'XData');
end
if isscalar(l)
    cSrc = {cSrc};
    oSrc = {oSrc};
end

n = length(l);
for ii = 1:n
    c = cSrc{ii};
    o = oSrc{ii};
    incl = (o >= oLim(1) & (o <= oLim(2))); 
    if isempty(c), continue; end
    c = c(incl);
    o = o(incl);
    
    switch S.method
        case 'std'
            m = nanmean(c);
            e = nanstd(c);
            cLim(1) = min(cLim(1), m - e * S.fac(1));
            cLim(2) = max(cLim(2), m + e * S.fac(2));
        case 'dif'
            cMax = nanmax(c(~isnan(o)));
            cMin = nanmin(c(~isnan(o)));
            cRange = cMax - cMin;
            cLim(1) = min(cLim(1), cMin - cRange * S.margin(1));
            cLim(2) = max(cLim(2), cMax + cRange * S.margin(2));
        otherwise
            error('Unknown method!');
    end
end

switch S.axis
    case 'x'
        xlim(S.h, cLim);
    case 'y'
        ylim(S.h, cLim);
end