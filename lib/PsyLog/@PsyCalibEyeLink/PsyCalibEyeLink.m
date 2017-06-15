classdef PsyCalibEyeLink < handle
    properties
        % PsyLog objects
        Scr_subj
        Scr_ctrl
        
        FP     % Shown on both sides
        Targ   % Shown on both sides
        Cursor % Shown on the control side only
        
        Key
        Eye
        Mouse
        Reward
        
        % Scr options
        scr_subj_opt = {
            'scr',          1, ...
            'refreshRate',  60, ...
            'skipSyncTests',true, ...
            };        
%         scr_ctrl_opt = {
%             'scr',          0, ...
%             'refreshRate',  60, ...
%             'skipSyncTests',true, ...
%             };

        % Object options
        targ_opt         = {'FillOval', [255 255 255; 0 0 255]', [0 0; 0 0]', [2, 2; 0.15 0.15]'};
        cursor_opt       = {[255 0 255]', 0.2};
        fix_range_opt    = {'FrameRect', [0 255 0]', [0 0]', [5 5]'};
        calib_marker_opt = {[0.3 0.3]', 'penWidthDeg', 0.1};
        calib_line_opt   = {0.1, [200 200 200]', [0 0]', false};
        eye_opt          = {};
        mouse_opt        = {'touchOnly', false};
        
        % Calibration options
        inp_mode = 'Eye';
        
        % Control display options
        ctrl_disp_kind = 'UI'; % 'UI', 'WTL' (waterloo), or 'PTB'
        
        % VarList
        List
    end
    
    methods
        function me = PsyCalibEyeLink(varargin)
        end
        
        function prepare_ctrl(me)
            
        end
        
        function draw_ctrl(me)
            % Draw opportunistically, only when time is left until flip
            
            switch me.ctrl_disp_kind
                case 'UI'
                    
            end
        end
        
        run(me)
    end
    
    methods (Static)
        me = test(varargin);
    end
end