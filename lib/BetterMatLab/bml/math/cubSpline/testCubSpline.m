N = 20;
N1 = N+1;

% % Construct equation matrix, which can be reused.
% % ref: http://mathworld.wolfram.com/CubicSpline.html, eq. (18)
% spMat = spdiags([ones(N1,1), zeros(N1,1)+4, ones(N1,1)]/3, -1:1, N1,N1);
% spMat(1,1) = 2;
% spMat(N1,N1) = 2;
% 
% y  = rand(N1,1);
% Dy = zeros(N1,1);
% Dy1= zeros(N,1);
% D  = zeros(N1,1);
% D1 = zeros(N,1);
% D2 = zeros(N,1);
% a  = zeros(N,1);
% b  = zeros(N,1);
% c  = zeros(N,1);
% d  = zeros(N,1);
% 
% tic;
% for ii = 1:1000
%     Dy = [y(2)-y(1); y(3:N1)-y(1:(N-1)); y(N1)-y(N)];
%     D  = spMat \ Dy;
%     
%     D1 = D(1:N);
%     D2 = D(2:N1);
%     Dy1 = Dy(1:N);
%     
%     a = y(1:N);
%     b = D1;
%     c = 3*Dy1 - 2*D1 - D2;
%     d = -2*Dy1 + D1 + D2;
% end
% toc;

y = normpdf(linspace(-4,4,N1)'); % rand(N1,1);
tic;
for ii = 1:1000
    [a,b,c,d] = estSpline(y);
end
toc;

%%
x       = (1:N1)';
xFine   = (1:0.01:(N1-0.01))';

tic;
ySp     = valSpline(xFine,a,b,c,d);
toc;

subplot(3,1,1);
plot(x, y, '.:'); hold on;
plot(xFine, ySp, 'r-'); hold off;

subplot(3,1,2);
plot(xFine(2:end), diff(ySp), '-'); ylim([-0.01 0.01]);

subplot(3,1,3);
plot(xFine(3:end), diff(ySp,2), '-'); ylim([-0.0001 0.0001]);