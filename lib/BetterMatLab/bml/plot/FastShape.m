classdef FastShape
    properties
        h               % Handle of the line object
        x_src           % Source x
        y_src           % Source y
        scale_x = 1;    % Multiplies x_src
        scale_y = 1;    % Multiplies y_src
        x = 0;          % Adds to x_src * scale_x
        y = 0;          % Adds to y_src * scale_y
    end
    
    properties (Dependent)
        x_dst   % x in the axes coordinate
        y_dst   % y in the axes coordinate
    end
    
    methods
        function me = FastShape(xy_src, varargin)
            % me = FastShape(xy_src, ['line_property1', line_property1, ...])
            %
            % xy_src: [N x 2] matrix of [x_src(:), y_src(:)].
            
            me.x_src = xy_src(:,1);
            me.y_src = xy_src(:,2);
            
            me.h = line(xy_src(:,1), xy_src(:,2), varargin{:});
        end
        
        function [x_out, y_out] = set(me, x, y, scale_x, scale_y)
            if exist('x', 'var') && ~isempty(x), me.x = x; end
            if exist('y', 'var') && ~isempty(y), me.y = y; end
            if exist('scale_x', 'var') && ~isempty(scale_x), me.scale_x = scale_x; end
            if exist('scale_y', 'var') && ~isempty(scale_y), me.scale_y = scale_y; end
            
            x_out = me.x_dst;
            y_out = me.y_dst;
            
            set(me.h, 'XData', x_out, 'YData', y_out);
        end
        
        function x_out = get.x_dst(me)
            x_out = me.x_src * me.scale_x + me.x;
        end
        
        function y_out = get.y_dst(me)
            y_out = me.y_src * me.scale_y + me.y;
        end
    end
end