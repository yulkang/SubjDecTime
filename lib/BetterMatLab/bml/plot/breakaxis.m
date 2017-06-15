function [hOccl, hLine] = breakaxis(ax, xy, win, varargin)

error('Not implemented yet!');

S = varargin2S(varargin, {
    'len', 0.5 % In proportion to the gap size, win(2) - win(1).
    'deg', 60
    'lineOpt', {'k-'}
    });

if isempty(ax), ax = gca; end

switch xy
    case 'x'
        cLim  = xlim(ax);
        oLim  = ylim(ax);
        oLim1 = oLim + diff(oLim) .* [-0.1, 0.1];
        
%         hOccl = plot(ax, win, oLim([1 1]), 'w', 'LineWidth', 2);
        hOccl = patch([win(:); flipud(win(:))], vVec(oLim1([1 1 2 2])), 'w', 'EdgeColor', 'w');
        hold on;
        
        gap = win(2) - win(1);
        len = gap * S.len;
        [dx, dy] = pol2cart(S.deg / 180 * pi, len);
        
        hLine = plot(bsxfun(@plus, [-dx; +dx], win(:)'), bsxfun(@plus, [-dy; +dy], hVec(oLim([1 1]))), ...
            S.lineOpt{:});
        xlim(cLim);
        ylim(oLim);
        
    case 'y'
        error('Not implemented yet!');
end