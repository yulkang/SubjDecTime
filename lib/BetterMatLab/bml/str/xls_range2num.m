function num = xls_range2num(str, varargin)
% num = xls_range2num(str, varargin)

S = varargin2S(varargin, { ...
    'max_digit', 26, ...
    });

num = 0;

for ii = 1:length(str)
    num = num * S.max_digit + (str(ii) - 'A' + 1);
end

num = num - 1;