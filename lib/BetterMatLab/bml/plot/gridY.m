function gridY(ySpacing)
% gridY(ySpacing)

grid on;

yLim = ylim;
set(gca, 'yTick', yLim(1):ySpacing:yLim(2));

    