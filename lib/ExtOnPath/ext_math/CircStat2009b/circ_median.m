function md = circ_median(alpha)
%
% mu = circ_median(alpha, w)
%   Computes the median direction for circular data.
%
%   Input:
%     alpha	sample of angles in radians
%     either a vector or a matrix. If matrix, works on each column. % YK
%
%   Output:
%     mu		median direction
%
% PHB 3/19/2009
%
% References:
%   Biostatistical Analysis, J. H. Zar (26.6)
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens/circStat.html

% YK
if isrow(alpha)
    alpha = alpha';
elseif size(alpha, 2) > 1 % If more than one column
    nc = size(alpha, 2);
    md = zeros(1, nc);
    for ii = 1:nc
        md(ii) = circ_median(alpha(:,ii));
    end
    return;
end
% if size(alpha,2) > size(alpha,1)
% 	alpha = alpha';
% end
alpha = mod(alpha,2*pi);
n = length(alpha);

m1 = sum(circ_dist2(alpha,alpha)>0,1);
m2 = sum(circ_dist2(alpha,alpha)<0,1);

dm = abs(m1-m2);
if mod(n,2)==1
  [m idx] = min(dm);
else
  m = min(dm);
  idx = find(dm==m,2);
end

if m > 1
  warning('Ties detected.') %#ok<WNTAG>
end

md = circ_mean(alpha(idx));
  
if abs(circ_dist(circ_mean(alpha),md)) > abs(circ_dist(circ_mean(alpha),md+pi))
  md = mod(md+pi,2*pi);
end

  