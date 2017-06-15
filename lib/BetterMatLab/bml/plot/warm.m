function res = warm(n)
% res = warm(n)
%
% See also: colormap, PsyLib
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

% Purple to green 2
res = cool(n);
res = res(:,[1 3 2]);
res(:,2) = 0.8;

res = [linspace(0, 1, n)
       linspace(0.8, 0.5, n)
       linspace(0.7, 0, n)]';

% % Purple to green
% res = cool(ceil(n*1.2));
% res = res((end-n+1):end,:);
% res(:,3) = 0 + res(:,1)*0.9;
% res(:,1:2) = res(:,1:2)*0.5 + 0.5;

% % Cyan to orange
% col1 = spring(ceil(n * 1.5));
% col2 = cool(ceil(n * 1.1));
% 
% col1 = col1(1:n,:);
% col2 = col2((end-n+1):end,:);

% % Orange to green
% col1 = summer(ceil(n * 2));
% col2 = autumn(ceil(n * 2));
% 
% col1 = (col1(n:-1:1,:));
% col2 = (col2((n+1):end,:));

% w = linspace(0, 1, n)';
% 
% res = (bsxfun(@times, col1, w) + bsxfun(@times, col2, 1-w));

