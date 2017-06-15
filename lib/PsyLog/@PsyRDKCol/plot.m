function h = plot(RDK, relS)

on_now = PsyVis.onnow(relS, RDK.relSec('on'), RDK.relSec('off'));

if on_now
    if ~isfield(RDK.v_, 'xyDeg')
        RDK.closeLog;
    end
    
    t  = RDK.relSec('xyDeg');
    fr = find(t <= relS, 1, 'last');

    xy   = RDK.v('xyDeg', fr);
    xy   = xy{1};
    col2 = RDK.v('col2', fr);
    col2 = col2{1} + 1;
    toShow = RDK.v('toShow', fr);
    xy   = xy(:,toShow{1});
    col2 = col2(toShow{1});
    
    dotTypes = 'soo';
    dotType  = dotTypes(RDK.dotType + 1);

    colors = RDK.colors / 255;
    ncolor = size(colors, 2);

    markerSize = norm2real(gca, RDK.dotSizeDeg, 'points') * 2; % Somehow *2 looks closer to actual dots.

%     if isempty(RDK.h) || ~isvalid(RDK.h)
%         if verLessThan('matlab', '8.4')
%             RDK.h = zeros(1, ncolor);
%         else
%             RDK.h = gobjects(1, ncolor);
%         end
%     end
    
    for icol = 1:ncolor
        if any(col2 == icol)
            cx = xy(1, col2 == icol)';
            cy = xy(2, col2 == icol)';
            
            if length(RDK.h) >= icol && ~isempty(RDK.h{icol}) && isvalid(RDK.h{icol})
                set(RDK.h{icol}, 'XData', cx, 'YData', cy);
            else
                RDK.h{icol} = plot(cx, cy, dotType, ...
                    'MarkerSize', markerSize, ...
                    'MarkerFaceColor', colors(:,icol), ...
                    'MarkerEdgeColor', 'none');
            end
        end
    end

    if nargout >= 1, h = RDK.h; end
    
else % if ~on_now && ~isempty(RDK.h) && ishandle(RDK.h) && isvalid(RDK.h)
    for ii = 1:length(RDK.h)
        if ~isempty(RDK.h{ii}) && isvalid(RDK.h{ii})
            delete(RDK.h{ii});
        end
    end
end
end