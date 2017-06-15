function h = plotPTB(h, comm, varargin)
switch comm
%     case 'FillOval'
%     case 'FillRect'
%     case 'FrameOval'
%     case 'FrameRect'
    case 'DrawLines'
        [xyDeg, penWidthDeg, color, centerDeg] = deal(varargin{:});
        
        x    = [xyDeg(1,1:2:end); xyDeg(1,2:2:end)] + centerDeg(1);
        y    = [xyDeg(2,1:2:end); xyDeg(2,2:2:end)] + centerDeg(2);
        n    = size(x, 2);
        color = rep2fit(color, [3, n])/255;
        
        penWidthPoint = norm2real(gca, penWidthDeg, 'points');
        
        if isempty(h)
            h = ghandles(1, n);
        end
        gh = ghandles;
        
        for ii = 1:n
            if isequal(h(ii), gh)
                h(ii) = plot(x(:,ii), y(:,ii), '-', 'Color', color(:,ii), 'LineWidth', penWidthPoint);
            else
                set(h(ii), 'XData', x(:,ii), 'YData', y(:,ii), 'Color', color(:,ii), 'LineWidth', penWidthPoint);
            end
        end
        
    %     case 'DrawLines' 
    %         Screen('DrawLines', win, round(PTB.xyPix), round(PTB.penWidthPix), PTB.color(:)', ...
    %                             round(PTB.centerPix(:)')); % , PTB.smooth);
    %     case 'DrawDots'
    %         Screen('DrawDots', win, PTB.sizePix, PTB.color, PTB.centerPix);
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
    otherwise
        error('Not implemented yet!');
end
end