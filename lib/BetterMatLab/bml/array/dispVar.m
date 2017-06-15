function dispVar(varargin)
% dispVar(variable1, variable2, ...)
%
% Example
%
% dispVar(a, [2 3], b)
%          a =      2
% 
% #        2 =      2     3
% 
%          b =      4
% 
% 2013 Yul Kang. hk2699 at columbia dot edu.

for ii = 1:length(varargin)
    if isempty(inputname(ii))
        fprintf('#%d =\n', ii);
    else
        fprintf('%s =\n', inputname(ii));
    end
    disp(varargin{ii});
end