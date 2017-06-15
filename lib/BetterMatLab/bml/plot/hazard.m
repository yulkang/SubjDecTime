function v = hazard(v, d)
% haz = hazard(v, d)

if nargin < 2
    if isrow(v), d = 2; else d = 1; end
end
    
try
    v = v ./ cumsum(v, 'reverse');
catch
    v = v ./ flipdim(cumsum(flipdim(v, d), d), d); %#ok<DFLIPDIM>
end