classdef PsyEyeTobii < PsyMouse
    properties
        use_tetio  = true;
        tracker_ID = '';
        
        Calib_struct = [];
        
        frame_rate = [];
       
        a_out = true;
        Gain % GuiDaqGain
    end
    
    methods
        function Eye = PsyEyeTobii(cScr, varargin)
            
            %% PsyDeepCopy interface
            Eye = Eye@PsyMouse;
            Eye.tag = 'Eye';
            
            if nargin > 0
                Eye.Scr = cScr; 
            else
                Eye.Scr = PsyScr;
            end
            
            %% Default values
            Eye.init(varargin{:});
        end
        
        % Common to PsyEye
        function init(Eye, varargin) % TODO: sampling rate, etc.
            global USE_TETIO
            
            Eye = varargin2fields(Eye, varargin);
            
            USE_TETIO = Eye.use_tetio;
            
            Eye.freq = 300; % Hz
            
            % Open Daq
            if Eye.a_out
                Eye.Gain = GuiDaqGain;
            end
            
            Eye.Scr.init;
            
            tetio_init;
        end
        
        function open(Eye, tracker_ID)
            if exist('tracker_ID', 'var') && ~isempty(tracker_ID)
                Eye.tracker_ID = tracker_ID;
            end
            
            if Eye.use_tetio && isempty(Eye.tracker_ID)
                tracker_info = tetio_getTrackers();
                
                n_tracker = numel(tracker_info);
                
                if n_tracker > 0             
                    for ii = 1:n_tracker
                        fprintf('Tracker %d:\n', ii);
                        disp(tracker_info(ii));
                    end
                    
                    if n_tracker > 1
                        tracker_ix = input_def('Choose tracker: ', ...
                            'str', false, ...
                            'choices', 1:n_tracker);
                    else
                        tracker_ix = 1;
                    end
                    
                    Eye.tracker_ID = tracker_info(tracker_ix).ProductId;
                else
                    tetio_cleanUp;
                    error('No tracker found!');
                end                
            end
            
            try
                tetio_disconnectTracker;
            catch err
                warning(err_msg(err));
            end
            tetio_connectTracker(Eye.tracker_ID);
            
            Eye.frame_rate = tetio_getFrameRate;
            fprintf('TETIO frame rate: %d Hz\n', Eye.frame_rate);
            
            % SetCalibParams;
            if Eye.use_tetio
                disp('Starting TrackStatus');
                % Display the track status window showing the participant's eyes (to position the participant).
                % TrackStatus; % Track status window will stay open until user key press.
                % disp('TrackStatus stopped');
            end
        end
        
        function initLogTrial(Eye, varargin)
            tetio_startTracking;
        end
        
        function [c_xy_deg, t, trig_signal] = get(Eye)
            [L, R, t, trig_signal] = tetio_readGazeData; % (Eye.Calib_struct);
            
            tf = (L(:,13) <= 2) & (R(:,13) <= 2);
            
            if ~any(tf)
                c_xy_prop = [0 0]';
                t = GetSecs;
            else
                c_xy_prop = [(L(tf,7)  + R(tf,7) ) / 2, ...
                             (L(tf,8)  + R(tf,8) ) / 2];
                         
                c_xy_prop = c_xy_prop(end,:)';
                
                t = t(tf);
                t = t(end);
            end
            
            c_xy_deg  = Eye.Scr.prop2deg(c_xy_prop(:));
            
            % TODO: add addLog().
            
            Eye.xyDeg = c_xy_deg(:);
            Eye.xyPix = Eye.Scr.deg2pix(c_xy_deg(:));
            
            % Daq
            if Eye.a_out
                Eye.Gain.sample(c_xy_deg(:), t);
            end
        end
        
        function closeLog(Eye) % TODO
            tetio_stopTracking;
        end
        
        function close(Eye)
            try
                tetio_stopTracking;
            catch err_stop
                warning(err_msg(err_stop));
            end
            tetio_disconnectTracker;
        end
        
        % Tobii-specific
        function calib_begin(Eye)
            tetio_startCalib;
%             tetio_clearCalib;
        end
        
        function calib_end(Eye, compute_calib)     
            if ~exist('compute_calib', 'var'), compute_calib = true; end
            
            if compute_calib
                tetio_computeCalib;
            end
            tetio_stopCalib;
        end
    end
end