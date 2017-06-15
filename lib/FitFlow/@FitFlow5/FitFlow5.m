classdef FitFlow5 < Fit_Flow3
    % Updates over Fit_Flow3
    % - Parameters can be numerical arrays of any size.
    %   - history is recorded as a cell.
    % - optimplotx can include a subset of parameters.
    % - optimplotxArray is added for array parameters.
    %
    % Considering for FitFlow6
    % - Functions can get Fl rather than W, to facilitate object-oriented programming.
    %   - But even now, functions can be added in the form of W = Fl.funW(W),
    %     or using W.Fl = Fl, making them class-aware.
    %
    % 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.
    
    methods
        function Fl = FitFlow5
            Fl = Fl@Fit_Flow3;
            Fl.VERSION = 5;
            Fl.VERSION_DESCRIPTION = 'Parameters can be arrays.';
        end
        
        %% Get/set
        function S = vec2S(Fl, v, S, names)
            % S = vec2S(Fl, v, S)
            
            if nargin < 3 || isempty(S), S = Fl.th; end
            if nargin < 4, names = {}; end
            [siz, numEl, fs] = FitFlow5.field_sizes(S, names);
            
            cumNumEl = [0; cumsum(numEl)];
            n = length(numEl);
            S = struct;
            
            for ii = 1:n
                st = cumNumEl(ii)+1;
                en = cumNumEl(ii+1);
                S.(fs{ii}) = reshape(v(st:en), siz{ii});
            end
        end
        
        function [v, name_ix] = S2vec(Fl, S, names)
            % [v, name_ix] = S2vec(Fl, S)
            %
            % name_ix : name_ind1_ind2 ... = name(ind1,ind2, ...)
            
            if nargin < 3, names = {}; end
            
            [siz, numEl, fs] = FitFlow5.field_sizes(S, names);
            
            cumNumEl = [0; cumsum(numEl(:))];
            n = length(numEl);
            v = zeros(cumNumEl(end),1);
            
            name_ix = cell(n, 1);
            
            for ii = 1:n
                st = cumNumEl(ii)+1;
                en = cumNumEl(ii+1);
                
                cv       = Fl.th.(fs{ii});
                v(st:en) = cv(:);
                
                for jj = 1:numEl(ii)
                    [ix{1:length(siz{ii})}] = ind2sub(siz{ii}, jj);
                    name_ix{ii+jj-1} = [fs{ii}, sprintf('_%d', ix{:})];
                end
            end
        end
        
        function varargout = th_sizes(Fl)
            [varargout{1:nargout}] = FitFlow5.field_sizes(Fl.th);
        end
        
        %% Output/plotting functions
        function f = dispfun(Fl)
            f = @c_outfun;
            th_names = Fl.th_names;
            S0       = Fl.th;
            
            function stop = c_outfun(x, optimValues, state)
                fprintf('Iter %4d (fval=%1.5g)', optimValues.iteration, optimValues.fval);
                
                th = vec2S(Fl, x, S0);
                
                for ii = 1:length(th_names)
                    fprintf(' %s=', th_names{ii});
                    
                    v = th.(th_names{ii});
                    if isscalar(v)
                        fprintf('%1.5g', v);
                    else
                        fprintf('\n');
                        disp(v);
                    end
                end
                stop = false;
            end
        end
        
        function f = record_history(Fl)
            % Gives Fl.f_record_history. Used in outfun.
            
            th_names = Fl.th_names;
            max_iter = Fl.max_iter;
            n_th     = length(th_names);
            S0       = Fl.th;
            
            % id: Prevent confusion between multiple Fl 
            % without using Fl (handle) explicitly during fitting
            % which adds overhead during parallel processing.
            f = @(x,v,s) f_rec(x,v,s,Fl.id);
            
            function stop = f_rec(x, optimValues, state, id)
                persistent history
                
                % Flag
                stop = false;

                switch state
                    case 'init'
                        % Initialize
                        history.(id) = cell2dataset(repmat({[]}, [max_iter, n_th+1]), ...
                            'VarNames', [th_names(:)', {'fval'}]);

                    case 'iter'
                        % Record
                        citer = optimValues.iteration + 1;
                        
                        th = vec2S(Fl, x, S0);
                        
                        for ii = 1:n_th
                            history.(id).(th_names{ii}){citer, 1} = th.(th_names{ii});
                        end
                        history.(id).fval{citer,1} = optimValues.fval;
                        
                    case 'done'
                        % Truncate
                        history.(id) = history.(id)(1:min(optimValues.iteration, end), :);

                    case 'retrieve'
                        % Return
                        stop = history.(id);
                        
                    case 'delete'
                        history = rmfield(history, id);
                        
                    case 'deleteAll'
                        history = struct;
                end
            end
        end
        
        function f = optimplotx(Fl, names)
            if nargin < 2 || isempty(names)
                names = Fl.th_names;
            end
            
            S0            = Fl.th;
            [ub, name_ix] = S2vec(Fl, Fl.th_ub, names);
            lb            = S2vec(Fl, Fl.th_lb, names);
            
            n     = length(name_ix);
            
            f = @f_optimplotx;
            
            function stop = f_optimplotx(x,optimValues,state,varargin)
                
                th = vec2S(Fl, x,  S0, names);
                x  = S2vec(Fl, th, names); % Leave designated parameters only.
                
                % Show normalized plot
                x_plot = (x - lb) ./ (ub - lb);
                
                barh(x_plot);
                
                labels = cell(n,1);
                for ii = 1:n
                    % Reverse order so that important info is close to the right,
                    % and not occluded in pre-2014b MATLABs.
                    labels{ii} = [
                        sprintf('(%1.2g - %1.2g)', lb(ii), ub(ii)), ...
                        sprintf('%1.3g', x(ii)), ' ', ... % '\newline', ...
                        ': ', ... % '\newline', ...
                        strrep(name_ix{ii}, '_', '-'), ...
                        ];
                end  
                
                set(gca, 'YTick', 1:n, 'YTickLabel', labels, 'YDir', 'reverse');
                xlim([0 1]);
                ylim([0 n+1]);

                stop = false;
            end
        end
    end
    
    methods (Static)
        function [siz, numEl, fs] = field_sizes(S, fs)
            % [siz, numEl, fs] = field_sizes(S, fieldNames)
            
            if nargin < 2 || isempty(fs)
                fs = fieldnames(S)';
            end
            
            if isempty(fs)
                siz  = {};
                numEl = [];
            else
                for ii = length(fs):-1:1
                    siz{ii}   = size(S.(fs{ii}));
                    numEl(ii) = prod(siz{ii});
                end
            end
        end
    end
end