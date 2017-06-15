classdef GuiTargetMonitor < handle
    properties
        targ_xy   = [0; 0];
        targ_size = cat(3,1,2); % [targ_size_appearance; win_size_appearance]
        targ_col  = {'k', 'b', 'r', 'g', 'c', 'm'};
        
        p_targ_xy = [];
        
        trace_xy  = [0; 0];
        trace_col = [1 0 0];
        
        xlim = [-20 20];
        ylim = [-20 20];
        
        tick = 2;
    end
    
    properties (Transient) % No need to save handles
        h_ax    = []; % axes
        h_targ  = {}; % cell array of targ handles.
        h_trace = {}; % cell array of trace handles.
        
        h_targ_xy  = {};
        h_trace_xy = {};
    end
    
    properties (Dependent)
        targ_coord
        trace_coord
    end
    
    methods
        function Mon = GuiTargetMonitor(varargin)
            
            varargin2fields(Mon, varargin);
            
%             replot(Mon);
        end
        
        function res = draw(Mon, ~)
            % Fast update of the trace position
            %
            % res = draw(Mon, ~)
            
            if ~isequal(Mon.targ_xy, Mon.p_targ_xy)
                c_targ_coord = Mon.targ_coord;
                c_h_targ_xy  = Mon.h_targ_xy;
                
                for i_targ = 1:size(c_targ_coord,2)
                    c_h_targ_xy{1,i_targ}.setDataBufferData(c_targ_coord(:,i_targ,1));
                    c_h_targ_xy{2,i_targ}.setDataBufferData(c_targ_coord(:,i_targ,2));
                end
            end
            
            c_trace_coord = Mon.trace_xy;
            c_trace_xy    = Mon.h_trace_xy;
            
            c_trace_xy{1}.setDataBufferData(c_trace_coord(1));
            c_trace_xy{2}.setDataBufferData(c_trace_coord(2));
            
            % PsyScr interface
            res = true;
        end
        
        function replot(Mon)
            % When target or trace number is changed, call this
            % instead of draw. Slower but updates necessary parts.
            
            c_targ_coord  = Mon.targ_coord;
            c_trace_coord = Mon.trace_xy;
            
            n_targ = size(c_targ_coord,2);
            C = cell(1, n_targ);
            
            for ii = 1:n_targ
                C{ii} = {'LineSpec', '-', 'Color', Mon.targ_col{ii}};
            end
            
            [Mon.h_ax, Mon.h_targ] = wtl.plot(Mon.h_ax, Mon.h_targ, ...
                c_targ_coord(:,:,1),  c_targ_coord(:,:,2), C);
            
            [Mon.h_ax, Mon.h_trace] = wtl.plot(Mon.h_ax, Mon.h_trace, ...
                c_trace_coord(1), c_trace_coord(2));

            for ii = 1:length(Mon.h_targ)
                Mon.h_targ_xy{1,ii} = Mon.h_targ{ii}.getXData;
                Mon.h_targ_xy{2,ii} = Mon.h_targ{ii}.getYData;
            end
            
            for ii = 1:length(Mon.h_trace)
                Mon.h_trace_xy{1,ii} = Mon.h_trace{ii}.getXData;
                Mon.h_trace_xy{2,ii} = Mon.h_trace{ii}.getYData;
            end
            
            wtl.lim(Mon.h_ax, 'x', Mon.xlim);
            wtl.lim(Mon.h_ax, 'y', Mon.ylim);
            wtl.tick(Mon.h_ax, 'x', Mon.tick);
            wtl.tick(Mon.h_ax, 'y', Mon.tick);
            
            Mon.h_ax.getView.setReverseY(true);
        end
        
        function v = get.targ_coord(Mon)
            % dims: ([x y], targs, [siz sensR])
            
            xy   = Mon.targ_xy;
            siz  = Mon.targ_size;
            
            Mon.p_targ_xy = xy;
            
            if size(siz,1) == 1, siz = repmat(siz, [2 1 1]); end
            
            v = cat( 3, ... 
               [xy(1,:) - siz(1,:,1)
                xy(1,:) + siz(1,:,1)
                xy(1,:) + siz(1,:,1)
                xy(1,:) - siz(1,:,1)
                xy(1,:) - siz(1,:,1)
                xy(1,:) - siz(1,:,2)
                xy(1,:) + siz(1,:,2)
                xy(1,:) + siz(1,:,2)
                xy(1,:) - siz(1,:,2)
                xy(1,:) - siz(1,:,2)], ...
               [xy(2,:) - siz(2,:,1)
                xy(2,:) - siz(2,:,1)
                xy(2,:) + siz(2,:,1)
                xy(2,:) + siz(2,:,1)
                xy(2,:) - siz(2,:,1)
                xy(2,:) - siz(2,:,2)
                xy(2,:) - siz(2,:,2)
                xy(2,:) + siz(2,:,2)
                xy(2,:) + siz(2,:,2)
                xy(2,:) - siz(2,:,2)]);
        end
        
        function v = get.trace_coord(Mon)
            v = Mon.trace_xy;
        end
        
        function res = set_trace_xy(Mon, xy)
            % res = set_trace_xy(Mon, xy)
            
            Mon.trace_xy = xy;
            res = true;
        end
    end
    
    methods (Static)
        function Mon = test
            Mon = GuiTargetMonitor('targ_xy', [1;1]);
            tic; for ii = 1:1000; Mon.draw; end; toc;
        end
    end
end