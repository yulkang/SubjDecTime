function vprintf(varargin)
% vprintf(variable1, variable2, ...)
%
% Pretty-prints variable values.
%
% EXAMPLE:
% >> a = 2; b = 3;
% >> vprintf(a, b)
%         a = 2
%         b = 3
%
% See also: eprintf

for ii = 1:length(varargin)
    if isempty(inputname(ii))
        fprintf('arg%6d =', ii);
    else
        fprintf('%9s = ', inputname(ii));
    end
    
    val = varargin{ii};
    
    if isnumeric(val)
        if size(val,1) == 1
            fprintf('%1.3g\n', val);
        else
            fprintf('\n');
            disp(val);
        end
            
    elseif ischar(val)
        fprintf('%s\n', val);
        
    else
        fprintf('\n');
        disp(val);
    end
end