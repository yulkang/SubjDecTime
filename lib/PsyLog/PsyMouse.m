classdef PsyMouse < PsyInp
%        
% Properties inherited from PsyInp:
%
%         sampledAbsSec    = -inf; % last sampled time
%         freq             = [];   % in Hz
%         active           = false;
%         
%         lowFreq          = 0;
%         highFreq         = 60;
%         lowFreqAtAbsSec  = nan;
%         highFreqAtAbsSec = nan;
%         
%         maxSecAtHighFreq = 1;
%         maxSecAtLowFreq  = 7; 

    properties
        
        Scr = [];
        
        xyPixRaw
        xyPix
        xyDeg
        buttons
        
        touchOnly   = true;
        
        info        = struct('maxSec', []);
        
        % Perhaps put back into info?
        centerPix       = [];
        rect            = [];
        pixPerDeg       = [];
        maxNButtonLog   = 1;
        numMouseButtons = 3;
        win             = [];
        leftTop         = nan(2,1);
        
        mapMousePortion = [0 0 1 1]'; % [left top width height]
        mapWinPortion   = [0 0 1 1]'; % [left top width height]
        mapMousePix     = nan(4,1);  % [left top width height]
        mapWinPix       = nan(4,1);  % [left top width height]
        
        downMarks       = {};
        upMarks         = {};
    end
    
    
    properties (Dependent)
        maxNSampleEffective
    end
    
    
    methods
        %% Before experiment
        function me = PsyMouse(cScr, varargin)
            % Mouse = PsyMouse([Scr], ['optName1', opt1, ...]);
            
            %% PsyDeepCopy interface
            me = me@PsyInp;
            me.tag         = 'Mouse';
            
            if nargin > 0, me.Scr = cScr; end
            
            %% PTB interface
            [~,~,cButtons] = GetTablet;
            me.numMouseButtons = length(cButtons);
            
            %% Other defaults
            me.freq = 133;
            
            %% User's specification
            if nargin > 1
                init(me, varargin{:});
            end
            
            %% Log
            % Coordinates: Many samples are taken.
%             me.initLogEntries('mark', {'sampledAbsSec'}, ...
%                               'absSec', {}, me.maxNSample);
                          
            me.initLogEntries('prop2', ...
                             {'xyPixRaw', 'xyPix', 'xyDeg'}, ...
                              'absSec', single([0; 0]), me.maxNSample);
                    
            % Buttons: Assume only one sample
            %          for each of 'buttonUp1', 'buttonDown1', etc.
            me.downMarks    = csprintf('buttonDown%d',  1:me.numMouseButtons);
            me.upMarks      = csprintf('buttonUp%d',    1:me.numMouseButtons);
            
            me.initLogEntries('markLast', ...
                               [me.downMarks me.upMarks], ...
                              'absSec');
        end
        
        
        function init(me, varargin)            
            me.info     = varargin2fields(me.info, varargin);
            
            copyFields(me, me.info, {}, true);
        end
        
        
        function initLogTrial(me, maxSec)
            %% Default
            me.sampledAbsSec   = GetSecs;
            me.xyPixRaw = [nan; nan];
            me.xyPix    = [nan; nan];
            me.xyDeg    = [nan; nan];
            me.buttons  = zeros(1, me.numMouseButtons);
            
            %% Temporary variables.
            me.centerPix = me.Scr.info.centerPix(:);
            me.pixPerDeg = me.Scr.info.pixPerDeg;
            me.rect      = me.Scr.info.rect(:);
            me.win       = me.Scr.info.win;
            
            try
                globalRect   = Screen('GlobalRect', me.win);
                me.leftTop   = globalRect(1:2)';

                me.mapMousePix = me.mapMousePortion ...
                              .* repmat(vVec(me.Scr.info.rect(3:4)), [2 1]);
                me.mapWinPix   = me.mapWinPortion ...
                              .* repmat(vVec(me.Scr.info.rect(3:4)), [2 1]);
            catch lastE
                warning(lastE.message);
                warning('PsyScr:initLogTrial:winVariableNotInitialized', ...
                    'Window is not open, so some variables are not initializd.');
            end
            %% Log sizes.
            if exist('maxSec', 'var')
                me.info.maxSec = maxSec;
                
            elseif isempty(me.info.maxSec)
                me.info.maxSec = me.Scr.info.maxSec;
            end
            
            %% Init Log
            setFields(me, 'maxN_', {'xyPixRaw', 'xyPix', 'xyDeg'}, ...
                      ceil(me.maxNSampleEffective));
            
            initLogTrial@PsyLogs(me);
        end
        
        
        function res = get.maxNSampleEffective(me)
            res = me.maxSecAtHighFreq * min(me.deviceFreq, me.highFreq) ...
                + me.maxSecAtLowFreq  * min(me.deviceFreq, me.lowFreq);
        end
        
        
        %% During experiment
        function [cXYDeg cButtons] = get(me)
            % Much faster (0.2-0.3ms) than KbCheck (2-3ms).
            
            %% Get pix coordinates
            cXYPixRaw = zeros(2,1);
            [cXYPixRaw(1), cXYPixRaw(2), cButtons] = GetTablet;
            
            cXYPixRaw = cXYPixRaw - me.leftTop;
            cAbsSec = GetSecs;            
            
            %% If this is a duplicate sample,
            if all(cXYPixRaw == me.xyPixRaw) && all(cButtons == me.buttons) ...
                && cAbsSec < (me.t_.xyPixRaw(me.n_.xyPixRaw) + 1/me.deviceFreq)
                
                cXYDeg           = me.xyDeg;
                me.sampledAbsSec = cAbsSec;
                
