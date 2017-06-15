function [x, y] = shift_line(line, dx, dy)
% [x, y] = shift_line(line, dx, dy)
for ii = numel(line):-1:1
    line1 = line(ii);
    
    x{ii} = get(line1, 'XData') + dx;
    y{ii} = get(line1, 'YData') + dy;
    
    set(line1, 'XData', x{ii}, 'YData', y{ii});
end