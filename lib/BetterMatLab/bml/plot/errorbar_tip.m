function htxt = errorbar_tip(h)
% errorbar_tip(h)

x = get(h, 'XData');
y = get(h, 'YData');
u = get(h, 'UData');
l = get(h, 'LData');

n = length(x);

htxt = zeros(1,n);

for ii = 1:n
    htxt(ii) = text(x(ii),y(ii)+u(ii), sprintf('%1.3g±%1.3g', y(ii), u(ii)), ...
        'VerticalAlignment', 'bottom', ...
        'HorizontalAlignment', 'center');
end