function [ch, chIx] = input_defs(querry, choices, varargin)
% [ch, chIx] = input_defs(querry, choices, varargin)
%
% querry : a string.
% choices: a cell vector of strings.
%
% OPTIONS
% -------
% 'maxN', inf
% 'def', nan
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

persistent querries defs

S = varargin2S(varargin, {
    'maxN', inf
    'def',  nan
    });
assert(S.maxN > 0, 'maxN must be > 0!');

if ~isempty(querries) && ismember(querry, querries)
    retrieve_def = false;
    try
        ixQ = find(strcmp(querry, querries), 1, 'last');
        def = defs{ixQ};
    catch
        retrieve_def = true;
    end
else
    retrieve_def = true;
end

if retrieve_def
    querries = [querries; {querry}];
    ixQ = length(querries);
    def = S.def;
end

if ischar(def) || iscell(def)
    def = strcmpfinds(def, choices);
end

n = length(choices);
if any(def > n) || (length(def) > S.maxN), def = nan; end

fprintf('Choices:\n');
cfprintf(' %3d: %s\n', 1:length(choices), choices);

chIx = nan;
while isnan(chIx)
    fprintf('%s (default: ', querry);
    fprintf(' %d', def);
    fprintf(', maxN:%d', S.maxN);
    chIx = input('):');
    
    if isempty(chIx)
        chIx = def;
    elseif length(chIx) > S.maxN
        chIx = nan;
    end
end

if S.maxN == 1
    ch = choices{chIx};
else
    ch = choices(chIx);
end

defs{ixQ} = ch;
end