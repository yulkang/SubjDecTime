function res = strrep_fmt(fmt, fmt_char, varargin)
% res = strrep_fmt(fmt, fmt_char, varargin)
%
% EXAMPLE:
% >> strrep_fmt('+%2L-%1L', 'L', 'a', 'b')
% ans =
% +b-a
%
% See also: str, PsyLib
%
% 2014 (c) Yul Kang. See help PsyLib for the license.

loc_st = regexp(fmt, ['%[0-9]+' fmt_char]);
loc_fmt_char = find(fmt == fmt_char);

n = length(loc_st);

p_loc = 0;

res = '';

for ii = 1:n
    loc_en = loc_fmt_char(find(loc_fmt_char > loc_st(ii), 1, 'first'));
    
    ix  = str2double(fmt((loc_st(ii)+1):(loc_en-1)));
    
    res = [res, fmt((p_loc+1):(loc_st(ii)-1)), varargin{ix}]; %#ok<AGROW>
    
    p_loc = loc_en;
end

res = [res, fmt((p_loc+1):end)];
end