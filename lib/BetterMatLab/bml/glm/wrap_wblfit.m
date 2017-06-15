function res = wrap_wblfit(x, y, th0)
% res = wrap_wblfit(x, y, th0)
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

[xcon, ycon] = consolidator(x, y);
[~,    n] = consolidator(x, y, @numel);
dat = [xcon, ycon, n];
dat = dat(n > 10,:);

if isempty(dat), res = []; return; end

if nargin < 3, 
    thresP = (1-exp(-1))/2+0.5;

    aftThres = find(ycon >= thresP, 1, 'first');
    befThres = find(ycon <  thresP, 1, 'last');
    if ~isempty(aftThres) && ~isempty(befThres) && befThres < aftThres
        thresX = (thresP - ycon(befThres)) / (ycon(aftThres) - ycon(befThres)) ...
               * (xcon(aftThres) - xcon(befThres)) + xcon(befThres);
    else
        thresX = median(xcon);
    end
    th0 = [thresX, 1.5];
end

[th, fval, exitflag, output] = fmincon(@(th) wbl_nll(th, dat), th0, ...
    [], [], [], [], [thresX 0], [thresX, 20]); % , [], ...
%     optimoptions('fmincon', 'PlotFcns', {@optimplotx, @optimplotfval}));

% res = pfit(dat, 'shape', 'weibull');
% res.th = res.params.est;
res = packStruct(th, fval, exitflag, output); % , lambda);
end


function nll = wbl_nll(th, dat)
x  = dat(:,1);
n  = dat(:,3);
n1 = dat(:,2) .* n;
n0 = n - n1; 

p1 = wblcdf(x, th(1), th(2)) / 2 + 0.5;
p1 = p1 * 0.99 + 0.005;
p0 = 1 - p1;
l1 = log(p1); % max(p1, eps));
l0 = log(p0); % max(p0, eps));

nll = -sum(l1.*n1 + l0.*n0); ...
%     + gammaln(n+1) - gammaln(n1+1) - gammaln(n0+1));
end
