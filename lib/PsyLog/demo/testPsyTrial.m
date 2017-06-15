clear classes; clear classes;
import MDD.eye.RT.MDDTrial;

Tr = MDDTrial; % PsyTrial;

condM9 = [-.256, -.128, -.64, -.32, 0, .32, .64, .128, .256];
condC9 = [-.8, -.6, -.4, -.2, 0, .2, .4, .6, .8];
condM5 = [-.256, -.64, 0, .64, .256];
condC5 = [-.8, -.4, 0, .4, .8];

Tr.add_paradigm('Run', 'Blocked_HBV', {'task', 'BHV'});
Tr.cond2plan('Run', 'Blocked_HBV', 12, 'min_total_plan');

%% add_paradigm
parad = 'B9_HV5';
Tr.add_paradigm('Tr', parad, {'task', 'BHV', 'condM', condM9, 'condC', condC9}, ...
    {'auto_lengthen_plan', 5}, ...
    {{'samp', {'dis', 'vec', 1:10}, {'task', 'condM'}, {'repID'}, 1000}});

%% Customizing freq. Default is 1. Reduces #coh in 1D tasks.
Tr.set_cond_freq('Tr', parad, ...
    @(d) (d.task == 'H' & ~bsxEq(d.condC, condC5)) ...
       | (d.task == 'V' & ~bsxEq(d.condM, condM5)), 0);
  
%% auto_attach_seeds
auto_attach_seeds(1) = struct( ...
        'filt_fun',     [], ...
        'unique_factor',{{'condM'}}, ...
        'unique_index', {{'repID'}}, ...
        'unique_index_max', {1000}, ...
        'seed_cols',    {{'seedM'}} ...
        );
auto_attach_seeds(2) = struct( ...
        'filt_fun',     [], ...
        'unique_factor',{{'condC'}}, ...
        'unique_index', {{'repID'}}, ...
        'unique_index_max', {1000}, ...
        'seed_cols',    {{'seedC'}} ...
        );

Tr.add_params('Tr', parad, 'auto_attach_seeds', auto_attach_seeds);
   
%% cond2plan:
%   Repeat according to the integer proportion,
Tr.cond2plan('Tr', parad, 5, 'plan_per_cond');

% %%
% Tr.plan.Tr.seedM = floor(unique_rand_by(Tr.r, ...
%                        [Tr.plan.Tr.condM, ...
%                         Tr.plan.Tr.condC]) .* 1e5);
% Tr.plan.Tr.seedC = floor(unique_rand_by(Tr.r, ...
%                        [Tr.plan.Tr.condM, ...
%                         Tr.plan.Tr.condC]) .* 1e5);

%% The default newRun and newTrial just
% (1) increases indices and assigns them to appropriate fields, and
% (2-1) gets an index and copies it to the new Run/Trial, or
% (2-2) gets filtered indices and randomly chooses among them, and does (2-1), or
% (2-3) gets nothing and randomly chooses among remaining Runs/Trials.
%
% filt_rem_Run and filt_rem_Tr gives the remaining from repRun and repTr (~succT & ~cancelled)
%
% Customization in subclasses should come BEFORE the default actions.
% Default actions can accomodate customization by getting indices of Run and Tr
% from the customized methods.
f_new_Tr = @(Tr) Tr.new_Tr(@(d) d.task == Tr.last_Run.task); % @(Tr) Tr.new_Tr; % 

n_test = 50;

tic;
for ii = 1:12 % 24 runs. Should automatically lengthen.
    c_Run = Tr.new_Run;
    
    for i_Tr = 1:n_test
        c_Tr  = f_new_Tr(Tr);
        Tr.rec('Tr', false, 'RT', 1, 'subjM', 2, 'subjC', nan, ...
            'tSt', GetSecs, 'tEn', c_Tr.i_all_Tr + 1, ...
            'score', rem(Tr.i_all.Tr,5));

        c_Tr  = f_new_Tr(Tr);
        Tr.rec('Tr', true, 'RT', 2, 'subjM', 2, 'subjC', nan, ...
            'tSt', GetSecs, 'tEn', c_Tr.i_all_Tr + 1, ...
            'score', rem(Tr.i_all.Tr,5));

        c_Tr  = f_new_Tr(Tr);
        Tr.rec('Tr', true, 'RT', 3, 'subjM', 1, 'subjC', nan, ...
            'tSt', GetSecs, 'tEn', c_Tr.i_all_Tr + 1, ...
            'score', rem(Tr.i_all.Tr,5));
    end
    
    Tr.rec('Run', true, 'score_per_min', 2);

    c_Run = Tr.new_Run;
    
    for i_Tr = 1:n_test
        c_Tr  = f_new_Tr(Tr);
        Tr.rec('Tr', true, 'RT', 4, 'subjM', 1, 'subjC', nan, ...
            'tSt', GetSecs, 'tEn', c_Tr.i_all_Tr + 1, ...
            'score', rem(Tr.i_all.Tr,5));

        Tr.rec('Run', false, 'score_per_min', 1);
    end
end
t_elapsed = toc;
fprintf('total: %g, time per trial: %g, #trial: %g\n', ...
    t_elapsed, t_elapsed / Tr.i_all.Tr, Tr.i_all.Tr);

%%
for ii = 1:min(3, max(Tr.obTr.repID))
    Tr.obTr(Tr.obTr.condM==0 & Tr.obTr.task == 'H' & Tr.obTr.repID == ii,{'repID', 'samp'})
end

for ii = 1:min(3, max(Tr.obTr.repID))
    Tr.obTr(Tr.obTr.condM==0 & Tr.obTr.repID == ii,{'repID', 'task', 'seedM'})
end

%%
plot(2:Tr.i_all.Tr, diff(Tr.obTr.tSt)*1000);
xlabel('Trial');
ylabel('Time from previous trial (ms)');