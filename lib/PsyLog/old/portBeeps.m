function varargout = portBeeps(mode, varargin)

% A convenient wrapper for PsychPortAudio.
% Prepares and delivers beeps with prespecified timing with short latency.
%
%
        % paHandle = portBeeps('init'[, deviceid][, mode][, reqlatencyclass][, freq][, channels], ...)
        %
        % Opens and initializes the port. See PsychPortAudio Open? for details.
        % Beeps are specified by portBeeps('sets'). 
%
%
        % portBeeps('sets', 'setName1', nBeep, freqs, durs, delays, 'setName2', ...)
        %
        % nBeep  : a scalar.
        % freqs  : a scalar or a vector of nBeep frequencies.
        % durs   : a scalar or a vector of nBeep durations in seconds.
        % delays : a scalar or a vector of nBeep-1 delays between beeps in seconds.        
%
%
        % varargout = portBeeps('ready', 'setName', ...);
        %
        % 'setName' : One set's name, as specified by portBeeps('sets', 'setName' ...).
        % ...       : Additional argument for PsychPortAudio('FillBuffer'), 
        %             like streamingrefill, and startIndex.
        % varargout : Outputs from PsychPortAudio('FillBuffer')
        %
        % portBeeps('play') will automatically perform this step if necessary, 
        % but doing this beforehand will potentially shorten latency.
%
%
        % startTime = portBeeps('play', 'setName', ...);
        %
        % 'setName' : One set's name, as specified by portBeeps('sets', 'setName' ...).
        % ...       : Additional argument for PsychPortAudio('Start'), 
        %             like repetitions, when, etc.
        % startTime : Estimated onset latency, when waitForStart = 1.
        %             When waitForStart=0, always 0.
%
%
        % portBeeps('close');
        %
        % Close the port.
%
%
% Jul 2012, Hyoung Ryul Kang.

persistent pa sampRate nChn sets setReady

switch mode
    case 'init'
        % paHandle = portBeeps('init'[, deviceid][, mode][, reqlatencyclass][, freq][, channels], ...)
        %
        % Opens and initializes the port. See PsychPortAudio Open? for details.
        % Beeps are specified by portBeeps('sets'). 
        
        nVarargin   = length(varargin);
        argins      = varargin;
        
        if length(varargin) < 3
            argins((nVarargin+1):5) = cell(1, 5-nVarargin);
        end
        
        if length(varargin) >= 4
            sampRate = varargin{4};
        else
            sampRate = 44100;
            argins{4}= 44100;
        end
        
        if length(varargin) >= 5
            nChn     = varargin{5};
        else
            nChn     = 2;
            argins{5}= 2;
        end
        
        InitializePsychSound;
        
        pa           = PsychPortAudio('Open', argins{:});
        varargout{1} = pa;
        
        sets         = [];
        setReady     = '';
        
        
    case 'sets'
        % portBeeps('sets', 'setName1', nBeep, freqs, durs, delays, 'setName2', ...)
        %
        % nBeep  : a scalar.
        % freqs  : a scalar or a vector of nBeep frequencies.
        % durs   : a scalar or a vector of nBeep durations in seconds.
        % delays : a scalar or a vector of nBeep delays before each beeps in seconds.
        
        nVarargin = length(varargin);
        if mod(nVarargin, 5) ~= 0
            error('Number of arguments should be a multiple of 5 + 1!');
        end
        
        sets         = [];
        setReady     = '';
        
        for iSet = 1:5:nVarargin
            setName = varargin{iSet};
            
            nBeep   = varargin{iSet+1};
            
            if isempty(nBeep)
                nBeep   = max(cellfun('length', varargin(iSet+(2:4))));
            end
            
            try
                freqs   = varargin{iSet+2} + zeros(1,nBeep);
                durs    = varargin{iSet+3} + zeros(1,nBeep);
                delays  = varargin{iSet+4} + zeros(1,nBeep);
            catch
                error(['Length of freqs, durs, and delays should be either ' ...
                       'nBeep, nBeep, nBeep-1, respectively, or 1 !']);
            end
            
            sets.(setName).freqs  = freqs;
            sets.(setName).durs   = durs;
            sets.(setName).delays = delays;
            
            data    = [];
            
            for iBeep   = nBeep:-1:1
                beepSt  = round((sum(durs(1:(iBeep-1))) + sum(delays(1:iBeep))) ...
                               * sampRate) + 1;
                
                cBeep   = MakeBeep(freqs(iBeep), durs(iBeep), sampRate) * 0.5;
                lenBeep = size(cBeep, 2);
                
                data(:,beepSt:(beepSt+lenBeep-1)) = repmat(cBeep, [nChn 1]);
            end            
            
            sets.(setName).data = data;
        end
        
               
    case 'ready'
        % varargout = portBeeps('ready', 'setName', ...);
        %
        % 'setName' : One set's name, as specified by portBeeps('sets', 'setName' ...).
        % ...       : Additional argument for PsychPortAudio('FillBuffer'), 
        %             like streamingrefill, and startIndex.
        % varargout : Outputs from PsychPortAudio('FillBuffer')
        %
        % portBeeps('play') will automatically perform this step if necessary, 
        % but doing this beforehand will potentially shorten latency.
        
        varargout{:} = PsychPortAudio('FillBuffer', pa, sets.(varargin{1}).data, ...
                                                 varargin{2:end});
        
        setReady = varargin{1};
                                             
        
    case 'play'
        % startTime = portBeeps('play', 'setName', ...);
        %
        % 'setName' : One set's name, as specified by portBeeps('sets', 'setName' ...).
        % ...       : Additional argument for PsychPortAudio('Start'), 
        %             like repetitions (=1), when (=0), waitForStart (=0), etc.
        % startTime : Estimated onset. When an output is requested,
        %             waitForStart is forced to be 1.
        
        if ~strcmp(setReady, varargin{1})
            portBeeps('ready', varargin{1});
        end
        
        args = {1, 0, 0};
        args(1:(nargin-2)) = varargin(2:end);
        
%         if nargout > 0, args{3} = 1; end % waitForStart forced to 1.
        
        varargout{1} = PsychPortAudio('Start', pa, args{:});
        
        
    case 'stop'
        % varargout = portBeeps('stop', ...);
        %
        % Stop ongoing sound playback, if any.
        
        varargout{:} = PsychPortAudio('Stop', pa, varargin{:});
        
        
    case 'close'
        % portBeeps('close');
        %
        % Close the port.
        
        PsychPortAudio('Close', pa);
end
end