function p = p_summand(s, p0)
% p = p_summand(s, p0)
%
% s: sum.
% p0(k, m): (unconditined) probability of m-th summand being k-1.
% p(k_1): probability of the first summand, marginalized across k_2 .. k_M.
% % p(k_1, k_2, ..., k_{M-1}): joint probability of k_1, ..., k_{M-1} 
% %   marginalized across k_M.

M = size(p0, 2);
s_max = size(p0, 1) - 1;
assert(any(M == [2 3]), 'Only 2 or 3 summands are supported!');
assert((s >= 0) && (s <= s_max), 's must be within [0, size(p0,1)-1] !');

if M == 2
    p1 = p0(1:(s+1),1);
    p1 = nan0(p1 ./ sum(p1));
    p2 = p0(1:(s+1),2);
    p2 = nan0(p2 ./ sum(p2));
    p = p1 .* flipud(p2);
    p = nan0(p / sum(p));
    if length(p) < s_max + 1
        p(s_max + 1, 1) = 0; % Match length
    end
elseif M == 3
    p = zeros(s_max + 1, 1);
    for k_M = 0:s
        cp = p_summand(s - k_M, p0(:,1:(M-1))) * p0(k_M + 1, M);
        p = p + cp;
    end
    p = nan0(p / sum(p));
end

return;

%% test: M=2
s_max = 4;
p1 = [1 2 2 2 1];
p1 = p1(:) / sum(p1);
p2 = [0 1 1 1 0];
p2 = p2(:) / sum(p2);
p0 = [p1, p2];

s = 2;
p  = p_summand(s, p0);

cla;
plot(0:s_max, [p, p0]); hold on;

%% test: M=3
s_max = 4;
p1 = [1 2 2 2 1];
p1 = p1(:) / sum(p1);
p2 = [0 1 1 1 0];
p2 = p2(:) / sum(p2);
p3 = [1 1 1 1 1];
p3 = p3(:) / sum(p3);
p0 = [p1, p2, p3];

s = 2;
p  = p_summand(s, p0);

cla;
plot(0:s_max, [p, p0]); hold on;

%% test: longer
s_max = 100;
t = (0:s_max)';
p1 = binopdf(t, s_max, 0.6);
p2 = binopdf(t, s_max, 0.4);
p3 = binopdf(t, s_max, 0.5);
p0 = [p1, p2, p3];
s = 100;
p = p_summand(s, p0);

cla;
plot(t, [p, p0]);
grid on;