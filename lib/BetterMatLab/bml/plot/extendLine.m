function extendLine(h, d)
% extendLine(h, d='x'|'y')

if nargin < 2 || isempty(d), d = 'x'; end

x = get(h, 'XData');
y = get(h, 'YData');
hAx = get(h, 'Parent');

switch d
    case 'x'
        xNew = xlim(hAx);
        b    = glmfit(x,y,'normal');
        yNew = glmval(b,xNew,'identity');
        
        set(h, 'XData', xNew, 'YData', yNew);
        
    case 'y'
        yNew = ylim(hAx);
        b    = glmfit(y,x,'normal');
        xNew = glmval(b,yNew,'identity');
        
        set(h, 'XData', xNew, 'YData', yNew);
        
    otherwise
        error('Unknown direction!');
end