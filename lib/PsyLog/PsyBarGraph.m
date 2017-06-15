classdef PsyBarGraph < PsyPTBs
    properties
        v
        v_max
        
        c = struct( ...
            'Bkg', [], ...
            'Fill', [], ...
            'Frame', [], ...
            'Tick', [], ...
            'Horz', [] ...
            );
        
        conf = [];
    end
   
    methods
        %% Essential
        function me = PsyBarGraph(cScr, varargin)
            me = me@PsyPTBs;
            
            me.tag = 'BarGraph';
            me.updateOn = {'befDraw'};
            
            if nargin > 0, me.Scr = cScr; end
            if nargin > 1
                me.init(varargin{:});
            end
        end
        
        function init(me, kind, varargin)
            % init(me, kind, varargin)
            %
            % 'history_n_current'
            %
            % 'kind', kind, ...
            % 'n', 5, ...
            % 'bounding_xyDeg', [0 0]', ...
            % 'bounding_sizeDeg', [3 2]', ...
            % 'widthProp_between_history_current', 0.1, ...
            % 'widthProp_between_history', 0.5, ...
            % 'fill_color_history', [40 40 40], ...
            % 'fill_color_current', [100 100 100], ...
            % 'frame_color_history', [1 1 1], ...
            % 'frame_color_current', [40 40 40], ...
            % 'frame_thickness_deg', 0.02, ...
            % 'bkg_color', [1 1 1], ...
            % 'v', 0.5+zeros(1,5), ...
            % 'v_max', ones(1,5), ...
            % 'v_horz_line', nan, ...
            % 'horz_color', [100 100 100], ...
            % 'horz_thickness_deg', 0.15, ...
            % 'tick_v', 0.2:0.2:0.8, ... % in [0, 1]
            % 'tick_length_deg', 0.2, ...
            % 'tick_thickness_deg', 0.075, ...
            % 'tick_color', [40 40 40] ...            
            
            switch kind
                case 'history_n_current'
                    if isempty(me.conf)
                        me.conf = struct(...
                            'kind', kind, ...
                            'n', 5, ...
                            'bounding_xyDeg', [0 0]', ...
                            'bounding_sizeDeg', [3 2]', ...
                            'widthProp_between_history_current', 0.1, ...
                            'widthProp_between_history', 0.5, ...
                            'fill_color_history', [60 60 60], ...
                            'fill_color_current', [100 100 100], ...
                            'frame_color_history', [1 1 1], ...
                            'frame_color_current', [40 40 40], ...
                            'frame_thickness_deg', 0.02, ...
                            'bkg_color', [1 1 1], ...
                            'v', 0.5+zeros(1,5), ...
                            'v_max', ones(1,5), ...
                            'v_horz_line', nan, ...
                            'horz_color', [60 60 60], ...
                            'horz_thickness_deg', 0.075, ...
                            'tick_v', 0.2:0.2:0.8, ... % in [0, 1]
                            'tick_length_deg', 0.2, ...
                            'tick_thickness_deg', 0.075, ...
                            'tick_color', [40 40 40] ...
                           );
                    end
                    me.conf = varargin2S(varargin, me.conf, false);
                    
                    unpackStruct(me.conf);
                    
                    me.v     = v;
                    me.v_max = v_max;
                    
                    if n < 2
                        error('n should be no less than 2!');
                    end
                    
                    % Convenience functions
                    rep_all      = @(a) repmat(a, [1 n]);
                    rep_hist_cur = @(a, b) [repmat(a, [1 n-1]), b];
                    
                    % Width
                    widthProp_bar = (1 - widthProp_between_history_current) ...
                                  / ((n - 2) * widthProp_between_history + n) / 2;
                                    
                    widthProp_between_bars = widthProp_bar * widthProp_between_history;
                    
                    widthDeg_bar = widthProp_bar * bounding_sizeDeg(1) * 2;
                    widthDeg_between_bars = widthProp_between_bars * bounding_sizeDeg(1) * 2;
                    
                    % Position
                    xDeg_history = bounding_xyDeg(1) - bounding_sizeDeg(1) ...
                        + widthDeg_bar + (0:(n-2))*(widthDeg_bar+widthDeg_between_bars)*2;
                    xDeg_current = bounding_xyDeg(1) + bounding_sizeDeg(1) ...
                        - widthDeg_bar;
                    yDeg = rep_all(bounding_xyDeg(2));
                          
                    % Frame
                    frame_rect = ...
                        {rep_hist_cur(frame_color_history(:), ... % color
                                      frame_color_current(:)), ...
                         [xDeg_history, xDeg_current; yDeg], ...  % xyDeg
                         [widthDeg_bar + zeros(1, n); ... % sizeDeg
                          bounding_sizeDeg(2) + zeros(1, n)], ...
                          'penWidthDeg', frame_thickness_deg};
                    
                    % Fill  
                    fill_rect = me.frame2fill(frame_rect, ...
                        rep_hist_cur(fill_color_history(:), ...
                                     fill_color_current(:)));
                    
                    % Background
                    bkg_rect = {bkg_color(:), bounding_xyDeg(:), bounding_sizeDeg(:)};
                    
                    % Tick
                    y0   = bounding_xyDeg(2) + bounding_sizeDeg(2);
                    y_size = -2 * bounding_sizeDeg(2);
                    y_st = y0 + tick_v * y_size;
                    y_en = y_st;
                    x_st = repmat(bounding_xyDeg(1) + bounding_sizeDeg(1), size(y_st));
                    x_en = x_st + tick_length_deg;
                    tick_lines = {xy4lines(x_st, y_st, x_en, y_en), ...
                                  tick_thickness_deg, tick_color(:), bounding_xyDeg};
                              
                    % Horz line
                    y_horz = y0 + v_horz_line/me.v_max * y_size;
                    x_horz_st = bounding_xyDeg(1) - bounding_sizeDeg(1);
                    x_horz_en = bounding_xyDeg(1) + bounding_sizeDeg(1);
                    horz_line = {xy4lines(x_horz_st, y_horz, x_horz_en, y_horz), ...
                        horz_thickness_deg, horz_color(:), bounding_xyDeg};
            end
            
            me.c.Bkg   = PsyPTB(me.Scr, 'FillRect', bkg_rect{:});
            me.c.Fill  = PsyPTB(me.Scr, 'FillRect', fill_rect{:});
            me.c.Frame = PsyPTB(me.Scr, 'FrameRect', frame_rect{:});
            me.c.Tick  = PsyPTB(me.Scr, 'DrawLines', tick_lines{:});
            me.c.Horz  = PsyPTB(me.Scr, 'DrawLines', horz_line{:});
        end
        
        function update(me, ~)
            frame2fill(me);
        end
        
        %% Additional
        function fill_rect = frame2fill(me, frame_rect, col)
            % fill_rect = frame2fill(me, frame_rect, col)
           
            me.v(isnan(me.v)) = 0;
            
            if nargin < 2
                frame_rect = {me.c.Frame.color, me.c.Frame.xyDeg, me.c.Frame.sizeDeg};
            end
            
            fill_rect = cell(1,3);
            
            if nargin < 3
                fill_rect{1} = me.c.Fill.color;
            else
                fill_rect{1} = col;
            end
            
            xyDeg_frame   = frame_rect{2};
            sizeDeg_frame = frame_rect{3};
            
            sizeDeg_fill(1,:)  = sizeDeg_frame(1,:);
            sizeDeg_fill(2,:)  = sizeDeg_frame(2,:) .* (me.v ./ me.v_max);
            
            xyDeg_fill(1,:) = xyDeg_frame(1,:);
            xyDeg_fill(2,:) = xyDeg_frame(2,:) ...
                + (sizeDeg_frame(2,:) - sizeDeg_fill(2,:));
            
            fill_rect{2} = xyDeg_fill;
            fill_rect{3} = sizeDeg_fill;
            
            % Directly modify Fill, or just return the arguments.
            try
                me.c.Fill.initPsyProps('FillRect', fill_rect{:});
                me.c.Fill.argsPsy2PTB;
            catch err_dummy %#ok<NASGU>
            end
        end
    end
end