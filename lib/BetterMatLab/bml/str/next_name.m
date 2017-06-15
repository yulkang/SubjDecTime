function [name, max_num, num] = next_name(name, names, varargin)
% NEXT_NAME  Return a numbered name that follows existing one(s).
%
% [name, max_num, num] = next_name(name, names, ['opt1', opt1, ...])
%
% names  : cell array of names, numbered or not.
% max_num: maximum number among existing.
% num    : vector of existing numbers.
%
% OPTIONS:
% str_con  : Comes between name and the number. Defaults to '_'.
% min_digit: Minimum number of digit. '0' will be spanned for shorter numbers.
% n_name   : Number of names to return. Defaults to 1.
%
% EXAMPLE:
% % Single name
% >> [nam, max_num, num] = next_name('ab', {'a', 'ab', 'abc', 'ab_2', 'ab_10'})
% nam =
% ab_11
% 
% max_num =
%     10
% 
% num =
%      2    10
%
% % Multiple names
% >> [nam, max_num, num] = next_name('ab', {'a', 'ab', 'abc', 'ab_2', 'ab_10'}, 'n_name', 3)
% % nam is now a cell array of strings.
% nam = 
%     'ab_11'    'ab_12'    'ab_13'
% 
% % Other outputs don't change.
% max_num =
%     10 
% 
% num =
%      2    10
%
% See also: str, PsyLib
%
% 2014 (c) Yul Kang. See help PsyLib for the license.

S = varargin2S(varargin, { ...
    'str_con',   '_', ...
    'min_digit', 1, ...
    'n_name',    1, ...
    });

same_beginning = regexp_tf(names, ...
    sprintf('^%s%s[0-9]+', name, S.str_con));

st = length([name, S.str_con]) + 1;

num = cellfun(@(s) str2double(s(st:end)), names(same_beginning));

max_num = max(num);

fmt       = sprintf('%%0%dd', S.min_digit);

if S.n_name == 1
    digit_str = sprintf(fmt, max_num + 1);
    name  = [name, S.str_con, digit_str];
else
    digit_str = csprintf(fmt, max_num + (1:S.n_name));
    name  = csprintf([name, S.str_con, '%s'], digit_str);
end