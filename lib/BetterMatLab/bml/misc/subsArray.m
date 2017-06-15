function S = subsArray(varargin)
% Create substruct from simple vectors.
%
% EXAMPLE:
% S = subsArray([2 3], [-1 -2], 'c');
% disp(S);

n = length(varargin);
C = cell(1, 2 * n);

for ii = 1:n
    if isnumeric(varargin{ii})
        if any(varargin{ii} < 0)
            typ = '{}';
            ix  = -varargin{ii};
        else
            typ = '()';
            ix  = varargin{ii};
        end            
        
    elseif ischar(varargin{ii})
        switch varargin{ii}
            case ':'
                typ = '()';
                ix  = ':';
            case ';'
                typ = '{}';
                ix  = ':';
            otherwise
                typ = '.';
                ix  = varargin{ii};
        end
    else
        error('Give an integer, positive for (), negative for {}, or char for .!');
    end
    
    C{ii*2-1} = typ;
    C{ii*2}   = ix;
end

S = substruct(C{:});