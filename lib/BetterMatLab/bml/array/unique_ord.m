function ix = unique_ord(v)
% ix = unique_ord(v)

[~,~,ix] = unique(v, 'stable');

% ix = zeros(size(v));
% n = length(v);
% 
% for ii = 1:n
%     if ix(ii) ~= 0, continue; end
%     ix(v == v(ii)) = ii;
% end
    