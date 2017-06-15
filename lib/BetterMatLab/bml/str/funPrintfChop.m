function c = funPrintfChop(frm, connectChar)
% Chop at connectChar, except when it's preceded by %.
%
% c = funPrintfChop(frm, connectChar)

c = cell(1,nnz(frm==connectChar)+1);
iC = 1;

nEsc = 0;
ii = 0;
while ii<length(frm)
    ii = ii + 1;
    
    if frm(ii) == connectChar && (mod(nEsc,2)==0)
        iC = iC + 1;
    else
        c{iC} = [c{iC}, frm(ii)];
        
        if frm(ii) == '%'
            nEsc = nEsc + 1;
        else
            nEsc = 0;
        end
    end
end

c = c(1:iC);
c(cellfun(@isempty, c)) = {''}; % To keep the type as char.
