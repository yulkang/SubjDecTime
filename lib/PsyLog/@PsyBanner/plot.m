function h = plot(me, relS)
if nargin < 2 || isempty(relS)
    on_now = true;
else
    on_now = PsyVis.onnow(relS, me.relSec('on'), me.relSec('off'));
end

if isfield(me.h, 'Banner')
    h = me.h.Banner; 
else
    h = [];
end

if on_now
    if me.draw_box
        me.plot@PsyPTB;
    end
    
    % Draw text centered at me.txtXYDeg.
    try txt        = me.v_.txt{on_now};         catch, txt = me.txt; end
    try me.color   = me.v_.color{on_now};       catch, end
    try txtColor   = me.v_.txtColor{on_now};    catch, txtColor = me.txtColor; end
    try xyDeg      = me.v_.xyDeg{on_now};       catch, xyDeg = me.xyDeg; end
    try txtSizeDeg = me.v_.txtSizeDeg{on_now};  catch, txtSizeDeg = me.txtSizeDeg; end
    try vSpacing   = me.v_.vSpacing{on_now};    catch, vSpacing = me.vSpacing; end
    
    linebreak  = [0, find(txt == sprintf('\n')), (length(txt)+1)];
    nline      = length(linebreak) - 1;
    
    txtSizePoints = norm2real(gca, txtSizeDeg, 'points');
    
    dy   = vSpacing * txtSizeDeg;
    st_y = xyDeg(2) ...
         - (txtSizeDeg * nline + txtSizeDeg * (vSpacing - 1) * (nline - 1)) / 2 ... % Half of the total size
         + txtSizeDeg / 2; % First line's center
    cx   = xyDeg(1);    
    
    %% Show line by line
    if isempty(h)
        h = ghandles(1, nline);
    end
    
    % DEBUG
%     if nline == 5 || on_now == 2 || isequal(find(on_now), 2)
%         keyboard;
%     end
    
    for ii = 1:nline
        ctxt = txt((linebreak(ii)+1):(linebreak(ii+1)-1));
        cy   = st_y + dy * (ii-1);
        
        if length(h) >= ii && isvalidhandle(h(ii))
            set(h(ii), 'String', ctxt, 'Position', [cx, cy], ...
                'FontUnits', 'points', 'FontSize', txtSizePoints, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                'Color', txtColor/255);
        else
            h(ii) = text(cx, cy, ctxt, 'Color', txtColor/255, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                'FontUnits', 'points', 'FontSize', txtSizePoints);
        end
    end
    
    % Remove extra handles
    if length(h) > nline
        delete(h((nline+1):end));
        h((nline+1):end) = [];
    end
    
    % Put at the top
    uistack(h, 'top');
else
    delete(h);
end

me.h.Banner = h;
end