function h = subplot_example
% Demonstrates functionality of fig_tag, subplotRCs, joinaxes, gltitle, and shiftpos.
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

fig = fig_tag('Subplot Example'); clf;
h = subplotRCs(2,2);
plot(h(1,1), 1:3, rand(1,3), 'r--');
plot(h(1,2), 1:10, rand(1,10), 'g-');
plot(h(2,1), 1:3, rand(1,3), 'k--');
plot(h(2,2), 1:10, rand(1,10), 'k-');
joinaxes(h, 'xsiz', [3, 10], 'xgap', 0.03, 'linkaxes', 'y', 'opt_common', {'YGrid', 'on'});
gltitle(h, 'all', 'Global Title');
gltitle(h, 'row', {{'Red and', 'Green'}, 'Black'});
gltitle(h, 'col', {'Dashed', 'Solid'});
shiftpos(fig, 'Children', [0.05, -0.05]);
