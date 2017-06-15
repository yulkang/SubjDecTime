function c2 = L2RGB(L,c1,m,colBkg)
if ~exist('c1', 'var'), c1 = 1; end
if ~exist('m', 'var'), m = 0.1; end
if ~exist('colBkg', 'var'), colBkg = 0; end

c2 = c1*L*(1.5+m/2)+colBkg;
