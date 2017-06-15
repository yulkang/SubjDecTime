function q = emp_deconv(b, a, pos)
% q = emp_deconv(b, a, pos)

if nargin < 3, pos = true; end

na = length(a);
nb = length(b);
q = zeros(1,nb);

if pos
    for ii = 1:nb
        ca = a(2:min(ii,na));
        cq = q((ii-1):-1:max(1, ii-na+1));
        
        q(ii) = (b(ii) - sum(ca .* cq)) / a(1);
    end
else
    error('Unimplemented yet!');
end