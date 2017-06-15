function v = diff_same_log_tail(v0, dim, MIN_STABLE_LOG)
% Use for a log of a unimodal pdf with an asymptotic derivative 
% on the right tail,
% to fill in the same value as the last stable derivative.

% Currently only works for vectors
assert(isvector(v0));

if nargin < 2
    if iscolumn(v0)
        dim = 1;
    else
        dim = 2;
    end
end

if nargin < 3
    MIN_STABLE_LOG = -34; % around log(eps) = -36
end

v = bml.math.diff_same(v0, dim);

[~, ix_max] = max(v0);

ix = 1:length(v0);
if iscolumn(v0)
    ix = ix'; 
end

% Find the last stable value
ix_tail = find((ix >= ix_max) & (v0 <= MIN_STABLE_LOG), 1, 'first'); 

% Fill in the last stable value
v((ix >= ix_max) & (v0 < MIN_STABLE_LOG)) = v(ix_tail);

% Replace infs on the left
v((ix < ix_max) & ~isfinite(v)) = -log(eps); % realmax./1e10;

return;

%% Test
x = 0:300;
L = log(bml.distrib.gampdf_ms(x, 1, 0.5));

subplot(2,1,1);
plot(x, L, 'k.-');

subplot(2,1,2);
LD1 = bml.math.diff_same(L);
plot(x, LD1, 'b-');
hold on;

LD2 = bml.math.diff_same_log_tail(L);
plot(x, LD2, 'r--');
hold off;