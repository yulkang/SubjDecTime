classdef PsyEye < PsyMouse
    properties
        %% conf: sent via EyeLink commands on open().
        
        conf = struct(...
           ... % ask for a 13-point grid calibration, to cover the center better.
            'calibration_type',                 'HV9' ... 'HV9'   ...
           ....
           ... % enable automatic calibration
           ,'enable_automatic_calibration',     'YES'   ...
           ...
           ... % interval between automatic calibration (in ms)
           ,'automatic_calibration_pacing',     1000    ...
           ...
... %            ... % disable binocular tracking for speed % not sure if necessary, and causing errors frequently - YK
... %            ,'binocular_enabled',                'NO'    ...
           ...
           ... % no need to convert pupil area to diameter
           ,'pupil_size_diameter',              'NO'    ...
           ...
           ... % in mm
           ,'simulation_screen_distance',       500     ... 
           ...
           ... % Filter level of 0, 1, or 2. Delays by as many samples.
           ,'heuristic_filter',                 'OFF'    ...
           ...
           ... % ensure that velocity information for saccade detection is computed based
           ... % on gaze 
           ,'recording_parse_type',             'GAZE'  ...
           ...
           ... % % set saccade velocity threshold. Taken from Palmer&Shadlen Psychophysics lab
           ... % 'saccade_velocity_threshold = 35'
           ... % % set saccade acceleration threshold. Taken from Palmer&Shadlen Psychophysics lab
           ... % 'saccade_acceleration_threshold = 9500'
           ... % the two lines above are valid only for EyelinkI, they are obselete for EyelinkII.
           ... % It is recommended to use select_parser_configuration for EyelinkII
           ... %   0 means (good for cognitive setup and less sensitive to setup problems)
           ... %       recording_parse_type = GAZE
           ... %       saccade_velocity_threshold = 30         deg/sec
           ... %       saccade_acceleration_threshold = 9500   deg/sec^2
           ... %       saccade_motion_threshold = 0.15         deg
           ... %       saccade_pursuit_fixup = 60
           ... %       fixation_update_interval = 0
           ... %   1 means (high sensitivity, good for pursuit experiments, but may
           ... %   produce false saccades if subject setup is poor)
           ... %       recording_parse_type = GAZE
           ... %       saccade_velocity_threshold = 22         deg/sec
           ... %       saccade_acceleration_threshold = 5000   deg/sec^2
           ... %       saccade_motion_threshold = 0.0          deg
           ... %       saccade_pursuit_fixup = 60
           ... %       fixation_update_interval = 0
           ,'select_parser_configuration',      0       ...
           ...
           ... % set the gain for storage of values in the EDF file. the stored values
           ... % need to be integers and this multiplication allows decimal precision. But
           ... % the value should be small enough to ensure the larest coordinates will
           ... % still remain in the integer range (between -32000 and +32000)
           ,'screen_write_prescale',            10      ...
           ...
           ... % same for eye velocity data 
           ,'velocity_write_prescale',          10      ...
           ...
           ... % set type of events written to the EDF file       
           , 'file_event_filter', 'LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON' ...
           ...
           ... % set type of events transferred through the link
           , 'link_event_filter', 'LEFT,RIGHT,FIXATION,SACCADE,BLINK,BUTTON' ...
           ...
           ... % set data in samples transferred over the link to PTB 
           , 'file_sample_data', 'LEFT,RIGHT,GAZE,GAZERES,AREA' ...
           ...
           ... % set data in samples transferred over the link to PTB 
           , 'link_sample_data', 'LEFT,RIGHT,GAZE,GAZERES,AREA' ...
             );
         
        % Type of pupil fitting procedure is important but not controllable from
        % display computer. Convert .edf to .asc and check if 'ELCL_PROC' is
        % 'ELLIPSE' or not.
         
        %% Miscellaneous info
        % el: Keyboard mapping, etc.
        el
        
        % Others
        dummy     = 0;
        whichEyeVec = [0 1]; % [0 1] for R, [1 0] for L, [1 1] for both.
        verbose   = 1;
        
        %% Time
        % freqSamp decides the size of the preallocated space,
        % whereas freq (inherited) decides the frequencey that Scr calls get().
        freqSamp  = 1000; 
        
        % time difference (in sec) shifted to match GetSecs.
        % (EyeLink sample time) + samp2GetSecs = GetSecs.
        samp2GetSecs = nan;
        
        %% Raw samples
        samp  = nan(31,0);
        evt   = nan(30,0);
        pupil = nan;
        
        saveDat = struct('samp', false, 'evt', false, 'pupil', true);
        
        %% Raw mode - request and record raw position
        raw_mode = 'cornea'; % Read cornea | pupil | pupil - cornea
        raw_gain   = 1; % xyDeg = (raw_value - raw_offset) * raw_gain
        raw_offset = 0; % xyDeg = (raw_value - raw_offset) * raw_gain
        
        %% edf
        receive_edf = 1; % 0: Don't attempt 1: Attempt but catch failure 2: Issue error on failure
        
        %% Calibration
        calibDstDeg = [0 0]';
        calibPix  = [0 0]'; % xyPixRaw * calibGain + calibPix = xyPix.
        calibGain = [1 1]'; % xyPixRaw * calibGain + calibPix = xyPix.
        
        calibTarg   % PsyPTB objects
        calibCursor % PsyCursor object        
    end  
    
    properties (Dependent)
        whichEye  % 0:L, 1:R, 2:B, -1:N
        maxNSampEye
        maxNEvtEye
        
        calibDstPix
        calibDeg % xyDegRaw + calibDeg = xyDeg.
    end
        
    
	methods
        %% Before experiment
        function Eye = PsyEye(cScr, varargin)
            % Eye = PsyEye([Scr], ['optName1', opt1, ...]);
            
            %% PsyDeepCopy interface
            Eye = Eye@PsyMouse;
            Eye.tag = 'Eye';
            
            if nargin > 0, Eye.Scr = cScr; end
            
            %% Default values
            Eye.maxSecAtHighFreq = 6;
            Eye.maxSecAtLowFreq  = 0;
            
            %% Set fields if specified
            varargin2fields(Eye, varargin, true);
            
            %% PsyLogs interface
            % Time checking at the beginning and end of each trial.
            Eye.initLogEntries('prop2', {'samp2GetSecs'}, 'absSec', nan, 2);
            
            %% Additional data
            % xyPix, xyDeg, pupil, sampledAbsSec has absSec calculated from
            % the sample time.
            % 
            % Their maxN should be Eye.maxNSampEye.
            %
            % sampledAbsSec has GetSecs at the time the samples were retrieved
            % from the display computer as the contents.
            Eye.initLogEntries('val2', {'xyPix', 'pupil', 'sampledAbsSec'}, 'absSec', ...
                              {single([nan;nan]), single(nan), nan}, Eye.maxNSampEye);
                          
            % xyPixRaw is not logged separately for now, since calibration 
            % takes place only during calibEL('targ'), which has its own separate
            % trial.
            Eye.initLogEntries('prop2', {'xyPixRaw'}, 'absSec', ...
                              {single([nan;nan])}, 0);
            
            % Messages
            Eye.initLogEntries('valCell', {'msg'}, 'absSec', {blanks(20)}, 10);
                          
            % Samples and events
            % : Default value is based on Eyelink('GetQueuedData').
            if Eye.saveDat.samp
                Eye.initLogEntries('val2', {'samp'}, 'absSec', ...
                              {single(nan(31,1))}, Eye.maxNSampEye);
            end
            if Eye.saveDat.evt
                Eye.initLogEntries('val2', {'evt'}, 'absSec', ...
                              {single(nan(30,1))}, Eye.maxNSampEye);
            end
            
            %% Defaults that differ from PsyMouse
            Eye.freq = 120; % Transfer signal from EyeLink only so often.
        end
        
        
        function initConf(Eye, varargin)
            Eye.conf = varargin2fields(Eye.conf, varargin);
        end
        
        
        function sCalib = initCalib(Eye, bkgCol, targCol, targRDeg, widthDeg)
            % sCalib = initCalib(Eye, bkgCol, targCol, targRDeg, widthDeg)
            
            if nargin > 1
                Eye.el.backgroundcolour  = bkgCol;
                Eye.el.foregroundcolour  = targCol;
                Eye.el.calibrationtargetcolour  = targCol;
                Eye.el.msgfontcolour     = targCol;
                Eye.el.imgtitlecolour    = targCol;

                targSizePercent = targRDeg * 2 ...
                                * Eye.Scr.info.pixPerDeg / Eye.Scr.info.rect(3) * 100;
                widthPercent    = widthDeg * 2 ...
                                * Eye.Scr.info.pixPerDeg / Eye.Scr.info.rect(3) * 100;

                Eye.el.calibrationtargetsize  = targSizePercent;
                Eye.el.calibrationtargetwidth = widthPercent;
                
                PsychEyelinkDispatchCallback(Eye.el);
            else
                sCalib.bkgCol  = Eye.el.backgroundcolour;
                sCalib.targCol = Eye.el.foregroundcolour;
                
                sCalib.targRDeg = Eye.el.calibrationtargetsize / 2 ...
                                / 100 * Eye.Scr.info.rect(3) / Eye.pixPerDeg;
                sCalib.widthDeg = Eye.el.calibrationtargetwidth / 2 ...
                                / 100 * Eye.Scr.info.rect(3) / Eye.pixPerDeg;
            end
        end
        
        
        function res = initEL(Eye)
            % initEL(Eye)  Connect to Eyelink & initialize it.
           
            %% Initialize TCP/IP connection with EyeLink
            % -1: dummy, 1: real connection, 0: none
            if Eyelink('IsConnected') ~= 0
                Eyelink('Shutdown');
                fprintf('Shut down existing connection to EyeLink!\n\n');
            end
            res     = EyelinkInit(Eye.dummy);
            if res == 1
                fprintf('EyeLink initialized successfully.\n\n');
            else
                error('PsyEye:ConnectionFailed', 'Cannot initialize EyeLink!');
            end
            
            %% Set up keycode structure
            Eye.el = EyelinkInitDefaults(Eye.Scr.info.win);
            
            % EyelinkInitDefaults() calls KbName('UnifyKeyNames'),
            % but PsyLogs needs alphanumeric KbNames. Fortunately, the names that
            % Eyelink() uses are fully compatible with alphanumeric KbNames.
            fprintf('Will use alphanumeric key names regardless of the platform.\n');
            psyKbName('UnifyToAlphaNumeric');
            
            %% Configuration
            Eye.initConf(...
                'simulation_screen_distance', Eye.Scr.info.distCm*10);
            
            Eye.sendConf;
            
            %% Send screen coordinates to eyelink  
            Eyelink('Message', ['DISPLAY_COORDS =', ...
                sprintf(' %d', Eye.Scr.info.rect)]);
            
            %% Open edf file and start recording.
            err = Eyelink('OpenFile', 'EyeData.edf');
            if err == 0
                fprintf('Opened EyeData.edf in EyeLink.\n\n');
            else
                error('PsyEye:OpeningEDFFailed', ...
                      'EyeLink failed to open EyeData.edf');
            end
            
            Eye.startRecordingEL;
            Eye.receiveELFile;
        end
        
        
        function calibEL(Eye, meth, varargin)
            % calibEL(Eye, meth, [opt])
            %
            % meth: 'orig' or 'targ'
            %
            % When meth=='targ':
            %   Targets are drawn as a FrameOval, the cursor as a FillOval.
            %
            % opt: Currently only works with 'targ'.
            %
            %   xyDeg    : 2 x N matrix of target locations. Defaults to [0 0]'.
            %   col      : 3 x 1 vector of target color. Defaults to [125 125 125]'.
            %   rDeg     : 1 x 1 vector of target radius in deg. Defaults to 0.3.
            %   penWidthDeg : Thickness of the frame. Defaults to 0.2.
            %   key      : Keycode to confirm fixation. Defaults to space.
            %   showCursor : Defaults to true.
            %   curRDeg  : Radius in deg. Defaults to 0.1.
            %   curCol   : Cursor color. Defaults to [255 0 0]'.
            %
            % When meth=='orig':
            %   While in the calibration mode you can use the following keys: 
            %
            %   c   start calibration
            %   v   start verification
            %   d   start drift correction
            
            % By default, use the original calibration from SR research.
            if ~exist('meth', 'var'), meth = 'orig'; end 
            
            switch meth
                case 'orig'
                    % Do calibration
                    err = EyelinkDoTrackerSetup(Eye.el, []);
                    if err == 0
                        fprintf('Calibration done using EyeLinkDoTrackerSetup.\n\n');
                    else
                        error('PsyEye:CalibrationFailed', 'Failed to calibrate EyeLink!');
                    end;

