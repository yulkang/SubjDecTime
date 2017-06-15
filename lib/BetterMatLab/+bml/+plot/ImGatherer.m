classdef ImGatherer < matlab.mixin.Copyable
    % Gathers images into subplots of a figure in an additive fashion.
    %
    % 2015 (c) Yul Kang. hk2699 at columbia dot edu.
    
%% Public properties
properties
    h_ax = gobjects(0,0); % Reshape h_ax to change arrangement of subplots.
end
%% Internal properties
properties (Hidden, SetAccess = protected)
    id = '';
    h_fig = gobjects(0,0);
end
%% User Interface
methods
    function Im = ImGatherer
        Im.init;
    end
    function add_figure(Im)
        Im.h_fig(end + 1) = ...
            fig_tag(str_con(Im.id, Im.get_n + 1), 'Visible', 'off');
        clf;
        Im.h_ax(end + 1) = gca;
    end
    function varargout = imgather(Im, varargin)
        % See also: bml.plot.imgather
        if bml.str.strcmpStart(Im.id, get(gcf, 'Tag'))
            figure;
        end
        [varargout{1:nargout}] = bml.plot.imgather(Im.h_ax, {}, varargin{:});
    end
end
%% Internal
methods (Hidden)
    function init(Im)
        Im.id = ['ImGatherer_' randStr];
        Im.h_fig = gobjects(0,0);
        Im.h_ax = gobjects(0,0);
    end
    function n = get_n(Im)
        n = numel(Im.h_ax);
    end
    function delete(Im)
        delete(Im.h_fig);
    end
end
%% Demo
methods
    function test(Im)
        Im.init;
        
        Im.add_figure;
        plot([1 3 2]);
        
        Im.add_figure;
        plot([3 1 4]);
        
        Im.h_ax = Im.h_ax(:);
        Im.imgather;
    end
end
methods (Static)
    function Im = demo
        Im = bml.plot.ImGatherer;
        Im.test;
    end
end
end