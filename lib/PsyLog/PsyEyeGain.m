classdef PsyEyeGain < PsyEye
    % Modeled after PsyEyeTobii
    
    properties
        Gain % GuiDaqGain
        
        gui_gain = true;
        a_out = false; % Unsupported yet
    end
    
    methods
        function Eye = PsyEyeGain(varargin)
            Eye = Eye@PsyEye(varargin{:});
        end
        
        function initGain(Eye)
            Gain = GuiDaqGain({ ...
                'gain_out_max', 10
                'gain_out_min', 1/100
                'gain_out_default', 1
                'offset_out_max', 1000
                'offset_out_min', -1000
                'offset_out_default', 0
                'plot_w_sample', true
                'daq_out_w_sample', false
                });
            Eye.Gain = Gain;
        end
        
        function get(Eye) % cXYDeg = get(Eye)
            if Eye.gui_gain
                Gain = Eye.Gain;
                Eye.calibGain = Gain.gain_out;
                disp(Gain.offset_out);
                Eye.calibPix  = Gain.offset_out;
            end
            
            get@PsyEye(Eye);
            
            if Eye.gui_gain
                Gain.sample(Eye.xyPix(:), Eye.sampledAbsSec);
            end
        end        
    end
end