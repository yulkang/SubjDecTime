% Save workspace. Scr should exist in the workspace.
if ~exist('Scr', 'var') || ~isa(Scr, 'PsyScr')
    error('A PsyScr object Scr is required!');
end
% if ~exist('preRunComment', 'var') || ~ischar(preRunComment)
%     error('A string preRunComment is required!');
% end
if exist('saveWorkspace_dst_', 'var'), error('Namespace conflict!'); end

%%
Scr.makePath('orig');

saveWorkspace_dst_ = Scr.trialFile('orig', '.mat');

vars_save = who;
vars_excl = [vars_save(strcmpFirst('f_', vars_save) | strcmpFirst('vars_', vars_save)); {'Tr'; 'TargRep'; 'c_prm_Tr'; 'ans'}];
vars_save = save_filt(whos, vars_excl);

save(saveWorkspace_dst_, vars_save{:});
fprintf('\nWorkspace saved to %s\n\n', saveWorkspace_dst_);

clear saveWorkspace_dst_