%                     % Check the calibration using drift correction 
%                     % Not recommended from EyeLink 1000 (EyeLink
%                     % Programmer's Guide)
%                     EyelinkDoDriftCorrection(Eye.el);   

                    % edf file contains useful information about
                    % calibration that is not available otherwise.
                    % So receive it right after the calibration.
                    Eye.receiveELFile;

                case 'targ'
                    % Shows a target at the center.
                    % Press Space when the subject fixates.
                    % Then after 2 frame's sample collection, 
                    % the cursor jumps to the corrected position.
                    % If the correction is satisfactory, wait until the 
                    % next target appears or the calibration ends.
                    % If not, press Space again to recorrect the position.
                    %
                    % TODO: Multiple targets, linear interpolation, 
                    % if necessary after HV13 calibration by EyeLink.
                    % Maybe recalibrate using HV13 if necessary, rather than
                    % rewriting the whole routine.
                    
                    % Set up opt
                    opt = struct(...
                        'xyDeg', Eye.calibDstDeg, ...
                        'col',   [125 125 125]', ...
                        'rDeg',  0.3, ...
                        'penWidthDeg', 0.2, ...
                        'key',   'space', ...
                        'showCursor', true, ...
                        'curRDeg', 0.1, ...
                        'curCol',  [255 0 0]', ...
                        'tInitCalib', 10, ...
                        'tNextCalib', 2);
                    opt = varargin2fields(opt, varargin);
                    
                    opt.nTarg   = size(opt.xyDeg, 2);
                    opt.targOrd = randperm(opt.nTarg);
                    
                    if opt.nTarg > 1, 
                        error('PsyEye:calibEL:SingleTargOnly', ...
                            'Multiple calibration targets are not supported yet!');
                    end
                    
                    % Set up Targ
                    for iTarg = opt.nTarg
                        Eye.calibTarg{iTarg} = PsyPTB(Eye.Scr, ...
                            'FrameCircle', opt.col, opt.xyDeg(:,iTarg), opt.rDeg, ...
                            'penWidthDeg', opt.penWidthDeg);
                        
                        Eye.calibTarg{iTarg}.tag = sprintf('calibTarg%d', iTarg);
                        Eye.Scr.addObj('Vis', Eye.calibTarg{iTarg});
                    end
                    
                    % Set up Cursor
                    Eye.calibCursor = PsyCursor(Eye.Scr, opt.curCol, opt.curRDeg, 'Eye');
                    Eye.calibCursor.tag = 'calibCursor';
                    Eye.Scr.addObj('Vis', Eye.calibCursor);
                    
                    % Run the calibration trial
                    Eye.Scr.initSaveOpt;
                    Eye.Scr.initLogTrial;
                    
                    for iTarg = opt.targOrd
                        Eye.Scr.hide('all');
                        Eye.calibTarg{iTarg}.show;
                        Eye.calibCursor.show;
                        
                        % Wait until the user says fixated.
                        cT = GetSecs;
                        cCalibName = sprintf('calib%d', iTarg);
                        Eye.Scr.wait(cCalibName, ...
                            @() Eye.Scr.c.Key.logged(opt.key) ...
                             && Eye.Scr.c.Key.lastT(opt.key) > cT + 0.1, ...
                             'for', opt.tInitCalib, 'sec');
                        
                        confirmed = false;
                        iConfirm  = 0;
                        
                        while ~confirmed
                            iConfirm = iConfirm + 1;
                            cCalibName = sprintf('calib%d_confirm%d', iTarg, iConfirm);
                            
                            % Center based on multiple samples.
                            Eye.Scr.wait([cCalibName '_samp'], @() false, ...
                            'for', 0.025, 'sec');
                        
                            Eye.calibPix(:,iTarg) = Eye.calibPix(:,iTarg) + ...
                                mean(Eye.v('xyPix', ...
                                        'GE', Eye.Scr.tVerdict([cCalibName '_samp_on']), ...
                                            'absSec') ...
                                   , 2) ...
                                - Eye.calibTarg{iTarg}.xyPix;

                            % See if the user requests further centering.
                            % Note that usually just one centering is
                            % enough.
                            cT = GetSecs;
                            
                            Eye.Scr.wait(cCalibName, ...
                                @() Eye.Scr.c.Key.logged(opt.key) ...
                                 && Eye.Scr.c.Key.lastT(opt.key) > cT+0.1, ...
                                 'for', opt.tNextCalib, 'sec');
                            
                            % If the user doesn't press anything,
                            % the centering is confirmed.
                            confirmed = Eye.Scr.wasVerdict([cCalibName '_pass']);
                        end
                                         
                        Eye.Scr.hide('all');
                    end
                    
                    Eye.Scr.closeLog;
                    
                    % Save the calibration trial
                    cFile = Eye.Scr.trialFile('orig', '_centerEye.mat');
                    fprintf('Saved workspace to %s\n\n', cFile);
                    save(cFile);
            end
            % After calibration, clear the screen.
            Screen('FillRect', Eye.Scr.info.win, Eye.Scr.info.bkgColor);
        end
        
        
        function initLogTrial(Eye, varargin)
            initLogTrial@PsyMouse(Eye, varargin{:});
            
            % Start recording if not already doing
            Eye.startRecordingEL;
            
            % Send msg
            [~, file] = fileparts(Eye.Scr.trialFile('orig'));
            Eye.sendMsg('TrBegin_%s', file);
        end
        
        
        %% After experiment
        function closeLog(Eye)
            % Send msg
            [~, file] = fileparts(Eye.Scr.trialFile('orig'));
            Eye.sendMsg('TrFinish_%s', file);
            
            % Check and record time offset. Takes 0.01 sec.
            Eye.checkTimeOffset;
            
            % Set toLog=false
            Eye.closeLog@PsyMouse;
        end
        
        
        function closeEL(Eye)
            % Receive file
            Eyelink('StopRecording');
            Eyelink('CloseFile');
            
            Eye.receiveELFile;
            
            % Close EyeLink
            try
                Eyelink('SetOfflineMode');
            catch
            end
            
            if Eyelink('IsConnected') ~= 0
                Eyelink('ShutDown');
            end
        end
        
        
        %% During experiment
        function get(Eye) % cXYDeg = get(Eye)           
            %% Debug
%             iLoop    = 0;
            
            %% Drain
            % sampledAbsSec: Contents (v_) are retrieval GetSecs,
            %                timestamps (t_) are the tracker time.
            samp_all   = [];
            sampledAbsSec = [];
            
            cSamp = nan;
%             drained = false;
            
            while ~isempty(cSamp) % ~drained
                %% Get all queued data.
                cSamp = Eyelink('GetQueuedData');
%                 [cSamp, ~, drained] = Eyelink('GetQueuedData');
                
                samp_all = [samp_all, cSamp];
                sampledAbsSec  = [sampledAbsSec, GetSecs + zeros(1, size(cSamp, 2))];
                
%                 iLoop = iLoop + 1;
            end
            
            %% Sample
            nSamp = size(sampledAbsSec, 2);
            
            if nSamp > 0 % c_len > 0 % ~isempty(cSamp)

                centerPix = Eye.centerPix;
                calibPix  = Eye.calibPix;
                calibGain = Eye.calibGain;
                whichEye  = Eye.whichEyeVec(2); % Record from right if available.
                save_samp = Eye.saveDat.samp;            
                samp2GetSecs = Eye.samp2GetSecs;

                % Log all xyPix and pupil if multiple samples are retrieved.
                % See also: Eyelink GetQueuedData?  PsyEye.calibEL.
                xyPix = samp_all([14, 16] + whichEye, :);

                % Offset should center the gaze. Gain should change the
                % eccentricity.
                xyPix(1,:) = (xyPix(1,:) - centerPix(1) + calibPix(1)) * calibGain(1) + centerPix(1);
                xyPix(2,:) = (xyPix(2,:) - centerPix(2) + calibPix(2)) * calibGain(2) + centerPix(2);

                pupil = samp_all(12 + whichEye,:);

                % Log with EyeLink time, shifted to match GetSecs.
                addLog(Eye, {'xyPix', 'pupil', 'sampledAbsSec'}, ...
                       samp_all(1,:)./1000 + samp2GetSecs, {xyPix, pupil, sampledAbsSec});

                %% Keep only the last sample.
                xyPix = xyPix(:,end);
                Eye.xyPix = xyPix;
                Eye.pupil = pupil(:,end);
                Eye.sampledAbsSec = sampledAbsSec(end);

                % Convert only the last sample. 
                % closeLog() will convert the whole xyPix afterwards.
                Eye.xyDeg = (xyPix - centerPix) ./ Eye.pixPerDeg;

                % Log the whole samp only if asked to.
                if save_samp
                    Eye.samp   = samp_all;

                    % Already has the tracker time in the first row
                    % so just use sampledAbsSec.
                    addLog(Eye, {'samp'}, sampledAbsSec, {samp_all});
                end                    
            end
                
            %% Debug
%             if iLoop > 1
%                 fprintf('Eye.get: %d loops!\n', iLoop);
%             end
        end
        
        
        %% Analysis
        function plotTXY(Eye, varargin)
            % Plot x, y, and pupil against relSec.
            %
            % [h hLeg] = plotTXY(Eye, 'opt1', opt1, ...)
            % 
            % Options:
            % t_align_to : A scalar relSec to subtract from t
            % xy_arg     : Cell array of arguments to feed t-xy plot
            % pupil_arg  : Cell array of arguments to feed t-pupil plot
            % pupil_divide_by : A scalar to divide the pupil reading.
            %                   Set [] to scale the max to ylim(2).
            
            S = varargin2S(varargin, {...
                't_align_to',   0, ...
                'xy_arg',       {}, ...
                'y_lim',        [-10 10], ...
                'pupil_arg',    {'r-'}, ...
                'pupil_divide_by', 600, ...
                'legend',       {'X (deg)', 'Y (deg)', 'pupil (a.u.)'}});
            C = S2C(S);
            
            Eye.plotTXY@PsyMouse(C{:});
            
            if Eye.saveDat.pupil
                pup = Eye.vTrim('pupil');
                
                if isempty(S.pupil_divide_by)
                    pup = pup ./ max(pup) .* ylim(2);
                else
                    pup = pup ./ S.pupil_divide_by;
                end

                hold on;
                plot(Eye.relSec('pupil') - S.t_align_to, pup, S.pupil_arg{:});
                
                ylim(S.y_lim);
            
                if ~isempty(S.legend)
                    legend(S.legend);
                    legend('Location', 'best');
                end
                hold off;
            end
        end
        
        
        function plotTSamp(Eye)
            subplotRC(2,3,1,2);
            tSamp = [0 diff(Eye.v('sampledAbsSec'))];
            tELSamp = Eye.relSec('sampledAbsSec');
            toPlot = tSamp~=0;
            plot(tELSamp(toPlot), tSamp(toPlot), 'r.-');
            hold on;
            dSampT = Eye.v('sampledAbsSec')-Eye.t('sampledAbsSec');
            plot(Eye.relSec('sampledAbsSec'), dSampT, 'b.-')
            plot(Eye.Scr.relSec('frOn'), [0, diff(Eye.Scr.relSec('frOn'))], 'g.-')
            ylim([0 0.05]);
            hold off;
            xlabel('DsampledAbsSec');
            legend({'tELSamp vs tSamp', 'relSec tsampled vs dSampT', 'frOn relS vs diff frOn relS'});
            
            subplotRC(2,3,2,2);
            plot(tELSamp(toPlot), tSamp(toPlot), 'r.-');
            hold on;
            plot(Eye.relSec('sampledAbsSec'), dSampT, 'b.-');
            plot(Eye.Scr.relSec('frOn'), [0, diff(Eye.Scr.relSec('frOn'))], 'g.-')
            ylim([0 0.05]); xlim([0 0.1]);
            xlabel('t sampled (relSec)');
            ylabel('D t sampled');
            hold off;

            subplotRC(2,3,1,1);
            dSamp = diff(Eye.v('sampledAbsSec')*1e3);
            hist(dSamp(dSamp>0));
            xlabel('interSample interval (ms, GetSecs)');
            
            subplotRC(2,3,2,1);
            hist(diff(Eye.Scr.t_.frOn)*1e3);
            xlabel('interFrame interval (ms)');
            
            subplotRC(2,3,1,3);
            hist(diff(Eye.relSec('sampledAbsSec'))*1e3);
            xlabel('interSample interval (ms, EyeLink)');
            
            subplotRC(2,3,2,3);
            hist(dSampT(Eye.relSec('sampledAbsSec')>0)*1e3);
            xlabel('Sample latency (ms, GetSecs-EyeLink)');
            
            %%
            fprintf('minimum latency in sampling: %1.4f sec\n', min(dSampT));
            fprintf('maximum sampling interval  : %1.4f sec\n\n', max(dSamp(dSamp>0)));
        end
        
        function [tf relS] = anyBlink(Eye, varargin)
            % [tf relS] = anyBlink(Eye, varargin)
            %
            % See also: PsyLogs.ParseIx
            
            ix      = find(Eye.vTrim('pupil', varargin) == 0);
            
            tf      = ~isempty(ix);
            relS    = Eye.relSec('pupil', ix);
        end
        
        function varargout = velocity(Eye, varargin)
            % See also PsyMouse.vel
            %
            % OPTIONS:
            % 'filt', filt_gauss(round(0.005 * Eye.deviceFreq))
            
            C = varargin2C(varargin, {
                'filt', filt_gauss(round(0.005 * Eye.deviceFreq))
                });
            
            [varargout{1:nargout}] = velocity@PsyMouse(Eye, C{:});
        end
        
        %% Subfunctions
        function err = startRecordingEL(Eye)
            % startRecordingEL Start recording if not recording already.
            
            if Eyelink('CheckRecording')
                err = Eyelink('StartRecording');
                
                if err == 0
                    fprintf('EyeLink started recording successfully.\n\n');
                else
                    error('PsyEye:StartRecordingFailed', ...
                      'EyeLink failed to start recording!');
                end
            end
        end
        
        
        function err = receiveELFile(Eye)
            if ~Eye.receive_edf
                fprintf('Not receiving edf file.\n');
                return;
            end
            
            err = Eyelink('ReceiveFile', 'EyeData.edf', ...
                          Eye.Scr.runFile('orig', '.edf'));
                                     
            if err <= 0,
                if Eye.receive_edf == 2
                    error('PsyEye:ReceiveFileFailed', ...
                          'Failed to receive .edf file!');
                else
                    warning('PsyEye:ReceiveFileFailed', ...
                          'Failed to receive .edf file!');
                end
            else
                fprintf('Received EyeData.edf (%d bytes) and saved to %s.\n\n', ...
                    err, Eye.Scr.runFile('orig', '.edf'));
            end
        end
        
        
        function err = sendMsg(Eye, fmt, varargin)
            msg = sprintf(fmt, varargin{:});
            
            err = Eyelink('Message', msg);
            addLog(Eye, {'msg'}, GetSecs, {msg});
        end
        
        
        function comm = sendConf(Eye, sendComm, varargin)
            % sendConf  Configure EyeLink according to Eye.conf
            %
            % comm = sendConf(Eye, [sendComm = true], ['varName1', 'varName2', ...])
            
            %% Initialize
            
            % Do actual configuration by default
            if ~exist('sendComm', 'var'), sendComm = true; end
            
            % Convert struct Eye.conf to cell arrays
            f = fieldnames(Eye.conf);
            c = struct2cell(Eye.conf);
            
            % Include only specified variables, if any.
            if ~isempty(varargin)
                toIncl = strcmpfinds(varargin, f);
                f = f(toIncl);
                c = c(toIncl);
            end
            
            % Initialize miscellaneous variables
            nConf = length(f);
            comm = cell(1,nConf);
            
            %% Formatted strings
            for iComm = 1:nConf
                if ischar(c{iComm})
                    fmt = ' %s';
                    
                elseif isnumeric(c{iComm})
                    if all(c{iComm} == floor(c{iComm}))
                        fmt = ' %g';
                    else
                        fmt = ' %f';
                    end
                else
                    error('PsyEye:sendConf:UnknownConfigFormat', ...
                        'Unknown config value format!');
                end
                
                comm{iComm} = sprintf('%s =%s', f{iComm}, sprintf(fmt, c{iComm}));
            end
            
            %% Send command
            if sendComm
                for cComm = comm
                    fprintf('Sending Command: %s', cComm{1});
                    err = Eyelink('Command', cComm{1});
                    
                    if err~=0
                        error('PsyEye:sendConf:SetupFailure', ...
                                'Failed to execute command: %s', cComm{1});
                    else
                        fprintf('  ...Succeeded.\n');
                    end
                    
                    % Wait a little bit to ensure communication.
                    WaitSecs(0.1);
                end
                fprintf('All commands sent successully!\n\n');
            end
        end
        
        
        function checkTimeOffset(Eye)
            % CHECKTIMEOFFSET  Dual checks for time offset. 
            %
            % Record sample time only. Only that makes coherent sense.
            % In doing so, also drain remaining samples.
            % Call only during initLogTrial and closeLog, 
            % so that samples of interest are not thrown off.
            
            % TrackerTime and sample time seems to differ. Use sample time.
            % Copy the newest sample and compare its time with GetSecs.
            cSamp = -1;
            while isequal(cSamp, -1)
                % Eyelink help says NewestFloatSample copies rather than dequeues.
                % (unlike GetQueuedData).
                % May prevent losing data.
                cSamp = Eyelink('NewestFloatSample');

                % Wait just a little so that new sample can be detected fast.
                if isequal(cSamp, -1), WaitSecs(0.0001); end
            end

            cAbsSec = GetSecs;
            Eye.samp2GetSecs = cAbsSec - cSamp.time/1000; % msec -> sec
            
            addLog(Eye, {'samp2GetSecs'}, cAbsSec);
            
            % Discrepancy between sample time and GetSecs may depend on 
            % how soon we retrieved the sample, but we made our best above.
            % Should have submillisecond precision.
            if Eye.n_.samp2GetSecs > 1
                sampDrift = -diff(Eye.v('samp2GetSecs'))*1e3;
                sampTSamp = diff(Eye.t('samp2GetSecs'));
                
                fprintf('Drift in sample time / display time (+ means Eyelink time is faster):\n');
                fprintf(' %+1.3f (ms) = %+1.3f (ms) / %1.3f (s)\n\n', ...
                    sampDrift./sampTSamp, sampDrift, sampTSamp);
            end
        end
        
        
        %% Dependent properties
        function v = get.whichEye(Eye)
            switch nnz(Eye.whichEyeVec)
                case 0
                    v = -1;
                case 1
                    v = Eye.whichEyeVec(2); % 0 if L, 1 if R
                case 2
                    v = 2;
            end
        end
        
        function set.whichEye(Eye, v)
            switch v
                case -1
                    Eye.whichEyeVec = [0 0];
                case 0
                    Eye.whichEyeVec = [1 0];
                case 1
                    Eye.whichEyeVec = [0 1];
                case 2
                    Eye.whichEyeVec = [1 1];
            end
        end
        
        function v = get.maxNSampEye(Eye)
            v = (Eye.maxSecAtHighFreq + Eye.maxSecAtLowFreq) * Eye.freqSamp;
        end
        
        function v = get.maxNEvtEye(Eye)
            v = (Eye.maxSecAtHighFreq + Eye.maxSecAtLowFreq) * 10;
        end
        
        function v = get.calibDstPix(Eye)
            v = Eye.Scr.deg2pix(Eye.calibDstDeg);
        end
        
        function v = get.calibDeg(Eye)
            v = Eye.calibPix ./ Eye.Scr.info.pixPerDeg;
        end
    end
    
    
    methods (Static)
        [ts, xys, pupils] = plot_Eyes(files, varargin)
    end
end