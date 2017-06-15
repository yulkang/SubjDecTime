classdef PsyRDK_OX < PsyRDKConst
    properties
        %% Shape parameters
        % Separate randstream for shape
        rS = PsyRStream % For shape identity
        
        coh_shape; % shape coherence. Probability of shape2.
        
        shape2 = []; % 1 x nDot vector
        
        % shapes_prop: 1 x n_shape cell array of n_line x (x1, y1, x2, y2) matrices.
        shapes_prop = {...
            [ 0,  0, -1, -1
              0,  0,  1,  1
              0,  0,  1, -1
              0,  0, -1,  1], ...
            [-1,  0,  0,  1 % diamond
              0,  1,  1,  0
              1,  0,  0, -1
              0, -1, -1,  0]};
%             [-1, -1, -1,  1 % square
%              -1,  1,  1,  1
%               1,  1,  1, -1
%               1, -1, -1, -1
%             ]*.71};

        % shapes_pix: 1 x n_shape cell array of (x,y) x (n_line*2) matrices.
        shapes_pix = {};
        
        lines_pix = [];
        
        enforce_shape_diameter = 'none'; % 'even'|'odd'|'none'
        
        %% Grid parameters
        % grid_type: 
        % 'xy'        : Regularly spaced on x and y positions.
        % 'concentric': Regularly spaced equidistant positions.
        grid_type = 'xy';
        
        % grid_size_deg:
        %   for grid_type == 'xy'
        %   : Space between x and y vertices. Every other one is skipped.
        %
        %   for grid_type == 'concentric'
        %   : {r_deg, n_points, phase}
        %       r_deg:    Radius of the circle. Currently scalar only.
        %       n_points: Number of grid points on the corresponding circle.
        %       phase:    Phase of the grid point locations in radian.
        grid_size_deg = 1;
        
        xy_grid_deg = []; % 2 x nDot
        xy_grid_pix = []; % 2 x nDot
        
        ix_xy = []; % nDot x maxFr
        
        %% Feature combination parameters
        feat_names = {'shape', 'color'};
        
        %% Temporal parameters
        t_freq = 10;
        show_for_prop = 0.5;
        
        % avoid_overlap_fr: Avoid showing the shape at overlapping position for this many 'flash'es.
        avoid_overlap_fr = 1;
        
        % balance_feat:
        % each cell is a scalar numeric (number of initial frames to balance).
        balance_feat = {0, 0}; 
    end
    
    properties (Dependent)
        n_grid
        show_for_fr
        pres_cycle_len_fr
    end
    
    methods
        %% Basic
        function me = PsyRDK_OX(cScr, varargin)
            % Construct
            me = me@PsyRDKConst;
            
            % PsyRDK_OX specific defaults
            me.tag = 'RDK_OX';
            me.apInnerRDeg = 0.5;
            me.nDot = 4;
            me.colors = [199 220 1; 1 220 255]';
            
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
            %
            % rSeed: {seed_xy, seed_color, seed_shape}
            %   Each seed is 'shuffle', 'reset', a specific number, 
            %   or empty (to leave it unchanged).
            %
            % init() without arguments will reset rStream, and do 
            % other necessary initialization without changing 
            % parameters, so as to generate the same shape pattern again.
            
            if exist('cohs', 'var')
                if ~iscell(cohs) || length(cohs) ~= 2
                    error('Give 2-cell vector for cohs!');
                end
                if ~isempty(cohs{1}), me.coh_shape = cohs{1}; end
                if ~isempty(cohs{2}), me.prop      = cohs{2}; end
            end
            
            varargin2fields(me, varargin);
            
            initRStream(me, rSeed);
            
            update(me, 'init');
        end
        
        function initTrial(me)
            c_nDot = me.nDot; % Disable automatic setting of nDot
            
            me.initTrial@PsyRDKCol;
            
            me.nDot = c_nDot;
            
            shapes_prop2pix(me);
            init_xy_grid(me);
        end
        
        function initLogEntries(me, varargin)
            if nargin > 2
                me.initLogEntries@PsyPTB(varargin{:});
            else
                switch me.replayLevel
                case 'none'
                    me.initLogEntries@PsyLogs('propCell', {'ix_xy', 'col2', 'toShow', 'shape2'}, ...
                                             'fr', {}, me.maxN); 
                    me.initLogEntries@PsyLogs('mark', {'draw'}, 'fr', {nan}, me.maxN);                
                    
                case 'contents'
                    me.initTimeEntries({'ix_xy', 'col2', 'toShow', 'shape2'}, ...
                                             me.maxN); 
                end
            end
        end
        
        function initRStream(me, rSeed)
            if iscell(rSeed)
                me.initRStream@PsyRStream(rSeed{1});

                % Always generate three numbers.
                seeds = floor(rand(me.rStream, 1,3) * 2^31);
                
                % Use the general randStream to generate seeds for
                % the other randStreams.
                %
                % Since we always generate three numbers, given the same
                % general seed, the other stream(s) with 'shuffle' gives
                % same results.
                for iSeed = 1:3
                    if strcmp(rSeed{1+iSeed}, 'shuffle')
                        rSeed{1+iSeed} = seeds(iSeed); 
                    end
                end
                
                me.rM.initRStream(rSeed{2});
                me.rC.initRStream(rSeed{3});
                me.rS.initRStream(rSeed{4});
            
            else
                error('Provide {seedGeneral, seedXY, seedColor, seedShape}!');
            end
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

            % Set ix
            me.v_.ix_xy = mat2cell(c_ix_xy, me.nDot, ones(1, me.maxN));
            
            % Calculate every color.
            c_color2 = rand(me.rC.rStream, me.nDot, me.maxN) < me.prop;
            me.v_.col2 = PsyRDK_OX.ix2log(c_color2);
            
            % Calculate every shape identity.
            c_shape2 = rand(me.rS.rStream, me.nDot, me.maxN) < me.coh_shape;
            me.v_.shape2 = PsyRDK_OX.ix2log(c_shape2);
            
            % Pen
            me.penWidthPix = me.penWidthDeg * me.Scr.info.pixPerDeg;
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
            n_shapes = length(me.shapes_prop);
            
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
            
            shape_str = 'xo';
            
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
        function v = get.n_grid(me)
            v = size(me.xy_grid_deg, 2);
        end
        
        function v = get.pres_cycle_len_fr(me)
            v = round(me.Scr.info.refreshRate / me.t_freq);
        end
        
        function v = get.show_for_fr(me)
            v = round(me.show_for_prop * me.pres_cycle_len_fr);
        end
        
        function v = maxN(me)
            v = maxN@PsyRDKConst(me);
            v = ceil(v / me.pres_cycle_len_fr);
        end
        
        function v = i_set(me)
            v = floor((me.n - 1) / me.pres_cycle_len_fr) + 1;
        end
        
        function v = getNDot(me)
            v = me.nDot; % No automatic estimation.
        end
    end
    
    methods (Static)
        [me, Scr] = test()
        
        function [x y] = gridPoint(typ, rOut, rIn, gridSize, toPlot)
            % [x y] = gridPoint(typ, rOut, rIn, gridSize, [toPlot = false])
            %
            % typ:
            % 'xy'        : Regularly spaced on x and y positions.
            % 'concentric': Regularly spaced equidistant positions.
            %
            % gridSize:
            %   for grid_type == 'xy'
            %   : Space between x and y vertices. Every other one is skipped.
            %
            %   for grid_type == 'concentric'
            %   : {r_deg, n_points}
            %       r_deg: Radius of the circle. Currently scalar only.
            %       n_points: Number of grid points on the corresponding circle.
            %       phase:    Phase of the grid point locations in radian.
        
            if ~exist('typ', 'var'), typ = 'xy'; end
            if ~exist('toPlot', 'var'), toPlot = false; end
            
            switch typ
                case 'xy'
                    rO2 = floor(rOut / gridSize) * gridSize;

                    xRep = [-rO2:gridSize:-gridSize, 0:gridSize:rO2];
                    yRep = xRep;

                    [x y] = meshgrid(xRep, yRep);

                    x = x(:);
                    y = y(:);
                    d = x.^2 + y.^2;

        %             ind  = (1:length(x))';
        %             ind0 = mod(ind((x==0) & (y==0)), 2);

                    toIncl = (rIn.^2 <= d) & (d <= rOut.^2); %  & (mod(ind,2)==ind0);

                    x = x(toIncl);
                    y = y(toIncl);
                    
                case 'concentric'
                    r_deg   = gridSize{1};
                    n_point = gridSize{2};
                    ph      = gridSize{3};
                    n       = sum(n_point);
                    n_circ  = length(gridSize{1});
                    
                    x = zeros(n, 1);
                    y = zeros(n, 1);
                    
                    c_n = 0;
                    for i_circ = 1:n_circ
                        
                        % Sample around the circle
                        th   = ph + linspace(0, 2*pi, n_point(i_circ) + 1);
                        th   = th(1:(end-1));
                        
                        % Convert to x & y
                        c_ix               = c_n + (1:n_point(i_circ));
                        [x(c_ix), y(c_ix)] = pol2cart(th, r_deg(i_circ));
                        c_n                = c_n + n_point(i_circ);
                    end
            end
            
            if toPlot
                [oX oY] = pol2cart(0:0.1:pi*2.1, rOut);
                [iX iY] = pol2cart(0:0.1:pi*2.1, rIn);
                
                plot(oX, oY, 'k-', iX, iY, 'k-'); hold on;
                plot(x,y,'b.'); axis tight; axis square; hold off;
            end
        end      
        
        function v = ix2log(ix)
            % Convert nDot x nFr matrix into 1 x nFr cell array of 
            % 1 x nDot vectors.
            
            nFr = size(ix, 2);
            
            v = mat2cell(ix', ones(nFr, 1))';
        end
        
        function lines = shape2line(shapes, shape2, xyPix)
            % lines = shape2line(shapes, shape2, xyPix)
            
            lines = reshape( ...
                bsxfun(@plus, ...
                    cell2mat(shapes(shape2 + 1)), ...
                    reshape(xyPix, 2, 1, []) ...
                ), 2, []);
        end
    end
end