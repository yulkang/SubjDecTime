function [history, res, Ss] = eqLum_RDK_auto(varargin)

S = varargin2S(varargin, {
    'run_name',     ''
    'n_trial',      12
    'attribute',    'col_red' % 'col_red' | 'coh_col'
    'maxSec',   5 
    'bef_RDK_sec',  1 
    'intertrial_sec', 1 
    'Scr',          []
    });

rng('shuffle');

switch S.attribute
    case 'coh_col'
        S.f_samp = @() max(min(normrnd(0, 0.05), 0.1), -0.1);
    case 'col_red'
        S.f_samp = @() round(rand * 115 + 140); % 140 to 255
end

if isempty(S.run_name)
    S.run_name = input('Run name', 's');
end
file_diary = name_par('diary', S.run_name, '.txt');
file_mat   = name_par('mat', S.run_name, '.mat');
diary(file_diary);
fprintf('Keeping diary to %s\n', file_diary);

%%
if isempty(S.Scr)
    S.Scr    = PsyScr('scr', 1, 'refreshRate', 75, 'distCm', 55, 'widthCm', 35.1, ...
    'hideCursor', true, 'maxSec', S.maxSec + S.bef_RDK_sec, 'bkgColor', 1);

    S.Scr.open;
end

%% Run calibration
res = cell(1, S.n_trial);
Ss  = cell(1, S.n_trial);
history = zeros(1, S.n_trial);

C = S2C(S);
for i_trial = 1:S.n_trial
    % Random starting point
    C = varargin2C({S.attribute, S.f_samp()}, C);
    
    switch S.attribute
        case 'coh_col'
            [res{i_trial}, Ss{i_trial}] = eqLum.eqLum_RDK(C{:});
        case 'col_red'
            [res{i_trial}, Ss{i_trial}] = eqLum.eqLum_RDK_col(C{:});
    end
    
    if res{i_trial}.accepted
        history(i_trial) = res{i_trial}.(S.attribute);
    else
        history = history(1:(i_trial-1));
        break;
    end
end

S.Scr.close;

%% Save results
save(file_mat);
fprintf('Saved results to %s\n', file_mat);

%% Display results
fprintf('----- Results:\n');
fprintf('history:'), fprintf(' %1.3f', history); fprintf('\n');
if strcmp(S.attribute, 'coh_col')
    fprintf('prop   :'), fprintf(' %1.3f', invLogit(history)); fprintf('\n');
end
eprintf('mean(history)');
eprintf('std(history)');

fprintf('Saved diary to %s\n', file_diary);
diary off;