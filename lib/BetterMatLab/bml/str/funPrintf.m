function s = funPrintf(frm, varargin)
% Replaces alphabets in the format to strings, except for escaped ones.
%
% s = funPrintf(frm, formatChar1, replacingStr1, ...)
%
% frm           : String. Characters matching one of formatChar is replaced by
%                 corresponding replacingStr escept when the formatChar is 
%                 preceded by %. Use %% to have % in the result.
%                 
% formatChar    : One alphabet character, either upper or lower case.
%
% replacingStr  : Any string.
%
% *When there are duplicate formatChars, the last replacingStr takes precedance.
%
% EXAMPLE:
%
% >> funPrintf('D%TT%%', 'D', '20130725', 'T', '162105');
% ans = 20130725T162105%
%
% See also FUNFULLFILE, FUNPRINTFCONNECT.

frmChar = varargin(1:2:end);
replStr = varargin(2:2:end);
len     = length(frm);

s = '';
ii = 0;
while ii < len
    ii = ii + 1;
    
    if frm(ii) == '%'
        s = [s, frm(ii+1)]; %#ok<*AGROW>
        ii = ii + 1;
    else
        cFrm = find(strcmp(frm(ii), frmChar), 1, 'last');
        
        if isempty(cFrm)
            s = [s, frm(ii)];
        else
            s = [s, replStr{cFrm}];
        end
    end
end



