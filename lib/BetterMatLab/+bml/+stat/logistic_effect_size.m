function [v_res, res] = logistic_effect_size(mdl, coef_name, varargin)
% Find the value of the regressor that would reject the null hypothesis.
%
% [v_res, res] = logistic_effect_size(mdl, coef_name, varargin)
%
% mdl: a GeneralizedLinearModel with a binomial response variable.
% coef_name: name of the coefficient.
% 
% v_res: if mode = 'thres', [thres_neg, thres_pos]
%        where 
%        if mode = 'power', [power1, power2, ...] where powerK is the
%        probability of detection given the K-th effect size.
% res: a struct containing the results and settings.
%
% OPTION
% ------
% 'n_sim', 1e4 % number of simulation.
% 'alpha', 0.05 % p-value under which to reject the null hypothesis.
% 'effect_sizes', [] % Unless given, 10.^(-3:0.25:3) .* SE are tried.

% 2017 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'n_sim', 1e3 % number of simulation.
    'alpha', 0.05 % p-value under which to reject the null hypothesis.
    ...
    ... % 'mode'
    ... % : 'thres': Calculate threshold coefficients that gives 
    ... %            the probability of detection that equals beta.
    ... % : 'power': Calculate probability of detection for each effect size.
    'mode', 'thres' 
    ...
    'beta', 0.8 % Statistical power for finding thresholds
    'tol_x_rel', 1e-2 % Tolerance of threshold value compare to SE
    'to_plot', false
    ...
    'effect_sizes', [] % Unless given, effect_sizes_rel_SE .* SE are tried.
    'effect_sizes_rel_SE', -5:0.5:5;
    });

%%
coef0 = mdl.Coefficients(coef_name, :);
b0 = mdl.Coefficients.Estimate;
ix_coef = strcmp(coef_name, mdl.CoefficientNames);
X = mdl.Variables;
X(:,mdl.ResponseName) = [];
X = table2array(X);

%%
switch S.mode
    case 'thres'
        %%
        ub = coef0.SE * 5;
        v_res = nan(1, 2);

        if S.to_plot
            plot_fcns = {@optimplotx, @optimplotfval};
        else
            plot_fcns = [];
        end
        if S.to_plot && ~is_in_parallel
            options = optimset( ...
                'TolX', coef0.SE * S.tol_x_rel, ...
                'PlotFcns', plot_fcns);
        else
            options = optimset( ...
                'TolX', coef0.SE * S.tol_x_rel);
        end

        for ii = 2:-1:1
            sgn = sign(ii - 1.5);
            ub1 = ub * sgn;

            fun = @(v) sum(glmpower(b0(:)' .* ~ix_coef + v .* ix_coef, X, 'logit', ...
                'n_sim', S.n_sim) .* ix_coef) - S.beta;
            
            fv0 = fun(0);
            fv1 = fun(ub1);
            if sign(fv0) ~= sign(fv1)
                [v_res(ii), fval(ii), exitflag(ii), output{ii}] = ...
                    fzero(fun, [0, ub1], options);
            else
                v_res(ii) = nan;
                fval(ii) = nan;
                exitflag(ii)=  nan;
                output{ii} = struct;
            end
        end
        
        res = packStruct(v_res, fval, exitflag, output, coef0, S);

    case 'power'
        error('mode = power not supported yet!');
%         %%
%         if isempty(S.effect_sizes)
%             S.effect_sizes = coef0.SE .* S.effect_sizes_rel_SE;
%         end
end
        
%% Output
end