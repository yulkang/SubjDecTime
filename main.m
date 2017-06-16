% function main
% Reproduces all figures and tables in
%   Kang, Petzschner, Wolpert, and Shadlen (2017)
%   "Piercing of consciousness as a threshold crossing operation"
%
% Note: It may take hours to days to run all the analyses.
%       Consider running each cell separately.
%       "Analysis" should be run before generating Figures and Tables.

%% Initializing path - Must be run before any other cell
init_path;

%% === Analysis (Should be run before generating Figures and Tables) ===
%% tSD fit with flat bound 
W0 = Fit.Dtb.MeanRt.Main;
W0.batch_VD_sdt_all;

%% tSD fit with flat bound + permutation - takes a long time 
W0 = Fit.Dtb.PermuteCoh.Main;
W0.batch_meanRt;

%% tSD fit with flat bound + permutation - takes a long time 
W0 = Fit.Dtb.PermuteCoh.Main;
W0.batch_meanRt_sdt_ch('subj', 'S5');

%% RT fit with flat bound 
W0 = Fit.Dtb.MeanRt.Main;
W0.batch_RT_all;
W0.batch_RT_import_k;

%% tSD fit with collapsing bound 
W0 = Fit.Dtb.Main;
W0.batch_VD;

%% CI of tSD fit with collapsing bound - takes a long time 
W0 = Fit.Dtb.Main;
W0.batch_CI_VD;

%% Shuffle test - prediction of choice by tSD - takes a long time
W0 = Fit.Dtb.PermuteCoh.Main;
W0.batch_meanRt;
W0.batch_meanRt_sdt_ch;

%% Shuffle test - summarize significance of the prediction
W0 = Fit.Dtb.PermuteCoh.Summarize;
W0.main_meanSDT;

%% Shuffle test - summarize kappa results
W0 = Fit.Dtb.PermuteCoh.Summarize;
W0.main_meanSDT_w_meanRT;

%% Accuracy of the timing reports with the clock 
W0 = Fit.Probe.Main;
W0.batch;

%% === Figures ===
%% Figure 2. tSD - Controlled duration - flat bound fit 
W0 = Fit.Dtb.MeanRt.Main;
W0.imgather_VD;

%% Figure 3. Steepness of the tSD-coh relationship 
init_path;
cd('beta_approx_all');
addpath(genpath('matlab'));
beta_approx_all;
cd('..');

%% Figure 4. tSD distribution - Controlled duration
W0 = Fit.Dtb.Main;
W0.imgather_rt_distrib_all_VD;

%% Figure 5. Motion energy 
init_path;
cd('ME');
main_ME;
cd('..');

%% Figure 6. RT flat bound fit, kappa free vs fixed 
W0 = Fit.Dtb.MeanRt.Main;
W0.imgather_k_fixed_vs_free;

%% === Supp. Figures ===
%% Figure S1. Probe scatterplot 
W0 = Fit.Probe.Main;
W0.imgather;

%% Figure S2. Order preserving perturbations - takes a long time 
W0 = Fit.PerturbPred.ShuffleDeltaSDT;
W0.batch; % ('n_perm', 4); % To test, use small n_perm

%% Figure S2. Order preserving perturbations - combine figures
W0 = Fit.PerturbPred.ShuffleDeltaSDT;
W0.imgather_sim_vs_llk;
W0.batch_group_stat;

%% Figure S3. tSD/RT in wrong choice trials - Controlled duration
W0 = Fit.Dtb.Main;
W0.imgather_collapsing_bound;

%% Figure S3 - tSD/RT in Wrong Choice Trials (Within Subjects) 
W0 = Fit.CompRt.CompRt;
W0.batch;

%% Figure S4 - JS divergence - bootstrap 
W0 = Fit.Dtb.CompareDistribFit;
W0.batch;

%% Figure S4 - JS divergence - shuffle 
W0 = Fit.Dtb.CompareDistribFitShuffleCoh;
W0.batch;

%% Figure S5. kappa scatterplot 
W0 = Fit.Dtb.PermuteCoh.Summarize;
W0.main_meanSDT_w_meanRT;
W0.relabel_scatter;

%% === Tables ===
%% Table 1. tSD fit with flat bound
W0 = Fit.Dtb.MeanRt.Main;
W0.tabulate_SDT_VD;

%% === Supp. Tables ===
%% Table S1. RT fit with flat bound 
W0 = Fit.Dtb.MeanRt.Main;
W0.tabulate_RT_RT_k_free;

%% Table S2. RT fit with kappa fixed to that from tSD fit 
W0 = Fit.Dtb.MeanRt.Main;
W0.tabulate_RT_RT_k_fixed;

%% Table S3. tSD fit with collapsing bound 
W0 = Fit.Dtb.Main;
W0.tabulate_VD;

%% === Other Results in the text
%% Permute params across subjects 
W0 = Fit.PerturbPred.PermuteParam;
W0.init;
W0.main;

W0 = Fit.PerturbPred.PermuteParam;
W0.init('subjs', Data.Consts.subjs_w_SDT_modul);
W0.main;

%% Correlation between RT and tSD 
W0 = Fit.CorrSdtRt.CorrSdtRt;
W0.batch;

%% RT vs tSD 
W0 = Fit.RtVsSdt.RtVsSdt;
W0.batch;

%% Comparison of accuracy & tSD between long vs short trials 
W0 = Fit.CompDur.CompDur;
W0.main;

%% Comparison of accuracy & tSD between long vs short trials 
% while matching the total duration same
% (dot 800 + delay 200 or dot 200 + delay 800)
W0 = Fit.CompDur.CompDur;
W0.to_keep_total_dur_same = true;
W0.main;

%% === Data Processing and Analysis ===
%% # Invalid trials 
W0 = Fit.NTrial.NTrialInvalid;
W0.batch;

%% # No-decision trials 
W0 = Fit.NTrial.NTrialNoDecision;
W0.batch;

%% === Supp. Results ===
%% Accuracy of the timing reports with the clock
W0 = Fit.Probe.Main;
W0.tabulate;

%% Performance with and without tSD 
W0 = Fit.CompAccu.CompAccu;
W0.main;

%% Correlation/Similarity between k_SDT and k_RT 
Fit.Dtb.PermuteCoh.shuf_kappa;
