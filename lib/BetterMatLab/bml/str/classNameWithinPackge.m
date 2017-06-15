function c = classNameWithinPackge(c)
% c = classNameWithinPackge(c)

ix = find(c == '.', 1, 'last');
if ~isempty(ix)
    c = c((ix+1):end);
end
end