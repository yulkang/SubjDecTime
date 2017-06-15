function a = beautify_axis(xy, varargin)
% a = beautify_axis(xy, varargin)
%
% xy : 'X' or 'Y'
%
% 'dtick', 0.5
% 'dtickminor', 0.1
% 'ticklen', 0.015
% 'max_tick', []
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'ax', []
    'dtick', 0.5
    'dtickminor', 0.1
    'ticklen', 0.015
    'max_tick', []
    });

xy = upper(xy);
if isempty(S.ax)
    S.ax = gca;
end

a = S.ax.([xy 'Axis']);

if isempty(S.max_tick)
    S.max_tick = a.Limits(2);
end

a.TickValues = 0:S.dtick:S.max_tick;
a.MinorTick = 'on';
a.MinorTickValues = 0:S.dtickminor:S.max_tick;
a.TickDirection = 'out';
a.TickLength = [0 0] + S.ticklen;
end