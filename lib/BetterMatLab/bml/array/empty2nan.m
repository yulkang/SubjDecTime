function vec = empty2nan(vec)
% EMPTY2NAN Converts cell/value to vector, filling empty elements with NaN.
%
% vec = empty2nan(cellVec)
%
% See also CROSSEQ

if iscell(vec)
    vec = cell2mat2(vec);
else
    if isempty(vec)
        vec = nan;
    end
end