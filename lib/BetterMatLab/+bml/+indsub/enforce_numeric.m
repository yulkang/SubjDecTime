function ind = enforce_numeric(ind)
% Enforce logical index into a numeric one. Leave numeric indices alone.
if islogical(ind)
    ind = find(ind);
else
    assert(isnumeric(ind));
end