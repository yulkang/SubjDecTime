% PsyLog Suite
% : A MATLAB library for high-level psychophysics programming,
%   with auto-logging & replay functionality.
%
% PsyV: PsyVPTB, PsyVOnOffColor, PsyVClock, PsyVRandomDotMotion
% PsyA: PsyABeeps, PsyAWav
% PsyScr
% PsyKey
% PsyMouse
% PsyEye
%
%%% Can logging be optional??
%
% Common nomenclature
%
% Prefix
%
% h         : handle
% i         : index, single
% ix        : index, multiple
% c, cur    : current
% p, prev   : previous
% n         : next, number of
% t         : time
% temp      : temporary
% st        : starting
% en        : ending
%
% Other acronyms
%
% fr        : frame
% relSec    : second from trial start.
% v, V      : version, visual, vector
% A, Aud    : auditory
% I, Inp    : input
% L         : logging struct.
%
% Capital letters
%
% Names start with a capital letter when it is (1) a class, (2) an object,
% (3) a struct property that is modified in a specific way in the class, or
% (4) a method that deals with (3).