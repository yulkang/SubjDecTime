function L = RGB2L(c2,m,colBkg,c1)
if length(c2)>1, c2 = max(c2(:)); end
if ~exist('m', 'var'),  m = 0.1; end
if ~exist('colBkg', 'var'), colBkg = 0; end    
if ~exist('c1', 'var'), c1 = 1; end
if length(c1)>1, c1 = max(c1(:)); end
    
L = (max(c2)-colBkg)./(c1*(1.5+m/2));
