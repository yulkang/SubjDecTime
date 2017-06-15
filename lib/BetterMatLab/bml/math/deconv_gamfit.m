function gamhat = deconv_gamfit(b, a)
% gamhat = deconv_gamfit(b, a)

c = bsxfun(@minus, b(:)', a(:));
c = c(c(:)>=0);

gamhat = gamfit(c);
end