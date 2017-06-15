function res = reverse(vec)
% res = reverse(vec)

res = reshape(vec(length(vec):-1:1), size(vec));
end