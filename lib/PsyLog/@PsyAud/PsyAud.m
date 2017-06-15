classdef PsyAud < PsyDeepCopy & PsyLogs
    % PsyAud Properties:
    %
    % spec          - struct of spec structs.
    % specDefault   - default spec.
    %
    % PsyAud Methods:
    %
    % Example:
    %
    
    properties
        Scr
        pa
        specDefault = struct('type',  {'beeps'}, ...
                             'file',  {''}, ...
                             'nBeep', {1}, ...
                             'freqs', {1000}, 'durs', {0.02}, ...
                             'amps',  {1}, ...
                             'offset',{0.01}, ...
                             'delays',{0.98}, ...
                             'rate',  {44100}, ...
                             'nChn',  {1}, ...
                             'latencyClass', {1}, ...
                             'otherOpenOpt', {{}});
        spec = struct; % struct of structs.
        ready
    end
    
    
    properties (Dependent)
        names
    end
    
    
    properties (Transient)
        wav
    end
    
    
    methods
        function Aud = PsyAud(cScr, varargin)
            % Aud = PsyAud(Scr, {spec1}, {spec2}, ...);
            %
            % : Constructs a PsyAud object and initializes contents to play.
            %   All arguments are optional. Use init() to initalize later.
            %
            %
            % spec for wav ------------------------------------------------------
            %   : {name, waveFile, 'fieldName1', field1, 'fieldName2', ...}
            %
            % waveFile  : full path to a .wav file.
            %
            %
            % spec for beeps ----------------------------------------------------
            %   : {name, 'beeps', 'fieldName1', field1, 'fieldName2', ...}
            %
            %
            % fields: All fields are optional. Some are common to wav & beeps.
            %
            %   nBeep   : Number of the beeps. 
            %             Defaults to 1. Ignored if 'wav'.
            %
            %   freqs   : Pitch of each beep in Hz. Either scalar or a vector.
            %             Defaults to 1000. Ignored if 'wav'.
            %
            %   durs    : Duration of each beep in sec. Either scalar or a vector.
            %             Defaults to 0.02. Ignored if 'wav'.
            %
            %   amps    : Amplitude of each beep in 0-1 range. Either scalar or a vector.
            %             Defaults to 1. Scales wave contents if 'wav'.
            %
            %   offset  : Duration of blank before the first beep or wav in sec.
            %             Defaults to 0.01.
            %
            %   delays  : Duration of blank between each beep. Either scalar or a vector.
            %             Defaults to 0.98. Ignored if 'wav'.
            %
            %   rate    : Sampling rate. 
            %             Defaults to 44100. Overridden by the file's for 'wav'.
            %
            %   nChn    : Either 1 (mono) or 2 (stereo). 
            %             Defaults to 1. Overridden by the file's for 'wav'.
            %
            %   latencyClass : Required latency class. 
            %                  See PsychPortAudio Open? for details.
            %   
            %   otherOpenOpt : Cell vector of options for PsychPortAudio Open, 
            %                  from 'buffersize' and on. 
            %                  See PsychPortAudio Open? for details.
            
            Aud.rootName = 'Scr';
            Aud.parentName = 'Scr';
            Aud.tag = 'Aud';
            
            if nargin > 0
                Aud.Scr = cScr;
            end
            
            if nargin > 1
                init(Aud, varargin{:});
            end
        end
        
        
        function initDefault(Aud, varargin)
            % initDefault(Aud, 'fieldName1', field1, ...)
            %
            % : Sets the default field.
            %
            % fields: All fields are optional. Some are common to wav & beeps.
            %
            %   nBeep   : Number of the beeps. 
            %             Defaults to 1. Ignored if 'wav'.
            %
            %   freqs   : Pitch of each beep in Hz. Either scalar or a vector.
            %             Defaults to 1000. Ignored if 'wav'.
            %
            %   durs    : Duration of each beep in sec. Either scalar or a vector.
            %             Defaults to 0.02. Ignored if 'wav'.
            %
            %   amps    : Amplitude of each beep in 0-1 range. Either scalar or a vector.
            %             Defaults to 1. Scales wave contents if 'wav'.
            %
            %   offset  : Duration of blank before the first beep or wav in sec.
            %             Defaults to 0.01.
            %
            %   delays  : Duration of blank between each beep. Either scalar or a vector.
            %             Defaults to 0.98. Ignored if 'wav'.
            %
            %   rate    : Sampling rate. 
            %             Defaults to 44100. Overridden by the file's for 'wav'.
            %
            %   nChn    : Either 1 (mono) or 2 (stereo). 
            %             Defaults to 1. Overridden by the file's for 'wav'.
            %
            %   latencyClass : Required latency class. 
            %                  See PsychPortAudio Open? for details.
            %   
            %   otherOpenOpt : Cell vector of options for PsychPortAudio Open, 
            %                  from 'buffersize' and on. 
            %                  See PsychPortAudio Open? for details.
            
            Aud.specDefault = varargin2fields(Aud.specDefault, varargin{:});
        end
        
        
        function init(Aud, varargin)
            % Aud.init({spec1}, {spec2}, ...);
            %
            % : Initializes contents to play.
            %
            %
            % spec for wav ------------------------------------------------------
            %   : {name, waveFileOrWav, 'fieldName1', field1, 'fieldName2', ...}
            %
            % waveFile  : full path to a .wav file.
            % wav       : waveform in a 1- or 2-row matrix.
            %             'rate' must be set as a field in this case.
            %
            %
            % spec for beeps ----------------------------------------------------
            %   : {name, 'beeps', 'fieldName1', field1, 'fieldName2', ...}
            %
            %
            % fields: All fields are optional. Some are common to wav & beeps.
            %
            %   nBeep   : Number of the beeps. 
            %             Defaults to 1. Ignored if 'wav'.
            %
            %   freqs   : Pitch of each beep in Hz. Either scalar or a vector.
            %             Defaults to 1000. Ignored if 'wav'.
            %
            %   durs    : Duration of each beep in sec. Either scalar or a vector.
            %             Defaults to 0.02. Ignored if 'wav'.
            %
            %   amps    : Amplitude of each beep in 0-1 range. Either scalar or a vector.
            %             Defaults to 1. Scales wave contents if 'wav'.
            %
            %   offset  : Duration of blank before the first beep or wav in sec.
            %             Defaults to 0.01.
            %
            %   delays  : Duration of blank between each beep. Either scalar or a vector.
            %             Defaults to 0.98. Ignored if 'wav'.
            %
            %   rate    : Sampling rate. 
            %             Defaults to 44100. Overridden by the file's for 'wav'.
            %
            %   nChn    : Either 1 (mono) or 2 (stereo). 
            %             Defaults to 1. Overridden by the file's for 'wav'.
            %
            %   latencyClass : Required latency class. 
            %                  See PsychPortAudio Open? for details.
            %   
            %   otherOpenOpt : Cell vector of options for PsychPortAudio Open, 
            %                  from 'buffersize' and on. 
            %                  See PsychPortAudio Open? for details.
            
            for ii = 1:length(varargin)
                cName = varargin{ii}{1};
                
                cSpec = varargin2fields(Aud.specDefault, ...
                                        varargin{ii}(3:end));
                                    
                if any(strcmp(varargin{ii}{2}, {'beeps', 'sweeps'}))
                    cSpec.type = varargin{ii}{2};
                else
                    cSpec.type = 'wav';
                    if ischar(varargin{ii}{2})
                        cSpec.file = varargin{ii}{2};
                    else
                        cSpec.file = '';
                    end
                end                
                
                switch cSpec.type
                    case 'beeps'
                        for jj = {'freqs', 'durs', 'amps'}
                            cField = jj{1};

                            cSpec.(cField) = rep2fit( cSpec.(cField), ...
                                                         [1, cSpec.nBeep]);
                        end
                        
                        cSpec.delays = rep2fit( cSpec.delays, ...
                                                   [1, cSpec.nBeep - 1]);
                        
                    case 'sweeps'
                        cSpec.args = varargin{ii}(3:end);
                        % Nothing much to do regarding cSpec
                        
                    case 'beepsweeps'
                        cSpec.type = 'beepsweeps';
                        % 'beeps', {beepSpec}, 'sweeps', {sweepSpec}
                        cSpec = varargin2S(varargin{ii}(3:end), cSpec);
                        cSpec.beeps = varargin2S(cSpec.beeps, Aud.specDefault);
                        cSpec = varargin2S(cSpec, Aud.specDefault);
                        
                    case 'wav'
                        cSpec.file = varargin{ii}{2};
                end
                
                Aud.spec.(cName)      = cSpec;
            end
            
            Aud.initwav;
            
            Aud.initLogEntries('markLast', [csprintf('%s_SchedSt', Aud.names), ...
                                           csprintf('%s_SchedEn', Aud.names), ...
                                           csprintf('%s_LogSt',   Aud.names), ...
                                           csprintf('%s_LogEn',   Aud.names)], ...
                              'absSec');
        end
        
        
        function initwav(Aud)
            for ccSpec = fieldnames(Aud.spec)'
                cName = ccSpec{1};
                cSpec = Aud.spec.(cName);
                
                switch cSpec.type
                    case 'beeps'
                        Aud.wav.(cName) = PsyAud.makeBeeps(cSpec);
                        
                    case 'sweeps'
                        Aud.wav.(cName) = PsyAud.makeSweeps( ...
                            Aud.specDefault, cSpec.args{:});
                        
                    case 'beepsweeps'
                        wav_beep  = PsyAud.makeBeeps(cSpec.beeps);
                        
                        [wav_sweep, cSpec.sweeps] = PsyAud.makeSweeps( ...
                            Aud.specDefault, cSpec.sweeps);
                        
                        if size(wav_beep, 2) > size(wav_sweep, 2)
                            wav_sweep(1, size(wav_beep, 2)) = 0;
                        elseif size(wav_beep, 2) < size(wav_sweep, 2)
                            wav_beep(1, size(wav_sweep, 2)) = 0;
                        end
                        
                        Aud.wav.(cName) = (wav_beep * 2 + wav_sweep) / 3;
                        
                    case 'wav'                        
                        if ischar(cSpec.file) && ~isempty(cSpec.file)
                            [~, fname, ext] = fileparts(cSpec.file);
                            try
                                [Aud.wav.(cName), cSpec.rate] ...
                                    = audioread([fname, ext], 'double');
                            catch
                                [Aud.wav.(cName), cSpec.rate] ...
                                    = wavread(cSpec.file, 'double'); %#ok<DWVRD>
                            end
                            Aud.wav.(cName) = Aud.wav.(cName)';
                        else
                            Aud.wav.(cName) = cSpec.file;
                            cSpec.file = '';
                        end
                        
                        cSpec.nChn = size(Aud.wav.(cName), 1);
                        cSpec.durs = size(Aud.wav.(cName), 2) / cSpec.rate;
                        
                        Aud.wav.(cName) = [zeros(cSpec.nChn, ...
                                                round(cSpec.offset * cSpec.rate)), ...
                                          Aud.wav.(cName) * cSpec.amps];
                                      
                        Aud.spec.(cName) = cSpec;
                end           
            end
        end
        
        
        function open(Aud, varargin)
            % Open the ports & fill the buffers, as specified in init.
            %
            % Aud.open
            %   : Opens all.
            %
            % Aud.open(name1, name2, ...)
            %   : Opens specified contents, as defined by PsyAud or by init().
            
            if isempty(varargin)
                toOpen = Aud.names;
            else
                toOpen = varargin;
            end
            
            for ccName = toOpen
                fprintf('\n');
                
                cName = ccName{1};
                
                try
                    PsychPortAudio('Close', Aud.pa.(cName));
                    fprintf('Closed PsyAud port that was already open: %s\n\n', ...
                            cName);
                catch
                    fprintf('Made sure that PsyAud port %s isn''t open yet.\n\n', ...
                            cName);
                end
                
                cSpec     = Aud.spec.(cName);
                
                Aud.pa.(cName) = PsychPortAudio('Open', [], 1, cSpec.latencyClass, ...
                                           cSpec.rate, cSpec.nChn, ...
                                           cSpec.otherOpenOpt{:});
                PsychPortAudio('FillBuffer', Aud.pa.(cName), Aud.wav.(cName));
                
                fprintf('\n');
                fprintf('Opened PsyAud port: %s\n', cName);
                fprintf('  spec:\n');
                disp(cSpec);
                fprintf('\n');
            end
            
            fprintf('\n');
        end
        
        
        function play(Aud, name, atTime, waitForStart)
            % play(Aud, name, atTime, waitForStart)
            
            if nargin < 3, atTime = GetSecs; end
            if nargin < 4, waitForStart = 0; end
            
            % Play
            stT = PsychPortAudio('Start', Aud.pa.(name), 1, ...
                atTime - Aud.spec.(name).offset, waitForStart);
            
            % Log times
            addLog(Aud, {[name '_SchedSt']}, atTime);
            
            if waitForStart
                addLog(Aud, {[name '_LogSt']}, stT + Aud.spec.(name).offset);
            end
        end
        
        
        function when(Aud)
            for ccName = Aud.names
                
                cName = ccName{1};
                
                if ~isnan(Aud.t_.([cName '_SchedSt'])) ...
                 && isnan(Aud.t_.([cName '_LogSt']))
             
                    stat = PsychPortAudio('GetStatus', Aud.pa.(cName));
                
                    requestedStartTime = Aud.t_.([cName '_SchedSt']) ...
                                       - Aud.spec.(cName).offset;
                    
                    if stat.StartTime >= requestedStartTime
                        % If it makes sense (i.e., not the one from last play)
                        
                        addLog(Aud, {[cName '_SchedSt']}, ...
                            stat.RequestedStartTime + Aud.spec.(cName).offset);
                        addLog(Aud, {[cName '_LogSt']}, ...
                            stat.StartTime + Aud.spec.(cName).offset);
                    end

                    if stat.EstimatedStopTime >= requestedStartTime
                        % Only minimally check if it's plausible.
                        
                        addLog(Aud, {[cName '_SchedEn']}, ...
                            stat.RequestedStartTime + Aud.spec.(cName).offset);
                        addLog(Aud, {[cName '_LogEn']}, ...
                            stat.StartTime + Aud.spec.(cName).offset);
                    end
                end
            end
        end
        
        
        function stop(Aud, varargin)
            if nargin < 2
                varargin = Aud.names;
            end
            
            for ccName = varargin
                PsychPortAudio('Stop', Aud.pa.(ccName{1}));
            end
        end
        
        
        function closeLog(Aud)
            Aud.when;
        end
        
        
        function close(Aud, names, ignoreError)
            if ~exist('names', 'var'),       names = Aud.names;   end
            if ~exist('ignoreError', 'var'), ignoreError = true; end
                
            fprintf('\n');
            
            for ccName = names
                cName = ccName{1};
                
                try
                    PsychPortAudio('Close', Aud.pa.(cName));
                    fprintf('Closed PsyAud port: %s\n\n', cName);
                    
                catch lastErr
                    fprintf('Error closing PsyAud port: %s', cName);
                    
                    if ignoreError, 
                        fprintf('... Ignoring it.\n\n');
                    else
                        fprintf('\n\n'); rethrow(lastErr); 
                    end
                end
            end
            
            fprintf('\n');
        end
        
        
        function res = get.names(Aud)
            res = fieldnames(Aud.spec)';
        end
    end
    
    
    methods (Static)
        function wav = makeBeeps(specDef, varargin)
            % wav = makeBeeps(specDefault, ...)
            %
            % OPTIONS:
            %   .nBeep
            %   .freqs
            %   .durs
            %   .delays : delay before each beep.
            %   .rate   : sample rate.
            %   
            
            S = varargin2S(varargin, specDef);
            
            freqs   = S.freqs;
            durs    = S.durs;
            delays  = [S.offset S.delays];
            
            dur     = sum(durs) + sum(delays);
            nSamp   = ceil(dur * S.rate);
            
            wav = zeros(S.nChn, nSamp);
            
            for ii = 1:S.nBeep
                st    = round((  sum(delays(1: ii   )) ...
                               + sum(durs  (1:(ii-1))) ...
                              )* S.rate ...
                             ) ...
                      + 1;
                
                cBeep = repmat(MakeBeep(freqs(ii), durs(ii), S.rate)  ...
                               * S.amps(ii), ...
                           [S.nChn, 1]);
                           
                en    = st + size(cBeep, 2) - 1;
                
                wav(:, st:en) = cBeep;
            end
        end
        
        function wav = makeSweeps(specDef, varargin)
            % wav = makeSweeps(specDefault, varargin)
            
            S = varargin2S({
                'n',        1
                'freqs',    [500 1000] % [StFreq1, EnFreq1; StFreq2, EnFreq2; ...]
                'durs',     0.5
                'delays',   0
                'rate',     44100
                'fun',      'linear' % 'musical' (=exponential) or 'linear' scalining of frequency
                'endAtZero',true % TODO: currently ignored
                }, specDef);
            S = varargin2S(varargin, S);
            
            S.freqs  = rep2fit(S.freqs,  [S.n, 2]);
            S.durs   = rep2fit(S.durs,   [1,   S.n]);
            S.delays = rep2fit(S.delays, [1,   S.n]);
            
            dur      = sum(S.durs) + sum(S.delays);
            nSamp    = ceil(dur * S.rate);
            
            wav      = zeros(S.nChn, nSamp);
            dt       = 1 / S.rate;
            
            for ii = 1:S.n
                tSt     = sum(S.delays(1:ii)) + sum(S.durs(1:(ii-1)));
                tEn     = tSt + S.durs(ii);
                t       = tSt:dt:tEn;                
                
                f0      = S.freqs(ii, 1);
                delta_f = S.freqs(ii, 2);
                
                % tMod: Time in the unit of cycle
                tMod    = t - tSt; % Start from zero.
                
                switch S.fun
                    case 'linear'
                        tMod    = f0 .* tMod + delta_f .* tMod .^ 2 ./ 2;
                    otherwise
                        error('Not implemented yet!');
                end
                
                st      = round(tSt * S.rate) + 1;
                cBeep   = sin(tMod * 2 * pi);                           
                en      = st + size(cBeep, 2) - 1;
                
                wav(:, st:en) = cBeep;
            end
        end
        
        
        %% Declaration
        cue = beep2sweep(cue) % See testAudSweep.m
        cue = beep2beepsweeps(cue) % See testAudSweep.m
    end
end