classdef CompRt < Fit.Common.CommonWorkspace
properties
    subjs = Data.Consts.subjs
    mdls = {};
    mdls_base = {};
    thres_n_wrong = 1; % 0 to include all
    to_include_ixn_acond_accu = false
    model_kind = 'contin_cond'; % 'anova' % 'anova'|'categ_cond'|'contin_cond'
end
methods
    function W = CompRt(varargin)
        if nargin > 0
            W.init(varargin{:});
        end
    end
    function batch(W0, varargin)
        S_batch = varargin2S(varargin, {
            'model_kind', {'contin_cond'} % 'anova', 'categ_cond', 
            'to_include_ixn_acond_accu', {false} % , true}
            });
        [Ss, n] = factorizeS(S_batch);
        for ii = 1:n
            S = Ss(ii);
            C = S2C(S);
            W0.main(C{:});
        end
    end
    function main(W0, varargin)
        C2 = varargin2C2(varargin, {
            {'parad', 'rt_field'}, {
                {'VD_wSDT', 'SDT_ClockOn'}
                {'RT_wSDT', 'RT'}
                }
            'subj', Data.Consts.subjs
            });
        [Ss, n] = factorizeC(C2);
        
        txts = cell(n, 1);
        mdls = cell(n, 1);
        mdls_base = cell(n, 1);
        
        S0 = W0.get_S0_file;        
        for ii = 1:n
            S = varargin2S(Ss(ii), S0);
            C = S2C(S);
            W = feval(class(W0), C{:});
            
            cond1 = W.Data.cond;
            ch1 = W.Data.ch;
            rt1 = W.Data.rt;
            
            b = glmfit(cond1, ch1, 'binomial');
            [~, spe] = logit2thres(b);
            cond_bias1 = cond1 - spe;
            accu1 = sign(cond_bias1) == sign(ch1 - 0.5);
            acond_bias1 = abs(cond_bias1);
            
            tbl = table(acond_bias1, cond1, accu1, rt1);

            [~,~,d_cond1] = unique(cond1);
            n_wrong_cond = accumarray(d_cond1, ~accu1, [], @sum);
            incl_cond = find(n_wrong_cond >= W.thres_n_wrong);
            incl_tr = ismember(d_cond1, incl_cond);
            tbl = tbl(incl_tr, :);
            
            switch W.model_kind
                case 'anova'
                    % equivalent to categ_cond
                    if W.to_include_ixn_acond_accu
                        spec = 'full';
                    else
                        spec = 'linear';
                    end
                    
                    [~, tbl, stats] = anovan(rt1, {cond1, accu1}, ...
                        'display', false, ...
                        'model', spec);
                    
                    [~, tbl_base, stats_base] = anovan(rt1, {cond1}, ...
                        'display', false, ...
                        'model', spec);
                    
                case 'categ_cond'
                    if W.to_include_ixn_acond_accu
                        spec = 'rt1 ~ cond1 * accu1';
                    else
                        spec = 'rt1 ~ cond1 + accu1';
                    end
                    
                    mdl = fitglm(tbl, spec, ...
                        'CategoricalVars', {'cond1', 'accu1'}, ...
                        'Distribution', 'normal');

                    mdl_base = fitglm(tbl, 'rt1 ~ cond1', ...
                        'Distribution', 'normal');

                case 'contin_cond'
                    if W.to_include_ixn_acond_accu
                        spec = 'rt1 ~ acond_bias1 * accu1';
                    else
                        spec = 'rt1 ~ acond_bias1 + accu1';
                    end
                    
                    mdl = fitglm(tbl, spec, ...
                        'CategoricalVars', {'accu1'}, ...
                        'Distribution', 'normal');

                    mdl_base = fitglm(tbl, 'rt1 ~ acond_bias1', ...
                        'Distribution', 'normal');
            end
            
            ix_subj = find(strcmp(W.subj, Data.Consts.subjs));
            txt1.parad = W.parad;
            txt1.DV = W.Data.rt_field_label;
            txt1.subj = sprintf('S%d', ix_subj);
            
            if strcmp(W.model_kind, 'anova')
                mdl = packStruct(tbl, stats);
                mdl_base = varargin2S({
                    'tbl', tbl_base
                    'stats', stats_base
                    });
                txt1.df = stats.dfe;
                varnames = {'cond1', 'accu1', 'ixn'};
                n_row = size(tbl, 1) - 3;
                for jj = 1:n_row
                    row = jj + 1;
                    txt1.(varnames{jj}) = ...
                        sprintf('F(%d;%d)=%1.1f (p=%1.2g)', ...
                            tbl{row, 3}, tbl{n_row + 2, 3}, tbl{row, 6}, ...
                            tbl{row, 7});
                end
                
            else
                Coef = mdl.Coefficients;

                n_reg = size(Coef, 1);
                regressors = strrep_cell(mdl.CoefficientNames, {
                    '(Intercept)', 'Intercept'
                    ':', '_'
                    '-', '_'
                    '.', '_'
                    });
                for i_reg = 1:n_reg
                    txt1.(regressors{i_reg}) = ...
                        sprintf('%1.3f +- %1.3f (p=%1.2g)', ...
                            Coef.Estimate(i_reg), ...
                            Coef.SE(i_reg), ...
                            Coef.pValue(i_reg));
                end
                txt1.df = mdl.DFE;
            
                d_bic = mdl.ModelCriterion.BIC ...
                      - mdl_base.ModelCriterion.BIC;
                txt1.DeltaBIC = sprintf('%1.1f', d_bic);

            end
            mdls{ii} = mdl;
            mdls_base{ii} = mdl_base;
            txts{ii} = txt1;
        end
        ds_txt = bml.ds.from_Ss(txts);
        
        W0.mdls = mdls;
        W0.mdls_base = mdls_base;
        
        disp(ds_txt);
        
        file = W.get_file({
            'sbj', unique({Ss.subj})
            'prd', unique({Ss.parad})
            'rtf', unique({Ss.rt_field})
            'tbl', 'indiv'
            });
        mkdir2(fileparts(file));
        save(file, 'mdls');
        export(ds_txt, 'File', [file, '.csv'], ...
            'Delimiter', ',');
        fprintf('Saved to %s.csv and .mat\n', file);
    end
    function fs = get_file_fields(W)
        fs = [
            W.get_file_fields@Fit.Common.CommonWorkspace
            {
            'thres_n_wrong', 'nwrg'
            'to_include_ixn_acond_accu', 'ixn'
            'model_kind', 'mdl'
            }];
    end
end
end