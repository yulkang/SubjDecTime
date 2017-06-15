function varargout = cellVec(len, varargin)
% CELLVEC   Get scalar numeric/cell/vector numeric and returns a cell vector.
%           Repeats elements to fit the desired length if necessary.
%
% varargout = cellVec(len, varargin)

varargout = cell(1, length(varargin));

for iArg = 1:length(varargin)
    cArg = varargin{iArg};
    
    if ~iscell(cArg)
        varargout{iArg} = repmat({cArg}, [1 len]);
        
    elseif length(cArg) == 1
        varargout{iArg} = repmat(cArg, [1 len]);
        
    elseif length(cArg) == len
        varargout{iArg} = cArg;
    else
        error('Cell argument %s''s length should equal 1 or len %d!', ...
               inputname(iArg+1), len);
    end
end
end