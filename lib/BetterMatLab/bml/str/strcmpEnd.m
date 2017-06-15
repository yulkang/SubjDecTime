function res = strcmpEnd(a, b, varargin)
% Compare final parts of two strings.
%
% res = strcmpEnd(a, b, ['opt1', opt1, ...])
%
% a is a string.
% b can be either a string or a cell array of strings.
%
% OPTIONS:
% 'mark_shorter_b_different'
% : If false (default), returns if the shorter of a and b matches 
%   the other's beginning.
%   If true, if b is shorter than a, returns false.
%
% EXAMPLE:
% >> strcmpEnd('ba', 'aa')
% ans =
%      0
%      
% >> strcmpEnd('ba', 'a')
% ans =
%      1
%
% See also: str, PsyLib
%
% 2014 (c) Yul Kang. See help PSYLIB for the license.


S = varargin2S(varargin, { ...
    'mark_shorter_b_different', false, ...
    }, true);

if iscell(b)
    res = cellfun(@(bb) strcmpEnd(a, bb, varargin{:}), b);
else
    lenA = length(a);
    lenB = length(b);

    if lenA <= lenB
        res = strcmp(a, b((end-lenA+1):end));
        
    elseif S.mark_shorter_b_different
        res = false;
        
    else
        res = strcmp(a((end-lenB+1):end), b);
    end
end