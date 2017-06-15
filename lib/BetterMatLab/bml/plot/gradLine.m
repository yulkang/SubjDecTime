function [h_line, h_marker] = gradLine(x,y,varargin)
% Line with gradual change in color
%
% h = gradLine(x,y,varargin)
%
% Options
% -------
% S = varargin2S(varargin, {
%     'ax', gca
%     'colors', @hsv
%     'edge_args', {}
%     'marker_args', {}
%     });
% edge = varargin2S(S.edge_args, {
%     'FaceColor','none'
%     'EdgeColor','interp'
%     'EdgeAlpha', 0.8
%     });
% marker = varargin2S(S.marker_args, {
%     'LineStyle', 'none'
%     'Marker', 'none'
%     'MarkerFaceColor', 'auto'
%     'MarkerEdgeColor', 'w'
%     });
%
% EXAMPLE:
% for ii = 1:100
%     gradLine(1:3, rand(1,3)/3 + [0, 0.1, 0.2], ...
%         'colors', [0 0 0; 0 0 0], ...
%          'edge_args', {'LineWidth', 2, 'EdgeAlpha', 0.2}, ...
%          'marker_args', {'Marker', 'none'}); 
% end

% 2015-2016 (c) Yul Kang. hk2699 at columbia dot edu.

%% Line
if ~isvector(x) && size(x, 2) > 1
    for ii = size(x, 2):-1:1
        [h_line(ii), h_marker(:,ii)] = ...
            bml.plot.gradLine(x(:,ii), y(:,ii), c, varargin{:});
        hold on;
    end
    hold off;
    return;
end

%% Segment
assert(isvector(x));
assert(isvector(y));

n = numel(x);
z = [zeros(n,1); NaN];

S = varargin2S(varargin, {
    'ax', gca
    'colors', @hsv2
    'edge_args', {}
    'marker_args', {}
    });
edge = varargin2S(S.edge_args, {
    'FaceColor','none'
    'EdgeColor','interp'
    'EdgeAlpha', 0.8
    });
marker = varargin2S(S.marker_args, {
    'LineStyle', 'none'
    'Marker', 'o'
    'MarkerFaceColor', 'auto'
    'MarkerEdgeColor', 'w'
    });

if isnumeric(S.colors)
    c = S.colors;
elseif isa(S.colors, 'function_handle')
    c = S.colors(n);
elseif ischar(S.colors)
    % Should be a colormap function's name, e.g., 'hsv' or 'hot'.
    c = feval(S.colors, n);
else
    error('colors must be a matrix, function handle, or function name!');
end

assert(size(c,2) == 3);
if size(c,1) == 1
    c = [linspaceN(0.9+zeros(1,3), c, n)];
elseif size(c,1) == 2
    c = [linspaceN(c(1,:), c(2,:), n)];
else
    assert(size(c,1) == n);
end
c = [c; zeros(1,3)];

C = S2C(edge);
h_line = patch(S.ax, [x(:);NaN],[y(:);NaN],z, 'CData', permute(c,[1,3,2]), ...
    C{:});

view(2);

%% Marker
if ~strcmp(marker.Marker, 'none')
    h_marker = gobjects(n, 1);
    for ii = 1:n
        marker1 = marker;
        if strcmp(marker1.MarkerFaceColor, 'auto')
            marker1.MarkerFaceColor = c(ii,:);
        end
        
        x1 = x(ii);
        y1 = y(ii);
        
        hold(S.ax, 'on');
        C = S2C(marker1);
        h_marker(ii,1) = plot(S.ax, x1, y1, C{:});
    end
    hold(S.ax, 'off');
end
end