function varargout = deconv_fmincon(b, a)
% gamhat = deconv_gamfit(b, a)

% c = bsxfun(@minus, b(:)', a(:));
% c = c(c(:)>=0);
% 
% gamhat = gamfit(c);

if nargin < 3
    dt = 0.01;
end
t    = 0:dt:(max([a(:); b(:)]) * 2);
b_ix = ceil(b / dt + eps);

gamhat_a = gamfit(a);
gampdf_a = gampdf(t, gamhat_a(1), gamhat_a(2)); 
gampdf_a = gampdf_a / sum(gampdf_a);

gamhat_b = gamfit(b);

[varargout{1:nargout}] = fmincon(@gamLL, gamhat_a, [], [], [], [], [0 0], gamhat_b);

function nll = gamLL(v)
    
    gampdf_b_hat = gampdf(t, v(1), v(2));
    gampdf_b_hat = gampdf_b_hat / sum(gampdf_b_hat);
    
    pdf_max = conv_t(gampdf_a(:), gampdf_b_hat(:)); % max_distrib([gampdf_a(:), gampdf_b_hat(:)]);
    
    nll = -sum(log(pdf_max(b_ix)));
    
    if ~isfinite(nll), nll = realmax; end
end
end