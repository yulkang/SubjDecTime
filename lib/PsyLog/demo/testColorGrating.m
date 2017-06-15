n_incl = 7;

th_incl  = linspace(0, 45, n_incl);
col_incl = cool(n_incl) * 255;

k      = 10; % 3.5;
k_incl = fliplr([1:ceil(n_incl / 2), ceil(n_incl / 2):-1:2] * k - k + 1);
p_incl = k_incl / sum(k_incl);
p_cum  = cumsum(p_incl);
logit_incl = log(k_incl ./ fliplr(k_incl));

disp(logit_incl);
disp(sum(p_incl .* logit_incl));
plot(p_incl); hold on;
plot(p_cum); hold off;
n = 40;
t_freq = 10;
s_freq = 2;

width = 2;

%%
% rng(0);

test_mode = inputYN_def('test mode? (Y/n) ', true);
if test_mode
    rect = [0 0 600 400];
else
    rect = [];
end

[win, rect] = Screen('OpenWindow', 0, 0, rect);

center = rect(1:2) + rect(3:4)/2;
siz    = rect(4)/20;

corr_ans = randi(2, 1,2);
d = zeros(1,2);

d_all = zeros(n, 2);

for ii = 1:n
    
    for i_dim = 1:2
        d(i_dim) = find(rand < p_cum, 1, 'first');
        
        if corr_ans(i_dim) == 2
            d(i_dim) = n_incl + 1 - d(i_dim);
        end        
    end
    
    d_all(ii,:) = d;
    
    ph = rand / 2 + 0.25;
    th = th_incl(d(1));
    
    if rand > 0.5, th = 180 - th; end
    
    col = col_incl(d(2), :);
    
    xy = [
        grating_xy(s_freq, ph, th, siz), ...
        grating_xy(s_freq, ph, th+90, siz)];
    
    Screen('DrawLines', win, xy, width, col, center);
    Screen('Flip', win);
    WaitSecs(1/t_freq);

%     Screen('Flip', win);
%     WaitSecs(0.3/t_freq);
end

Screen('CloseAll');

disp(corr_ans);
if corr_ans(1) == 1
    fprintf('0  ');
else
    fprintf('45 ');
end
if corr_ans(1) == 1
    fprintf('B\n');
else
    fprintf('R\n');
end

%%
plot([0 0; cumsum(-logit_incl(d_all))], '.-');
legend('th (-0, +45)', 'col (-B +R)', 'Location', 'East');
