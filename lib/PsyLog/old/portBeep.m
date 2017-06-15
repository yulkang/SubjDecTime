function [startTime oPaHandle oMode oLatencyClass oSampRate oChn] = ...
         portBeep(freq, varargin)

% Initialization mode:
%
%   [~, paHandle, mode, latencyClass, sampRate, chn] = 
%       portBeep([], [mode=1, latencyClass=2, sampRate=44100, chn=1, paHandle]);
%
%
% Playback mode:
%
%   startTime = portBeep(freq, [duration=0.025, amplitude=1, when=0])
%
%
% Closure mode:
%
%   portBeep(nan);
%
% 
% Written by Hyoung-Ryul Kang, 2012. hk2699 at columbia dot edu.

     
persistent mode sampRate chn paHandle latencyClass;

if isempty(freq) % Initialization mode
    if nargin >= 2 && ~isempty(varargin{1})
        mode = varargin{1};
    else
        mode = 1; % Playback only. Set it 3 for capture and playback.
    end
    if nargin >= 3 && ~isempty(varargin{2})
        latencyClass = varargin{2}; 
    else
        latencyClass = 2; % May crash other apps. See PsychPortAudio Open?
    end
    if nargin >= 3 && ~isempty(varargin{3})
        sampRate = varargin{3}; 
    else
        sampRate = 44100;
    end
    if nargin >= 4 && ~isempty(varargin{4})
        chn = varargin{4}; 
    else
        chn = 1;
    end
    if nargin >= 5 && ~isempty(varargin{5}) % Just get paHandle
        paHandle = varargin{5};
        
    else % Actually initialize
        InitializePsychSound(1);
        paHandle = PsychPortAudio('Open', [], mode, latencyClass, freq, chn);
    end 
    
    if nargout > 0
        startTime = [];
    end
    
elseif isnan(freq) % Closure mode
    PsychPortAudio('Close', paHandle);
    
    mode        = [];
    sampRate    = [];
    chn         = [];
    paHandle    = [];
    latencyClass = [];
    
else % Playback mode
    if isempty(paHandle)
        warning('Initialize before first use to get low latency!');
        portBeep([], varargin{:});
    end
        
    if nargin < 2 || isempty(varargin{1})
        dur = 0.025;
    else
        dur = varargin{1};
    end
    if nargin < 3 || isempty(varargin{2})
        beep = MakeBeep(freq, dur, sampRate);
    else
        beep = MakeBeep(freq, dur, sampRate) * varargin{2};
    end
    if nargin < 4 || isempty(varargin{3})
        when = 0;
    else
        when = varargin{2};
    end
    
    if chn > 1
        beep = repmat(beep, [chn 1]);
    end
    
    PsychPortAudio('FillBuffer', paHandle, beep);
    startTime = PsychPortAudio('Start', paHandle, 1, when);
end

if nargout > 1
    oPaHandle = paHandle;
    oMode = mode;
    oLatencyClass = latencyClass;
    oSampRate = sampRate;
    oChn = chn;
end