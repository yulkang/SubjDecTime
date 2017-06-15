% %%
% files = bml.str.Serializer.ls('Data/Fit.Dtb.PermuteCoh.Main/fit_perm/*.mat', ...
%     'allof', {'ftcl=Fit^Dtb^MeanRt^Main', 'igch=0'});
% 
% %%
% bml.file.strrep_filename('igch=0', 'igch=1', 'files', files);

% %%
% files = bml.str.Serializer.ls('Data/Fit.Dtb.PermuteCoh.Main/fit_perm/*.mat', ...
%     'allof', {'ftcl=Fit^Dtb^MeanRt^Main', 'bnd=betacdf'});
% 
% %%
% bml.file.strrep_filename('bnd=betacdf', 'bnd=const', 'files', files);

% %%
% files = bml.str.Serializer.ls('Data/Fit.Dtb.PermuteCoh.Main/fit_perm/*.mat', ...
%     'allof', {'ftcl=Fit^Dtb^MeanRt^Main', 'bayes=bayesLeastSq'});
% 
% %%
% bml.file.strrep_filename('bayes=bayesLeastSq', 'bayes=none', 'files', files);

% %%
% files = bml.str.Serializer.ls('Data/Fit.Dtb.MeanRt.Main/*.mat', ...
%     'allof', {'imk={parad,rt_field,n_tnd,VD_wSDT,SDT_ClockOn,1}'});
% 
% %%
% bml.file.strrep_filename( ...
%     'imk={parad,rt_field,n_tnd,VD_wSDT,SDT_ClockOn,1}', ...
%     'imk={parad,VD_wSDT,rt_field,SDT_ClockOn,n_tnd,1}', ...
%     'files', files);

%%
files = bml.str.Serializer.ls('Data/Fit.Dtb.PermuteCoh.Main/fit_perm/*.mat', ...
    'allof', {'ftcl=Fit^Dtb^MeanRt^Main', 'bnd=betacdf'});

%%
bml.file.strrep_filename( ...
    'bnd=betacdf', ...
    'bnd=const', ...
    'files', files);
