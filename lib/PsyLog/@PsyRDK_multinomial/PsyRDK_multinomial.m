classdef PsyRDK_multinomial < PsyRDK_OX
    properties
    end
    
    properties (Dependent)
        n_color
        n_shape
    end
    
    methods
        %% Basic
        function me = PsyRDK_multinomial(cScr, varargin)
            % Construct
            me = me@PsyRDK_OX;
            
            % PsyRDK_OX specific defaults
            me.tag = 'RDK_multinomial';
            me.apInnerRDeg = 0.5;
            me.nDot = 4;
            me.colors = [
                199 220 1
                1 220 255
                202 202 202]';
            
            % shapes_prop: 1 x n_shape cell array of n_line x (x1, y1, x2, y2) matrices.
            me.shapes_prop = {
                [ 0, -1,  1,  1 % <
                  0, -1,  1, -1], ...
                [ 0,  1, -1,  1 % >
                  0,  1, -1, -1], ...
                [-1, -1,  1,  1
                 -1,  1,  1, -1] % X
                  };            
              
            % Initialize
            if nargin > 0, me.Scr = cScr; end
            
            if nargin > 1
                init(me, varargin{:}); 
            end
        end
        
        function init(me, cohs, rSeed, varargin)
            % init(me, cohs, rSeed, varargin)
            %
            % cohs: {coh_shape, coh_color}
            %   Leave empty to leave unchanged.
            %   Each coherence has a size of
            %     [nDot, max_n_fr, nColor] or 
            %     [nDot, max_n_fr, nShape].
            %   If the size(coh,2) == 1, the coh will be constant
            %   for all frames.
            %
            % rSeed: {seed_xy, seed_color, seed_shape}
            %   Each seed is 'shuffle', 'reset', a specific number, 
            %   or empty (to leave it unchanged).
            %
            % init() without arguments will reset rStream, and do 
            % other necessary initialization without changing 
            % parameters, so as to generate the same shape pattern again.
            
            varargin2fields(me, varargin);
            
            % Check size and value of cohs. 
            % (n_color and n_shape should match 3rd dimension's size.)
            if exist('cohs', 'var')
                if ~iscell(cohs) || length(cohs) ~= 2
                    error('Give 2-cell vector for cohs!');
                end
                if ~isempty(cohs{1})
                    me.coh_shape = cohs{1}; 
                    
                    if size(me.coh_shape, 3) ~= me.n_shape
                        error('size(me.coh_shape, 3) must match me.n_shape!');
                    end
                    if size(me.prop, 3) ~= me.n_color
                        error('size(me.prop, 3) must match me.n_color!');
                    end
                end
                if ~isempty(cohs{2})
                    me.prop      = cohs{2}; 
                    
                    if any(me.coh_shape < 0) || any(sum(me.coh_shape, 3) > 1)
                        error('coh_shape should be positive and sum on 3rd dimension must not exceed 1!');
                    end
                    if any(me.prop < 0) || any(sum(me.prop, 3) > 1)
                        error('prop should be positive and sum on 3rd dimension must not exceed 1!');
                    end
                end                
            end
            
            initRStream(me, rSeed);
            
            update(me, 'init');
        end
        
        function initPreCalc(me)
            % Calculate every shape position
            c_ix_xy = zeros(me.nDot, me.maxN);
            
            r = me.rM.rStream;
            c_ix_xy(:, 1) = randsample(r, me.n_grid, me.nDot, false);
            
            % Draw 
            for i_Fr = 2:me.maxN
                check_overlap_in_fr = ...
                    max(i_Fr - me.avoid_overlap_fr, 1):(i_Fr-1);
                
                pop = setdiff(1:me.n_grid, ...
                    hVec(c_ix_xy(:,check_overlap_in_fr)));
                
                c_ix_xy(:, i_Fr) = randsample(r, pop, me.nDot, false);
            end
            
            % Removing overlap yet to implement % TODO

            %% Set ix, the position index.
            me.v_.ix_xy = mat2cell(c_ix_xy, me.nDot, ones(1, me.maxN));
            
            %% Determine color.
            me.v_.col2 = coh2v(me, me.prop, me.n_color, me.rC.rStream);
            
            %% Determine shape.
            me.v_.shape2 = coh2v(me, me.coh_shape, me.n_shape, me.rS.rStream);
            
            %% Pen width.
            me.penWidthPix = me.penWidthDeg * me.Scr.info.pixPerDeg;            
        end        

        %% Subfunctions
        function v = coh2v(me, coh, n_token, r)
            % v = coh2v(me, coh, n_token, r)

            siz     = [me.nDot, me.maxN, me.n_token - 1];
            c_coh   = rep2fit(coh, siz);
            c_token = zeros(me.nDot, me.maxN);
            c_tf    = rand(r, me.nDot, me.maxN, n_token - 1) < c_coh;

            for i_token = 2:n_token
                c_token(c_tf(:,:,i_token-1)) = i_token - 1;
            end
            v = PsyRDK_multinomial.ix2log(c_token);
        end
        
        function updateXY(me)
            % Load from log.
            me.ix_xy = me.vCell('ix_xy', me.i_set);
            addTime(me, {'ix_xy'}, me.Scr.cFr);
        end
        
        function updateCol(me)
            % Load from log.
            me.col2  = me.vCell('col2', me.i_set);
            addTime(me, {'col2'}, me.Scr.cFr);
        end
        
        function updateShape(me)
            % Load from log.
            me.shape2 = me.vCell('shape2', me.i_set); % shape identity
            addTime(me, {'shape2'}, me.Scr.cFr);
            
            me.lines_pix = PsyRDK_OX.shape2line(me.shapes_pix, me.shape2, me.xyPix);
        end
        
        function update(me, from)
            if strcmp(from, 'befDraw')
                me.n = me.n + 1;
                
                if me.i_set <= me.maxN
                    if rem(me.n, me.pres_cycle_len_fr) == 1
                        updateXY(me);
                        updateCol(me);
                        updateShape(me);
                    end
                else
                    hide(me);
                end
            end
        end
        
        function draw(me)
            % Draw only when 
            % (1) visible, and
            % (2) the frame is among show_for_fr / pres_cycle_len_fr.
            if ~me.visible ...
                    || (rem(me.n-1, me.pres_cycle_len_fr) >= me.show_for_fr)
                return; 
            end
            
            addLog(me, {'draw'}, me.Scr.cFr);
            
            % TODO: accelerate by vectorizing.
            for i_shape = 1:me.nDot
                Screen('DrawLines', me.win, ...
                    me.shapes_pix{me.shape2(i_shape) + 1}, ...
                    me.penWidthPix, ...
                    me.colors(:, me.col2(i_shape) + 1), ...
                    me.apCenterPix + me.xy_grid_pix(:, me.ix_xy(i_shape))');
            end
        end
        
        %% Shapes
        function shapes_prop2pix(me)
            n_shapes = me.n_shape;
            
            me.shapes_pix = cell(1, n_shapes);
            
            for i_shape = 1:n_shapes
                me.shapes_pix{i_shape} = xy4lines( ...
                    me.shapes_prop{i_shape}(:,1), ...
                    me.shapes_prop{i_shape}(:,2), ...
                    me.shapes_prop{i_shape}(:,3), ...
                    me.shapes_prop{i_shape}(:,4) ...
                    ) * me.dotSizeDeg * me.Scr.info.pixPerDeg;
            end
        end
        
        function init_xy_grid(me)
            [x, y] = PsyRDK_OX.gridPoint(me.grid_type, me.apRDeg, me.apInnerRDeg, ...
                        me.grid_size_deg, false);

            me.xy_grid_deg = [x(:)'; y(:)'];
            me.xy_grid_pix = me.xy_grid_deg * me.Scr.info.pixPerDeg;                    
        end
        
        %% Evidence
        function [CEsum, mCE, cCE, tf, LLR] = roughEnCol(me, ~, propRep, varargin)
            
        end
        
        function [SEsum, mSE, cSE, tf, LLR] = roughEnShape(me, ~, propRep, varargin)
            % [SEsum, mSE, cSE, tf, LLR] = roughEnShape(me, ~, propRep, varargin)
            
            % Defaults
            if ~exist('propRep', 'var'), propRep = []; end

            % Calculate Shape Evidence
            [SEsum, mSE, cSE, tf, LLR] = ...
                roughEnCol(me, [], propRep, 'shape2', 'S');
        end
        
        function varargout = EnShape(me, varargin)
            % See also: roughEnShape
            
            % TODO: Consider temporal smear
            [varargout{1:nargout}] = roughEnShape(me, varargin{:});
        end
        
        %% Plots
        function [x, y] = plot_gridPoint(me)
            fig_tag('grid_point');
            [x, y] = PsyRDK_OX.gridPoint(me.grid_type, me.apRDeg, me.apInnerRDeg, ...
                me.grid_size_deg, true);
        end
        
        function plot_shape(me)            
            for i_shape = 1:2
                subplot(1, 2, i_shape);
            
                for i_line = 1:size( me.shapes_prop{i_shape}, 1);
                    plot(me.shapes_prop{i_shape}(i_line, [1 3]), ...
                         me.shapes_prop{i_shape}(i_line, [2 4])); 
                    hold on;
                end
                hold off;
                axis square;
            end
        end        
        
        function plot_timeline(me)
            fig_tag('RDK_OX_timeline');
            
            shapes = cell2mat(me.v('shape2')')';
            colors = cell2mat(me.v('col2')')';
            
            shape_str = 'xot';
            
            n_draw = me.n_.col2;
            
            cla;
            for i_shape = 1:2
                c_shape = shape_str(i_shape);
                
                for i_color = 1:2
                    c_color = me.colors(:,i_color)/255;
                    
                    filt = (shapes == (i_shape - 1)) ...
                         & (colors == (i_color - 1));
                    
                    for i_draw = 1:n_draw
                        if any(filt(:,i_draw))
                            x = i_draw + zeros(1, nnz(filt(:,i_draw)));
                            y = find(filt(:,i_draw));

                            plot(x, y, c_shape, 'Color', c_color);
                            hold all;
                        end
                    end
                end
            end
            set(gca, 'Color', 'k');
            xlim([0, me.n_.col2 + 1]);
            ylim([0, me.n_grid + 1]);
        end
        
        %% Dependent properties or the like
        function v = get.n_shape(me)
            % Depends on me.shapes_prop.
            
            v = length(me.shapes_prop);
        end
        
        function v = get.n_color(me) 
            % Depends on me.colors.
            
            v = size(me.colors, 2);
        end
    end
    
    methods (Static)
        [me, Scr] = test()
        
        function v = ix2log(ix)
            % Convert nDot x nFr x nMultinomial matrix into 1 x nFr cell array of 
            % 1 x nDot x nMultinomial arrays.
            
            ix = permute(ix, [2 1 3]);
            v  = num2cell(ix, [2 3])';
        end
    end
end