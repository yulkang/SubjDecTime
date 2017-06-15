function [tf, res] = regexp_tf(str, fmt)
% REGEXP_TF  Returns if any (sub)string matches regexp.
%
% [tf, res] = regexp_tf(str, fmt)
%
% res is the original result.
% tf(k) is 1 if res{k} is nonempty.
%
% EXAMPLE:
% >> regexp_tf({'abc', 'abc_12', '_abc_12'}, '^abc_[0-9]+')
% ans =
%      0     1     0
%
% See also: regexp, str, PsyLib
%
% 2014 (c) Yul Kang. See help PsyLib for the license.

res = regexp(str, fmt);

if iscell(res)
    tf = cellfun(@(c) ~isempty(c), res);
else
    tf = ~isempty(res);
end