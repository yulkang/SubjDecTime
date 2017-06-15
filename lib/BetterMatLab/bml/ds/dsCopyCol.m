function ds2 = dsCopyCol(ds2, ds1, varargin)
% dsCopyCol  Copies columns of the 2nd argument to 1st argument.
%
% ds2 = dsCopyCol(ds2, ds1, varargin)

if isempty(varargin)
    for cV = get(ds1, 'VarNames')
        ds2.(cV{1}) = ds1.(cV{1});
    end
else
    for cV = varargin
        ds2.(cV{1}) = ds1.(cV{1});
    end
end