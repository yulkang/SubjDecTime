function h = plot(PTB, relS)
% h = plot(PTB, relS)

if nargin < 2 || isempty(relS)
    on_now = true;
else
    on_now = PsyVis.onnow(relS, PTB.relSec('on'), PTB.relSec('off'));
end

color = PTB.color;
if size(color, 1) == 1
    color = color';
end

if isfield(PTB.h, 'PTB') && all(isvalidhandle(PTB.h.PTB))
    h = PTB.h.PTB;
else
    h = [];
end

if on_now % && (isempty(PTB.h) || ~isvalid(PTB.h))
    switch PTB.commPTB
        case 'FillOval' % Currently circles only
            h = plotcircle(h, PTB.xyDeg', PTB.sizeDeg(1,:)', color'/255, 'fill');
            
        case 'FillRect'
            h = plotrect(h, PTB.xyDeg', PTB.sizeDeg(1,:)', color'/255, 'fill');

        case 'FrameOval'
            h = plotcircle(h, PTB.xyDeg', PTB.sizeDeg(1,:)', color'/255, 'frame', ...
                PTB.penWidthDeg);

        case 'FrameRect'
            h = plotrect(h, PTB.xyDeg', PTB.sizeDeg(1,:)', color'/255, 'frame', ...
                PTB.penWidthDeg);

    %     case 'DrawDots'
    %         Screen('DrawDots', win, PTB.sizePix, PTB.color, PTB.centerPix);
    % 
    %     case 'DrawLines' 
    %         Screen('DrawLines', win, round(PTB.xyPix), round(PTB.penWidthPix), PTB.color(:)', ...
    %                             round(PTB.centerPix(:)')); % , PTB.smooth);
    % 
    %     case 'FillArc'
    %         Screen('FillArc', win, PTB.color, ...
    %                PsyPTB.xyPix2RectPix(PTB.xyPix, PTB.sizePix), ...
    %                PTB.startAngle, PTB.arcAngle);
    % 
    %     case 'FrameArc'
    %         Screen('FrameArc', win, PTB.color, ...
    %                PsyPTB.xyPix2RectPix(PTB.xyPix, PTB.sizePix), ...
    %                PTB.startAngle, PTB.arcAngle, PTB.penWidthPix);
    end
    
    % Put at the top
    uistack(h, 'top');
else % if ~on_now && ~isempty(h) && ishandle(h) && isvalid(h)
    for ii = 1:length(h)
        if ~isempty(h(ii)) && isvalid(h(ii))
            delete(h(ii));
        end
    end
    h = [];
end

% Copy back
PTB.h.PTB = h;