import Fit.Dtb.PermuteCoh.shuf_kappa_unit

%%
kappa_w_S5_SDT_only = [
    40.4, 5.7, 19.2, 24.3, 64.1
    28.2, 8.5, 17.6, 23.6, 20.2
    ]';
kappa_w_S5_joint = [
    40.4, 5.7, 19.2, 24.3, 24.6
    28.2, 8.5, 17.6, 23.6, 20.2
    ]';

%%
[r, p] = corrcoef(kappa_w_S5_joint(1:4,:))
[r, p] = corrcoef(kappa_w_S5_joint)

%%
disp('kappa_w_S5_SDT_only(1:4)')
[p_incl_d0, p_excl_d0] = shuf_kappa_unit(kappa_w_S5_SDT_only(1:4,:))

disp('kappa_w_S5_joint')
[p_incl_d0, p_excl_d0] = shuf_kappa_unit(kappa_w_S5_joint)
