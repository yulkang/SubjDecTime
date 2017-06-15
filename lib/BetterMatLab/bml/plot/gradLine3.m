function h = gradLine3(x,y,z,c,varargin)
% Line with gradual change in color
%
% h = gradLine3(x,y,z,c=[0 0 0],varargin)
%
% Options
% -------
% 'EdgeAlpha', 0.5

if nargin < 4|| isempty(c)
    c = [0 0 0];
end

C = varargin2C(varargin, {
    'EdgeAlpha', 0.5
    });

if size(c,1) == 1 && size(c,2) == 3
    c = linspaceN(0.8+zeros(1,3), c, numel(x)); % ; nan(1,3)];
%     c = linspaceN(0.8+zeros(1,3), c, numel(x)+1); % ; nan(1,3)];
elseif size(c,1) == 2 && size(c,2) == 3
    c = linspaceN(c(1,:), c(2,:), numel(x)); % ; nan(1,3)];
%     c = linspaceN(c(1,:), c(2,:), numel(x)+1); % ; nan(1,3)];
end

x = x(:);
y = y(:);
z = z(:);
c = [c; c(end,:)];
c = permute(c, [1 3 2]);

h = patch('XData', [x;nan], 'YData', [y;nan], 'ZData', [z(:);nan], ...
    'CData', c, ...
    'FaceColor','none','EdgeColor','interp', C{:});
% h = patch('XData', [x;flipud(x)], 'YData', [y;flipud(y)], 'ZData', [z(:);flipud(z)], ...
%     'CData', [c; flipud(c)], ...
%     'FaceColor','none','EdgeColor','interp', C{:});
% h = patch([x(:);NaN],[y(:);NaN],[z(:);NaN], 'CData', permute(c, [1 3 2]), ...
%     'FaceColor','none','EdgeColor','interp', C{:});
