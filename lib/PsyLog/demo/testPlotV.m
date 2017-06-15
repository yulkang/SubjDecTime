[xyPix t] = Mouse.vTrim('xyPix');

vX = diff(xyPix(1,:));
vY = diff(xyPix(2,:));

plot(vY*100, 'b-'); hold on; 
plot(vX*100, 'r-'); hold on;

plot(xyPix(2,:), 'c-'); hold on;
plot(xyPix(1,:), 'm-'); hold on;

hold off;

%%
v = sqrt(vX.^2 + vY.^2);