%                 addLog(me, {'sampledAbsSec'}, cAbsSec);
                
                return; % Return without logging.
            end
            
            %% touchOnly
            if me.touchOnly && ~cButtons(1)
                % If no buttons are pressed, don't update
                cXYPix = me.xyPix;
            else
                % If a button is pressed, map using prespecified proportion
                cXYPix = (cXYPixRaw - me.mapMousePix(1:2)) ...
                      .*  me.mapWinPix(3:4) ./ me.mapMousePix(3:4) ...
                       +  me.mapWinPix(1:2);
            end
            
            %% xyDeg
            cXYDeg = (cXYPix - me.centerPix) / me.pixPerDeg;
            
            %% Buttons
            diffButton = int32(cButtons) - int32(me.buttons);
            
            %% Update last inputs
            me.xyPixRaw = cXYPixRaw;
            me.xyPix    = cXYPix;
            me.xyDeg    = cXYDeg;
            me.buttons  = cButtons;
            me.sampledAbsSec   = cAbsSec;
            
            %% Logging
            addLog(me, ...
                [{'xyPixRaw', 'xyPix'}, ... , 'sampledAbsSec'}, ...
                 me.downMarks(diffButton==1), me.upMarks(diffButton==-1)], ...
                 cAbsSec);
        end
        
        
        %% After experiment
        function closeLog(me)
            % closeLog(me): xyPix to xyDeg.
            
            xyPix2Deg(me);
        end
        
        
        %% Analysis
        function removeDuplicate(me)
            % removeDuplicate(me)
            
            dXY     = diff(me.v_.xyPix, 1, 2);
            dTSamp  = diff(me.t_.xyPix);
            
            % Duplicate if both x & y are identical and sampled close in time
            ix      = ~[false, ... % First sample is always not duplicate
                        hVec(sum(dXY == 0, 1) ...
                        & (dTSamp < 1/me.deviceFreq))];
            
            % Substitute back, maintaining original array size
            n           = nnz(ix);
            me.n_.xyPix = n;
                    
            me.v_.xyPix = [me.v_.xyPix(:,ix), nan(2, me.maxN_.xyPix - n)];
            me.t_.xyPix = [me.t_.xyPix(ix),   nan(1, me.maxN_.xyPix - n)];
            
            me.xyPix2Deg;
        end
        
        
        function cTS = ts(me, ixArg, smArg, varargin)
            % TS Return a timeseries containing xyDeg that is preprocessed.
            %
            % cTS = ts(me)
            % cTS = ts(me, {ixArgs})
            % cTS = ts(me, ..., {smoothArgs})
            % cTS = ts(me, ..., 'optName1', opt1, ...)
            %
            % ixArgs    : see PsyLogs.ParseIx
            % smoothArgs: see smooth
            % opt
            %
            % useDeviceFreq     : Resample using deviceFreq.
            % startFromZero     : Zero starting time.
            %
            % See also REMOVEDUPLICATE, INTERPDUPLICATE, PsyLogs.ParseIx
            
            if me.n_.xyDeg ~= me.n_.xyPix, xyPix2Deg(me); end
            if ~exist('ixArg', 'var'), ixArg = {}; end
            if ~exist('smArg', 'var')
                smArg = {round(0.15*me.deviceFreq/2)*2+1, 'loess'}; 
            end
            opt = varargin2fields( struct( ...
                'useDeviceFreq', true, ...
                'alignTo', nan)...
                , varargin);
            
            removeDuplicate(me);
            cTS = timeseries(me.vTrim('xyDeg', ixArg{:})', ...
                             me.relSec('xyDeg', ixArg{:}));
                         
            cTS = PsyMouse.interpDuplicate(cTS);
            
            if opt.useDeviceFreq
