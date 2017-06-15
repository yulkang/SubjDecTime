function v = smooth_gauss_nan(v, sigma)
% v = smooth_gauss_nan(v, sigma)
%
% Smooth, ignoring nan.
%
% sigma: in the unit of elements = sigma_in_t / dt_per_element

f = filt_gauss(sigma);
if isvector(v)
    incl = ~isnan(v);
    v(incl) = conv(v(incl),f,'same');
    
elseif ismatrix(v)
    for ii = 1:size(v, 2)
        incl = ~isnan(v(:,ii));
        v(incl, ii) = conv(v(incl, ii), f, 'same');
    end
else
    error('Not implemented yet!');
    v = convn(v,f(:),'same');
end
