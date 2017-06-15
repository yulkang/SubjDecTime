function drawAxes(xy, varargin)
% DRAWAXES Draws x and y axes.
% 
% drawAxes(xy, ...)
%
% xy: 'x', 'y', or 'xy' (default)
% 
% See also CROSSLINE.

if ~exist('xy', 'var'), xy = 'xy'; end;
if isempty(varargin), varargin = {'k-', 'LineWidth', 0.5}; end

if any(xy=='x')
    h1 = crossLine('h', 0, varargin);
else
    h1 = [];
end
if any(xy=='y')
    h2 = crossLine('v', 0, varargin);
else
    h2 = [];
end

%% Reorder so that the axes are at the bottom.
reorder([h1 h2], 'bottom');