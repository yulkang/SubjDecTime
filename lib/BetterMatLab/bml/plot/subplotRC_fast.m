function hA = subplotRC_fast(op, hFig, r, c)
% SUBPLOTRC_FAST  Faster wrapper for subplotRC
%
% hA = subplotRC_fast(op, hFig, r, c)
%
% op: 'init' or 'choose'
% r/c : Number of rows/columns for 'init'. 
%       Row/Column position for 'choose'

persistent hF hA nR nC

switch op
    case 'init'
        if isempty(nR) || isempty(nC) || isempty(hF) || hF ~= hFig || ...
                nR ~= r || nC ~= c
            hF = hFig;
            nR = r;
            nC = c;
            hA = zeros(nR, nC);
            
            for ii = 1:nR
                for jj = 1:nC
                    hA(ii, jj) = subplotRC(nR, nC, ii, jj);
                end
            end
        end        
        
    case 'choose'
        axes(hA(r, c));
end
       