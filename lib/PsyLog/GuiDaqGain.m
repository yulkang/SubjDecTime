classdef GuiDaqGain < handle
    properties
        %% Handles
        h_fig
        h_ax
        h_title
        h_sl_gain
        h_sl_offset
        h_sl_time
        h_daq
        h_plot
        h_vertline
        
        %% Samples
        t_span = []; % time span to display
        n_samp = 300; % How many total samples are displayed 
        v_samp = [];
        o_samp = [];
        t_samp = [];
        i_samp = 1;
        
        %% Plot
        out_names = {'x', 'y'};
        plot_w_sample = true; % DEBUG
        daq_out_w_sample = false; % DEBUG
        
        %% Daq
        n_out = 2;
        
        chn_out = [0, 1];
        
        %% Output Gain, Offset % TODO: set slider max/min directly?
        gain_out_max = 1;
        gain_out_min = 1/100;
        gain_out_default = 1/50;
        
        offset_out_max = 5;
        offset_out_min = -5;
        offset_out_default = 0;
        
        %% Time Gain (= n_samp)
        gain_t_max = 2000;
        gain_t_min = 10;
        gain_t_default = 900;
    end
    
    properties (Dependent)        
        gain_out
        offset_out
        
        gain_t
    end
    
    methods
        %% Interface
        function Gain = GuiDaqGain(varargin)
            varargin2fields(Gain, varargin);
            
            init(Gain);
        end
        
        function sample(Gain, samp, t)
            % SAMPLE  Add sample(s), optionally with time.
            %
            % sample(Gain, samp, t)
            %
            % samp(s,k): s-th source, k-th sample
            % t(k)     : k-th sample
            
            n = size(samp, 2);
            c_n_out = Gain.n_out;
            assert(size(samp, 1) == c_n_out, 'Sampe #row should match n_out!');
            
            c_i_samp = Gain.i_samp;
            c_n_samp = Gain.n_samp;
            
            % Determine where to record
            c_ix = ix_wrap(c_i_samp, n, c_n_samp);
            
            % Record samples
            Gain.v_samp(:,c_ix) = samp;
            Gain.o_samp(:,c_ix) = max(0, min(1, ...
                bsxfun(@plus, ...
                    bsxfun(@times, ...
                        samp, ...
                        Gain.gain_out(:)), ...
                    Gain.offset_out(:)) ...
                ));
            
            % Record t
            if nargin >= 3
                Gain.t_samp(c_ix) = t(:)';
            end
            
            % Increase index
            Gain.i_samp = ix_wrap(c_i_samp + n, 1, c_n_samp);
            
            % Plot
            if Gain.plot_w_sample, plot(Gain); end
            
            % Daq out
            if Gain.daq_out_w_sample, daq_out(Gain); end
        end
        
        function plot(Gain)
            h_pl = Gain.h_plot;
            
            % Read gain from sliders
            c_gain_out = Gain.gain_out;
            c_gain_t   = Gain.gain_t;
            
            % Set time
            x = 1:Gain.n_samp;
            y = Gain.o_samp;
            
            % Plot
            for ii = 1:Gain.n_out
                set(h_pl(ii), ...
                    'XData', x, ...
                    'YData', y(ii,:));
            end
        end
        
        function daq_out(Gain)
            c_h_daq   = Gain.h_daq;
            c_chn_out = Gain.chn_out;
            
            c_samp = Gain.v_samp(:, ix_wrap(Gain.i_samp - 1, 1, Gain.n_samp));
            
            for ii = 1:Gain.n_out
                DaqAOut(c_h_daq, c_chn_out(ii), c_samp(ii));
            end
        end
        
        %% Internal
        function init(Gain)
            % Initialize variables according to n_out
            
            % Samples
            Gain.v_samp = nan(Gain.n_out, Gain.n_samp);
            Gain.o_samp = nan(Gain.n_out, Gain.n_samp);
            Gain.t_samp = nan(1, Gain.n_samp);
            
            % Figure
            Gain.h_fig = fig_tag('DaqGain'); clf;
            set_size(Gain.h_fig, [500, 300*Gain.n_out], 'NE');
            set(Gain.h_fig, 'CloseRequestFcn', @(src,evt) close(Gain));
            
            % Plot & Slider
            for ii = 1:Gain.n_out
                subplot(Gain.n_out, 1, ii);
                Gain.h_plot(ii) = plot(Gain.t_samp(:), Gain.v_samp(ii,:));
                Gain.h_ax(ii) = gca;
                ylim([0 1]); % PTB's DaqAOut uses 0-1 range for 0-4.095V.
                
                pos = get(Gain.h_ax(ii), 'Position');
                Gain.h_title(ii) = title(Gain.out_names{ii}, 'FontSize', 12);
                
                % Gain
                Gain.h_sl_gain(ii) = uicontrol('Style', 'slider', ...
                    'Units', 'normalized', ...
                    'Position', [pos(1)/3, pos(2), pos(1)/3, pos(4)]);
                
                % Set default output gain
                v = (Gain.gain_out_default - Gain.gain_out_min) ...
                    / (Gain.gain_out_max - Gain.gain_out_min);
                set(Gain.h_sl_gain(ii), 'Value', v);
                
                % Offset
                Gain.h_sl_offset(ii) = uicontrol('Style', 'slider', ...
                    'Units', 'normalized', ...
                    'Position', [0, pos(2), pos(1)/3, pos(4)]);
                
                % Set default output gain
                v = (Gain.offset_out_default - Gain.offset_out_min) ...
                    / (Gain.offset_out_max - Gain.offset_out_min);
                set(Gain.h_sl_offset(ii), 'Value', v);
            end
            
            % Position the time gain slider under the last plot
            Gain.h_sl_time = uicontrol('Style', 'slider', ...
                'Units', 'normalized', ...
                'Position', [pos(1), pos(2)/3, pos(3), pos(2)/3]);
            
            % Set default time gain
            v = (Gain.gain_t_default - Gain.gain_t_min) ...
                / (Gain.gain_t_max - Gain.gain_t_min);
            set(Gain.h_sl_time, 'Value', v);
            
            % Daq % DEBUG