%                 cTS = alignTS(cTS, opt.alignTo, 1/me.deviceFreq);
                
                if isempty(opt.alignTo)
                    t = cTS.Time(1):(1/me.deviceFreq):cTS.Time(end);
                
                elseif opt.alignTo == -inf
                    cTS.Time = cTS.Time - cTS.Time(1);
                    t = 0:(1/me.deviceFreq):cTS.Time(end);
                
                else
                    stT = cTS.Time(1) - opt.alignTo;
                    enT = cTS.Time(end) - opt.alignTo;
                    
                    if (stT <= 0) && (enT >= 0)
                        t = [flipdim(0:(-1/me.deviceFreq):stT, 2), ...
                             (1/me.deviceFreq):(1/me.deviceFreq):enT];
                    else
                        error('Should align to time within the sampled interval!');
                    end
                    
                    cTS.Time = cTS.Time - opt.alignTo;
                end
                
                cTS = resample(cTS, t);
            end
            
            cTS = smoothTS(cTS, smArg{:});
%             mTS = mean(cTS.Data, 3);
%             cTS = idealfilter(cTS, [0 5], 'pass');
        end
        
        
        function xyPix2Deg(me)
            % xyPix2Deg(me)
            
            copyLogInfo(me, 'xyPix', 'xyDeg');
            
            me.v_.xyDeg = pix2deg(me.Scr, me.v_.xyPix);
        end
        
        
        function h = plotXY(me, v_args, plot_args)
            % Plot y against x.
            %
            % h = plotXY(me, v_args, plot_args)
            
            if nargin < 2, v_args = {}; end
            if nargin < 3, plot_args = {}; end
            
            cXyDeg = me.v('xyDeg', v_args{:});
            
            h = plot(cXyDeg(1,:), cXyDeg(2,:), plot_args{:});
            set(gca, 'YDir', 'reverse');
            
            xlim([-10 10]); ylim([-10 10]);
        end
        
        
        function plotTXY(me, varargin)
            % PLOTTXY - Plot x and y against relSec.
            %
            % plotTXY(me, 'opt1', opt1, ...)
            % 
            % Options:
            % t_align_to : A scalar relSec to subtract from t
            % xy_arg     : Cell array of arguments to feed t-xy plot
            
            S = varargin2S(varargin, {...
                't_align_to',   0, ...
                'xy_arg',       {}, ...
                'y_lim',        [-10 10], ...
                'legend',       {'X (deg)', 'Y (deg'}});
            
            plot(me.relSec('xyDeg') - S.t_align_to, me.vTrim('xyDeg'), S.xy_arg{:});
            
            ylim(S.y_lim);
            
            if ~isempty(S.legend)
                legend(S.legend);
                legend('Location', 'best');
            end
        end
        
        
        function [xy2, t2] = resample(me, varargin)
            % RESAMPLE  with even spacing
            %
            % [xy2, t2] = resample(me, varargin)
            
            S = varargin2S(varargin, {
                'freq', me.deviceFreq
                });
            
            xy = me.v('xyDeg');
            t  = me.relSec('xyDeg');
            
            [xy2, t2] = PsyMouse.resamp(xy, t, S.freq);
        end
        
        function [xy_sm_v, spd, xy_sm, t] = velocity(me, varargin)
            % VEL velocity from smoothed samples
            %
            % [xy_sm_v, spd, xy_sm, t] = velocity(me, varargin)
            
            S = varargin2S(varargin, {
                'filt', filt_gauss(round(0.05 * me.deviceFreq))
                });
            
            [xy, t] = me.resample;
            
            [xy_sm_v, spd, xy_sm, t] = PsyMouse.vel(xy, t, S.filt);
        end
    end
    
    
    methods (Static)
        function [xy2, t2] = resamp(xy, t, freq)
            % [xy2, t2] = resamp(xy, t, freq)
            
            t2  = t(1):(1/freq):t(end);
            xy2 = interp1(t, xy', t2)';
        end
        
        function [xy_sm_v, spd, xy_sm, t] = vel(xy, t, filt)
            % [xy_sm_v, spd, xy_sm, t] = vel(xy, t, filt)
            
            xy_sm   = conv2_pad(xy, filt);
            
            dt = diff(t);
            
            xy_sm_v = diff(xy_sm, 1, 2);
            spd     = sum(xy_sm_v .^ 2, 1) ./ dt;
            xy_sm_v = bsxfun(@rdivide, xy_sm_v, dt);
        end
        
        function ts = interpDuplicate(ts)
        % INTERPDUPLICATE  Interpolate duplicate samples within one directional movement.
            
            % Remember original time
            t    = ts.Time;
            
            % Sign of dXY
            sgn  = sign(diff(squeeze(ts.Data), 1, 2));
            
            % If a duplicate sample is surrounded by identical-signed velocities
            dup  = find(prod(double(sgn(:,2:(end-1)) == 0), 1) ...
                      & prod(double(sgn(:,1:(end-2)) == sgn(:,3:end)), 1));
            
            % Remove duplicate samples
            ts   = delsample(ts, 'Index', dup + 2);
            
            % Resample it using linear interpolation
            ts   = resample(ts, t);
        end
    end
end