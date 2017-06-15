function [startTime oPaHandle oPaMode oLatencyClass oSampRate oChn] ... 
        = portWave(filename, varargin)

% For users of PsychToolbox 3
% : Very simple wrapper for PsychPortAudio. Eases programming without 
%   compromising performance.
%   
%   portWave({'file1.wav', 'file2.wav'}); % Initializes PsychPortAudio
%                                         % automatically according to the 
%                                         % files specified.
%   
%   startTime = portWave('file1.wav');    % Plays back file1.wav (preloaded)
%                                         % with low-latency.
%
%
% For users of PsychLib
% : Supersedes playWave(~, 'async'), which used online sound loading 
%   and high-latency playback.
%
%   Can be used with changing only the function name (playWave -> portWave).
%   In such case, the first playback will be high-latency as before, but the
%   following playbacks will be low-latency.
%
%   With an addition of one preloading line (see below), the first playback
%   becomes low-latency, too. Furthermore, portWave automatically avoids 
%   loading preloaded files again, further enhancing performance.
%
% [~, paHandle, paMode, latencyClass, sampRate, chn] = ...
%   portWave({'file1.wav', 'file2.wav', ...}, [loadMode, paMode=1, latencyClass=2, paHandle]);
%
% : Loads files for low-latency playback. Also initializes PsychPortAudio.
%
%   paMode       1          Playback only.
%                3          Playback and recording.
%
%   loadMode    'replace'   Deletes previously loaded files and add new ones.
%                           
%               'append'    Append new files. Default value. Equivalent to loadmode = [].
%                           Overlapping files won't be loaded again.
%
%   latencyClass            According to the PsychPortAudio help:
%                0          Don't care about latency. Work smooth with other
%                           programs.
%                1          (Default) Shortest latency without interfering
%                           other programs.
%                2          Do anything to get shortest latency, even if it
%                           interferes with other programs.
%                3          The most aggressive settings for the given
%                           device.
%                4          Issue error when the device can't meet the
%                           strictest requirements.
%
%   Note that number of channels & frequency is always set to the first file's, 
%   and only one kind is allowed. It simplifies the call and works smoothly
%   in most settings. To change the number of channels & frequency, you can
%   use free softwares like Audacity (http://audacity.sourceforge.net/) or
%   others.
%
%
% startTime = portWave('file1.wav', [when]);
%
% : Plays the file with low latency, and returns accurate start time.
%   Schedules playback after WHEN seconds from now, and returns immediately. 
%  (Default is WHEN=0 to start now.)
%
%
% Written by Hyoung-Ryul Kang, 2012. hk2699 at columbia dot edu.


persistent wavFNames wavs paHandle paMode sampRate chn;

if iscell(filename) % Load
    
    if nargin < 2 || isempty(varargin{1})
        loadMode = 'append'; 
    else
        loadMode = varargin{1}; 
    end
    if nargin < 3 || isempty(varargin{2})
        paMode = 1;
    else
        paMode = varargin{2};
    end
    if nargin < 4 || isempty(varargin{3})
        latencyClass = 1; 
    else
        latencyClass = varargin{3}; 
    end
    if nargin >= 5 && ~isempty(varargin{4})
        paHandle = varargin{4};
    end
    
    % If loadmode is 'replace', delete existing data.
    if strcmp(loadMode, 'replace')
        wavFNames = {};
        wavs = {};
    end
    
    % Set up flag
    reopenPort = false;
    
    %% Load files one by one.
    for iWav = 1:length(filename)
        
        % Find the file
        iFile = find(strcmp(filename{iWav}, wavFNames));
        
        if isempty(iFile) || (iFile == 0)
            
            %% Load file if absent
            [wav cSampRate] = wavread(filename{iWav}, 'double');
            wav = wav';
            
            
            %% Initialize number of channels if not yet done.
            cChn = size(wav,1);

            if isempty(chn), chn = cChn; end

            % Only one kind of number of channels is allowed.
            if cChn ~= chn
                warning(['Only one kind of number of channels is allowed,\n' ...
                         'but %s''s = %d differs from the original %d!\n' ...
                         'Feeding average to all channels in the new file..\n'], ...
                          filename{iWav}, cChn, chn);

                % Force all channels to the average.
                wav = repmat(mean(wav,1), [chn 1]);
            end
            

            %% Initialize frequency if noy yet done.
            if isempty(sampRate), sampRate = cSampRate; end
            
            
            % Only one frequency is allowed across files for performance.
            if cSampRate ~= sampRate
                warning(['Only one sampling frequency is allowed,\n' ...
                         'but %s''s = %d differs from the original %d!'], ...
                          filename{iWav}, cSampRate, sampRate);
                
                % Force the same sampling frequency.
                if cSampRate > sampRate
                    warning('Downsampling the new file');
                    wav = downsample(wav, cSampRate, sampRate);
                else
                    warning('Downsampling the old files');
                    for iiWav = 1:length(wavs)
                        wavs{iiWav} = downsample(wavs{iiWav}, sampRate, cSampRate);
                    end
                    
                    sampRate = cSampRate;
                    
                    reopenPort = true;
                end
            end            
            
            
            %% Append the wav to the buffer.
            fprintf('Loaded %s successfully!\n', filename{iWav});
            wavs{end+1} = wav; %#ok<AGROW>
            wavFNames{end+1} = filename{iWav}; %#ok<AGROW>
        end
    end
    
    % If some parameter change enforces reopening the port
    if reopenPort && ~isempty(paHandle)
        PsychPortAudio('Close', paHandle);
        paHandle = [];
    end
    
    % Initialize PsychPortAudio if not done yet.
    if isempty(paHandle)
        ndisp(latencyClass);
        ndisp(sampRate);
        ndisp(chn);
        
        InitializePsychSound(1);
        paHandle = PsychPortAudio('Open', [], paMode, latencyClass, sampRate, chn);
    
    end
    
    if nargout > 0
        startTime = [];        
    end
    
elseif isnan(filename) % Close
    PsychPortAudio('Close', paHandle);
    
    wavFNames   = {};
    wavs        = [];
    paHandle    = [];
    paMode      = [];
    sampRate    = [];
    chn         = [];
    
else % Play
    
    if nargin<2, when = 0; else when = varargin{1}; end
    
    % Determine where the wave data is in the buffer.
    iWav = find(strcmp(filename, wavFNames));
    
    % Initialize if necessary.
    if isempty(paHandle) || isempty(iWav) || (iWav==0), 
        warning('Loading %s. Preload .wav files with portWave({''file1.wav'', ''file2.wav'', ...}); for low-latency playback!', filename);
        portWave({filename}, 'append'); 
        
        iWav = strcmp(filename, wavFNames);
    end 
    
    % Play
    PsychPortAudio('FillBuffer', paHandle, wavs{iWav});
    startTime = PsychPortAudio('Start', paHandle, 1, when);    
end

if nargout > 1
    oPaHandle = paHandle;
    oPaMode = paMode;
    oLatencyClass = latencyClass;
    oSampRate = sampRate;
    oChn = chn;    
end
end



function res = downsample(wav, src, dst)
% function res = downsample(vec, src, dst)
%
% Downsamples WAV with SRC sampling rate to DST sampling rate.
% WAV should have dimensions of channels x samples.

if rem(src, dst)~=0
    error('Cannot downsample if sampling frequencies don''t differ by an integer factor!');
end
                
res = wav(:, (src/dst):(src/dst):end);
end