function dc2 = rep_deep_copy(dc0, siz, as_cell)
    % dc2 = rep_deep_copy(dc|{dc}, [nrow, ncol], as_cell = true)
    if nargin < 3
        as_cell = true;
    end
    if iscell(dc0)
        assert(isscalar(dc0));
        dc0 = dc0{1};
    end
    
    assert(isnumeric(siz));
    if isscalar(siz)
        siz = zeros(1,2) + siz;
    else
        assert(length(siz) == 2);
    end
    for row = siz(1):-1:1
        for col = siz(2):-1:1
            if isa(dc0, 'DeepCopyable')
                dc = deep_copy(dc0);
            elseif isa(dc0, 'matlab.mixin.Copyable')
                dc = copy(dc0);
            elseif row == siz(1) && col == siz(2)
                dc = dc0;
            end
            
            if as_cell
                dc2{row, col} = dc;
            else
                dc2(row, col) = dc;
            end
        end
    end
end
