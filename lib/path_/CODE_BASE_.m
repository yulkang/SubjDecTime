function res = CODE_BASE_(ptn)
% Find out code base from pattern

persistent code_base
if isempty(code_base)
    if nargin == 0
        try
            is_win = IsWin;
        catch err
            warning('IsWin not found! Setting is_win to false...');
            is_win = false;
        end
        if is_win
            ptn = '\Code\';
        else
            ptn = '/Code/'; 
        end
    end
    
    c_full = mfilename('fullpath');
    ix = strfind(c_full, ptn);
    
    assert(~isempty(ix), 'Pattern %s not found in %s!\n', ptn, c_full);
    
    code_base = c_full(1:(ix(1) + length(ptn) - 2));
end

res = code_base;
end