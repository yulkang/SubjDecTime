function varargout = unpackStruct(S, varargin)
% UNPACKSTRUCT : Creates variables with the fields of a struct.
%
% unpackStruct(S);
% unpackStruct(S, 'field1', ...);
% unpackStruct(S, {'field1', ...});
%
% : Creates variables named the same as the fields. 
%   Unpacks all the fields if unspecified.
%
% var1 = default1;
% var2 = default2;
% ...
% [var1, var2, ...] = unpackStruct(S, var1, var2, ...);
%
% : When output arguments exist, replaces each input variable's value 
%   with the value of a field with the same name, if such field exists. 
%   If not, keeps original value.
%   Every argument must be a variable or a variable name.
%   In case a string variable is given, its name is taken, rather than the
%   value. For example,
%     S = struct('A', 10, 'B', 20);
%     B = 'A'; 
%     C = unpackStruct(S, B);
%   gives C == 20, rather than 10. Use expressions to work around this behavior.
%   For example, either of the following
%     C = unpackStruct(S, 'A');
%     C = unpackStruct(S, [B '']);
%   gives C == 10.
%
% See also: ws2base
%
% 2013 (c) Yul Kang, hk2699 at columbia dot edu.

if nargout == 0
    if isempty(varargin)
        fieldS = fieldnames(S);
    elseif iscell(varargin{1})
        fieldS = varargin{1};
    elseif ischar(varargin{1})
        fieldS = varargin;
    else
        error('Wrong input format!');
    end
    nfieldS = numel(fieldS);

    for cfield = 1:nfieldS
        assignin('caller', fieldS{cfield}, S.(fieldS{cfield}) );
    end
    
elseif isempty(inputname(2)) && iscell(varargin{1})
    varargout = cell(1, nargout);
    for ii = 1:nargout
        varargout{ii} = S.(varargin{1}{ii});
    end
    
else
    varargout = varargin(1:nargout);
    
    for ii = 1:nargout
        if ~isempty(inputname(ii+1))
            if isfield(S, inputname(ii+1))
                varargout{ii} = S.(inputname(ii+1));
            end
        else
            if ischar(varargin{ii})
                varargout{ii} = S.(varargin{ii});
            else
                error('When output(s) exist, input(s) must be either variables or field names!');
            end
        end
    end
end