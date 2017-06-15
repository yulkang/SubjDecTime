classdef CompareDistribFitShuffleCoh < Fit.Dtb.CompareDistribFit
properties
    n_shuf = 200;
    divergence_shuf_coh % (1, shuf, kind)
end
methods
    function Comp = CompareDistribFitShuffleCoh(varargin)
        if nargin > 0
            Comp.init(varargin{:});
        end
    end
    function batch(Comp0)
        n_subj = numel(Comp0.fit_orig_files);
        n_kind = numel(Comp0.divergence_kinds);
        
        d = zeros(n_subj, n_kind);
        d_shuf = zeros(n_subj, Comp0.n_shuf, n_kind);
        
        for i_subj = 1:n_subj
            Comp = feval(class(Comp0));
            Comp.i_subj = i_subj;
            
            [d1, d_shuf1] = Comp.main;
            d(i_subj,:) = d1;
            d_shuf(i_subj,:,:) = d_shuf1;
            d_ci = prctile(d_shuf, [2.5, 97.5], 2);
            d_est = median(d_shuf, 2);
        end
        d_err = bsxfun(@minus, d_ci, d_est);
        
        %% Plot
        for i_kind = 1:n_kind
            kind = Comp0.divergence_kinds{i_kind};
            
            clf;
            bar(1:n_subj, d(:,i_kind), 'w');
            hold on;
            errorbar_wo_tick( ...
                1:n_subj, ...
                d_est(:,1,i_kind), ...
                d_err(:,1,i_kind), d_err(:,2,i_kind), ...
                {
                    'Marker', 'o'
                    'MarkerFaceColor', 'none'
                    'MarkerEdgeColor', 'k'
                    'LineStyle', 'none'
                }, {
                    'Marker', 'none'
                    'LineStyle', '-'
                    'Color', 'k'
                });
            hold off;
            title({[strrep(kind, '_', ' '), ...
                ', orig vs shuf coh & ch'], ' '});
            
            bml.plot.beautify;
            ylabel('Jensen-Shannon Divergence');
            set(gca, 'XTickLabel', csprintf('S%d', 1:n_subj));
            
            file = Comp0.get_file({
                'isbj', 1:n_subj
                'plt', 'bar_n_shuf'
                'knd', kind
                });
            savefigs(file);
        end
        
        %% Print p-values
        file = [Comp0.get_file({
            'isbj', 1:n_subj
            'knd', 'pval'
            }), '.txt'];
        if exist(file, 'file')
            delete(file);
        end
        diary(file);
        
        for i_kind = 1:n_kind
            kind = Comp0.divergence_kinds{i_kind};
            
            d1 = d(:, i_kind);
            d_shuf1 = d_shuf(:, :, i_kind);
            ci1 = prctile(d_shuf1, [2.5, 97.5], 2);
            
            n_shuf = size(d_shuf1, 2);
            p1 = (sum(bsxfun(@lt, d_shuf1, d1), 2) + 1) ./ (n_shuf + 1);
            
            fprintf('%s: \n', kind);
            for i_subj = 1:n_subj
                fprintf('S%d: %1.3f (95%% CI = %1.3f-%1.3f), p=%1.3g\n', ...
                    i_subj, ...
                    d1(i_subj), ci1(i_subj,1), ci1(i_subj,2), ...
                    p1(i_subj));
            end
            fprintf('\n');
        end
        
        diary('off');
        fprintf('Saved to %s\n', file);
    end
    function [d, d_shuf] = main(Comp)
        %% Load results if exists
        [Comp, d, d_shuf] = Comp.load_mat;
        if ~isempty(d)
            n_kind_loaded = size(d, 2);
%             n_kind = numel(Fit.Dtb.CompareDistribFit.divergence_kinds);
            Comp.divergence_kinds = {'match_mean'};
            n_kind = numel(Comp.divergence_kinds);
            if n_kind_loaded < n_kind
                for i_kind = n_kind:-1:(n_kind_loaded+1)
                    kind = Comp.divergence_kinds{i_kind};
                    d(i_kind) = Comp.get_divergence([], [], ...
                        'kind', kind);
                    
                    [~, d_shuf1] = Comp.get_divergence([], [], ...
                        'kind', 'shuf_coh', ...
                        'kind_nested', kind);
                    d_shuf(:,:,i_kind) = d_shuf1;
                end
                Comp.save_mat;
            end
            
            return;
        end        
        
        Comp.load_fit_orig;
        d = Comp.get_divergence([], [], 'kind', 'all');
        Comp.divergence = d;
        
        Comp.get_divergence([], [], ...
            'kind', 'shuf_coh', ...
            'kind_nested', 'all', ...
            'to_store', true);
        d_shuf = Comp.divergence_shuf_coh;
        
        %% Save
        Comp.save_mat;
    end
    function S = get_S_divergence(Comp, varargin)
        S = varargin2S(varargin, varargin2S({
            'kind_nested', 'all'
            }, Comp.get_S_divergence@Fit.Dtb.CompareDistribFit));
    end
    function [d, d_shuf] = get_divergence(Comp, pred_pdf, data_pdf, varargin)
        %%
        S = Comp.get_S_divergence(varargin{:});
        
        if nargin < 2 || isempty(pred_pdf)
            pred_pdf = Comp.pred_pdf;
        end
        if nargin < 3 || isempty(data_pdf)
            data_pdf = Comp.data_pdf;
        end
        
        %%
        switch S.kind
            case 'shuf_coh'
                nt = size(pred_pdf, 1);
                n_ch = size(pred_pdf, 2);
                n_cond = size(pred_pdf, 3);
                
                rng(0); % DEBUG
                pred_pdf0 = reshape(pred_pdf, nt, n_ch * n_cond);
                
                C = varargin2C({
                    'kind', S.kind_nested
                    %  'to_store', true % DEBUG
                    'to_store', false
                    }, S);
                
                d_shuf = cell(Comp.n_shuf, 1);
                for i_shuf = 1:Comp.n_shuf
                    ix_shuf = randperm(n_cond * n_ch);
                    pred_pdf1 = reshape(pred_pdf0(:, ix_shuf), ...
                        nt, n_ch, n_cond);
                    d_shuf{i_shuf} = ...
                        Comp.get_divergence@Fit.Dtb.CompareDistribFit( ...
                            pred_pdf1, data_pdf, C{:});
                    
%                     Comp.plot_divergence_by_shift; % DEBUG
                    
                    fprintf('.');
                    if mod(i_shuf, 50) == 0
                        fprintf('%d\n', i_shuf);
                    end
                end
                % (1, kind, shuf) <- (shuf, kind)
                d_shuf = permute(cell2mat(d_shuf), [3, 1, 2]);
                if S.to_store
                    Comp.divergence_shuf_coh = d_shuf;
                end
                d = median(d_shuf);
                
            otherwise
                d = Comp.get_divergence@Fit.Dtb.CompareDistribFit( ...
                    pred_pdf, data_pdf, varargin{:});
        end
    end    
    function [Comp, d, d_shuf] = load_mat(Comp)
        file = Comp.get_file({'isbj', Comp.i_subj});
        if exist([file, '.mat'], 'file') ...
                && Comp.skip_existing_fit
            L = load(file);
            fprintf('Loaded Comp from %s.mat\n', file);
            Comp = L.Comp;
            d = Comp.divergence;
            d_shuf = Comp.divergence_shuf_coh;
        else
            d = [];
            d_shuf = [];
        end
    end
end
end