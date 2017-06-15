function color = color_lines(desc)
% color = color_lines(desc)
% desc: 'black'|'k', 'white'|'w', 'blue'|'b', 'tangerine'|'t',
%       'yellow'|'y'|'orange'|'o', 'purple'|'p', 'green'|'g',
%       'cyan'|'c', 'red'|'r'

if ~isscalar(desc)
    if ischar(desc)
        color = arrayfun(@bml.plot.color_lines, desc, 'UniformOutput', false);
    else
        color = cellfun(@bml.plot.color_lines, desc, 'UniformOutput', false);
    end
    color = cell2mat2(color(:));
    return;
end
color0 = lines(7);

switch desc
    case {'k', 'black'}
        color = [0 0 0];
    case {'w', 'white'}
        color = [1 1 1];
    case {'b', 'blue'}
        color = color0(1, :);
    case {'t', 'tangerine'}
        color = color0(2, :);
    case {'y', 'yellow', 'o', 'orange'}
        color = color0(3, :);
    case {'p', 'purple'}
        color = color0(4, :);
    case {'g', 'green'}
        color = color0(5, :);
    case {'c', 'cyan'}
        color = color0(6, :);
    case {'r', 'red'}
        color = color0(7, :);
    otherwise
        error('Unkown desc: %s\n', desc);
end    

