function varargout = unpackStruct2(S, fieldS, varargin)
% UNPACKSTRUCT2 : Creates variables with the fields of a struct.
%
% unpackStruct2(S);
% unpackStruct2(S, {'field1', ...});
%
% : Creates variables named the same as the fields. 
%   Unpacks all the fields if unspecified.
%
% OPTIONS:
%     'ignoreError', false
%     'include', true % specified fields are included by default
%
% See also: ws2base
%
% 2013 (c) Yul Kang, hk2699 at columbia dot edu.

SS = varargin2S(varargin, {
    'ignoreError', false
    'include', true
    });

if nargin < 2
    fieldS = fieldnames(S)';
end
if ~SS.include
    fieldS = setdiff(fieldnames(S)', fieldS);
end

if nargout == 0
    if SS.ignoreError
        for ifield = 1:length(fieldS)
            try
                assignin('caller', fieldS{ifield}, S.(fieldS{ifield}) );
            catch
            end
        end            
    else
        for ifield = 1:length(fieldS)
            assignin('caller', fieldS{ifield}, S.(fieldS{ifield}) );
        end
    end
else
    if SS.ignoreError
        for ifield = 1:length(fieldS)
            try
                varargout{ifield} = S.(fieldS{ifield});
            catch
            end
        end
    else
        for ifield = 1:length(fieldS)
            varargout{ifield} = S.(fieldS{ifield});
        end
    end
end