%             Gain.h_daq = DaqDeviceIndex;
%             
%             assert(length(Gain.h_daq) == 1, 'Currently supports only one Daq connected!');

            % Set title
            set_titles(Gain);
        end
        
        function close(Gain)
            try
                delete(Gain.h_fig);
            catch err
                warning(err_msg(err));
            end
            Gain.h_fig = [];
        end
        
        %% Get/Set functions
        function v = get.gain_out(Gain)
            persistent p_gain_out
            
            n      = Gain.n_out;
            c_h_sl = Gain.h_sl_gain;
            c_max  = Gain.gain_out_max;
            c_min  = Gain.gain_out_min;
            
            v = zeros(1,n);
            
            for ii = 1:n
                v(ii) = get(c_h_sl(ii), 'Value') * (c_max - c_min) + c_min;
            end
            
            if ~isequal(v, p_gain_out)
                p_gain_out = v;
                set_titles(Gain);
            end
        end
        
        function v = get.offset_out(Gain)
            persistent p_offset_out
            
            n      = Gain.n_out;
            c_h_sl = Gain.h_sl_offset;
            c_max  = Gain.offset_out_max;
            c_min  = Gain.offset_out_min;
            
            v = zeros(1,n);
            
            for ii = 1:n
                v(ii) = get(c_h_sl(ii), 'Value') * (c_max - c_min) + c_min;
            end
            
            if ~isequal(v, p_offset_out)
                p_offset_out = v;
                set_titles(Gain);
            end
        end
        
        function set_titles(Gain)
            % Display gain & offset in title                
            c_h_title = Gain.h_title;
            c_names   = Gain.out_names;

            c_gain_out   = Gain.gain_out;
            c_offset_out = Gain.offset_out;
            
            n = length(c_gain_out);

            for ii = 1:n
                set(c_h_title(ii), 'String', ...
                    sprintf('%s: 1/%1.0f + %1.0f', c_names{ii}, ...
                        1/c_gain_out(ii), c_offset_out(ii)));
            end            
        end
        
        function v = get.gain_t(Gain)
            persistent p_gain_t
            
            v = 1; % TODO
            
            if ~isequal(v, p_gain_t)
                % Change event % TODO
                % Change number of samples displayed, for example.
            end
            
            p_gain_t = v;
        end
    end
end