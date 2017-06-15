function S = varargin2SArray(S, ix, varCell)
% S = varargin2SArray(S, ix, name_value_pair_or_struct)
%
% See also varargin2S

switch class(varCell)
    case 'cell'
        for ii = 1:2:length(varCell)
            S(ix).(varCell{ii}) = varCell{ii+1};
        end
    
    case 'struct'
        for f = fieldnames(varCell)'
            S(ix).(f{1}) = varCell.(f{1});
        end
        
    otherwise
        error('Unsupported input class!');
end