function samp = n2samples(num)
% samp = n2samples(num)
%
% Duplicate num(k) for num(k) times, so that if num(k) represents duration,
% hist(num) reflects correct duration.
%
% EXAMPLE:
% >> n2samples([1 3 2])
% ans =
%      1     3     3     3     2     2

n     = length(num);
samp  = zeros(1, sum(num));

c_pos = 0;

for ii = 1:n
    ix = c_pos + (1:num(ii));
    samp(ix) = num(ii);
    
    c_pos = ix(end);
end