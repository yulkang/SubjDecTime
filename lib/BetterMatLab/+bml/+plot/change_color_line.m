function change_color_line(line, color)
% Change color of the lines or marker face colors without affecting other style.

set(line, 'Color', color, 'MarkerFaceColor', color);
end