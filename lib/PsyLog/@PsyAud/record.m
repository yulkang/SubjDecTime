function wavout = record(Aud, file, varargin)
S = varargin2S(varargin, {
    'dur',  []
    'replaceFile', {} % {spec1, wav1; spec2, wav2; ...}
    't0', 0 % This time will be considered zero. Give, e.g., Scr.relSec('frOn')(1).
    });

samprate    = Aud.specDefault.rate;

%% Replace files if requested
if ~isempty(S.replaceFile)
    for ii = 1:size(S.replaceFile)
        s  = S.replaceFile{ii,1};
        f  = S.replaceFile{ii,2};
        
        assert(strcmp(Aud.spec.(s).type, 'wav'), 'Cannot replace if the type is not wav!');
            
        Aud.spec.(s).file = f;
    end
end

%% Fill in wav
if isempty(Aud.wav)
    Aud.initwav;
end

%% Determine duration
if isempty(S.dur)
    S.dur = max(cell2mat(cellfun(@vVec, struct2cell(Aud.relSec), 'UniformOutput', false)));
    S.dur = S.dur + max(cellfun(@length, struct2cell(Aud.wav))) / samprate;
end

nsamp_trial = ceil(samprate * S.dur);
wav = zeros(Aud.specDefault.nChn, nsamp_trial);

relSecs = Aud.relSec;

% Align on t0
for fs = fieldnames(relSecs)'
    relSecs.(fs{1}) = relSecs.(fs{1}) - S.t0;
end

%% Record each track, and add
for ccname = Aud.names(:)'
    st  = max(round(relSecs.([ccname{1} '_LogSt']) * samprate), 1);
    
    if isempty(st), continue; end
    
%     en  = max(round(relSecs.([ccname{1} '_LogEn']) * samprate), 1);
%     nen = length(en);
%     dur(1:nen) = en - st(1:nen) + 1;
        
    cwav   = Aud.wav.(ccname{1});
    crate  = Aud.spec.(ccname{1}).rate;
    if samprate ~= crate
        cwav = resample(cwav', samprate, crate)'; 
    end

    if size(cwav,1) > size(wav,1)
        cwav = mean(cwav,1);
    elseif size(cwav,1) < size(wav,1)
        cwav = repmat(cwav,[2 1]);
    end
    wavlen = size(cwav, 2);

    % en is incorrect somehow.
    dur = repmat(wavlen, size(st));
%     if length(en) < length(st)
%         ix = (nen+1):length(st);
%         dur(ix) = wavlen; %#ok<AGROW>
%     end
    en = st + dur - 1; % min(wavlen, dur) + st - 1;

    % Add sound at each LogSt with clipping
    for ii = 1:length(st)
        if size(wav, 2) < en(ii)
            wav(end, en(ii)) = 0;
        end
        wav(:,st(ii):en(ii)) = minmax( ...
            bsxfun(@plus, wav(:,st(ii):en(ii)), cwav(:,1:dur(ii))), ...
            -1, 1);
    end
end
    
%% Save to file
if nargin >= 2 && ~isempty(file)
    try
        audiowrite(file, wav, samprate, 'BitsPerSample', 16);
    catch
        wavwrite(wav, samprate, 16, file); %#ok<DWVWR>
    end
    fprintf('Audio is recorded to %s\n', file);
end

%% Output
if nargout > 0, wavout = wav; end