function [s, b, t, bt] = binSnd(r, p, dt, N, f, fSamp, toPlot, toPlay)
% BINSND Binary frequency sound pulse.
%
% [s, b, t, bt] = binSnd(r, p, dt, N, f, fSamp, [toPlot=false], [toPlay=false])
%
% p  : [p_bilateral] or [p_left, p_right].
%
% dt : dt or [dt gap] in seconds.
%      dt is the time between subsequent pulse onsets, and
%      gap is the time between a pulse's offset to the next pulse's onset.
%
% f  : [f1 f2] in Hz. Set 0 for silence.
%
% Working but not good psychophysically because:
% (1) At short dt (<0.05s), produces low-frequency buzz. But not much more
%     useful than the traditional random dot kinesiogram if dt is too long.
%
% (2) Higher freqency pulse is intrinsically more salient.
%     This is a bigger problem.
%
% (3) Transition between frequencies may be much more important than the 
%     count itself.
%
% Example:
%
% % Startrek-like bifrequency sound (by some group seen in SfN 2012)
% [s, b, t, bt] = binSnd([], 0.6, [0.1 0.05], 40, [400 800], 44100, true, true);
%
% % Poisson Click (Brunton et al., 2013)
% p = rand/2+0.25, P = 0.1; 
% [s, b, t, bt] = binSnd([], [p*P, (1-p)*P], [0.00625 0.003125], 160, [800 0], 44100, true, true);

if ~exist('toPlot', 'var'), toPlot = false; end
if ~exist('toPlay', 'var'), toPlay = false; end

if length(p)>2
    error('length(p) should be 1 or 2!');
    
elseif length(p)==2
    [s(1,:), b(1,:), t, bt(1,:)] = binSnd(r, p(1), dt, N, f, fSamp);
    [s(2,:), b(2,:), ~, bt(2,:)] = binSnd(r, p(2), dt, N, f, fSamp);

    if toPlot
        plot(t, s(1,:),  'b-', t, -s(2,:),  'b-'); % , ...
%              t, bt(1,:), 'r-', t, -bt(2,:), 'r-');
    end
    
else % length(p)==1

    if length(dt) == 1
        gap = 0;
    else
        gap = dt(2);
        dt  = dt(1);
    end

    T       = N * dt;
    Nsamp   = round(fSamp * T);
    s       = zeros(1,Nsamp);
    bt      = zeros(1,Nsamp);

    if ~isempty(r)
        b = rand(r, 1, N) > p;
    else
        b = rand(1, N) > p;
    end

    t = (0:(Nsamp-1))/fSamp;

    for ii = 1:N
        st = floor((ii-1)*dt*fSamp) + 1;

        en = floor((ii*dt-gap)*fSamp);

        if f(b(ii)+1)~=0
            s(st:en) = sin(t(st:en)*2*pi*f(b(ii)+1)) / 2 + 0.5;
        end
        bt(st:en)= b(ii);
    end
    
    if toPlot
        plot(t, s, 'b-'); % , t, bt, 'r-'); 
    end
end

if toPlay
    Snd('Play', s, 44100);
end