function h_ax = gltitle(h_ax0, op, t, varargin)
% Column and row titles.
% Makes a new axes that encompasses the combined areas of h_ax0,
% and adds a title to the new axes.
%
% h_ax = gltitle(h, op, t, varargin)
%
% h_ax0 : Array of axes
% op    : 'all', 'row', 'col'
% t     : Title. In case of 'all', a string. In case of 'row' or 'col', a cell array of strings.
% shift : [xshift, yshift] or [xshift, yshift, zshift].
%   Defaults to [0, 0].
%   Use bml.plot.position_subplots instead of specifying shift
%   for flexible positioning.
%   If nonzero shift is used, [0.05, -0.05] is often reasonable.
%         Use bml.plot.position_subplots first for flexible positioning.
% title_args : arguments fed to title().

% 2016-2017 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    ... % shift : [xshift, yshift] or [xshift, yshift, zshift].
    ... %   Defaults to [0, 0].
    ... %   Use bml.plot.position_subplots instead of specifying shift
    ... %   for flexible positioning.
    ... %   If nonzero shift is used, [0.05, -0.05] is often reasonable.
    'shift', [0, 0] 
    'title_args', {}
    });

if ~isempty(S.shift)
    shiftpos(h_ax0, S.shift);
end
if ischar(t), t = {t}; end
        
fntsiz = get(0, 'DefaultTextFontSize');

switch op
    case 'all'
        C = varargin2C(S.title_args, {
            'FontSize',     fntsiz + 8
            'Position',     [0.5, 1.06, 0.5]
            });
        
        h_ax = glaxes(h_ax0, 'title', t, C{:});
        
    case 'row'
        n = size(h_ax0, 1);
        if verLessThan('matlab', '8.4')
            h_ax = zeros(1, n);
        else
            h_ax = gobjects(1, n);
        end
        
        C = varargin2C(S.title_args, {
            'FontSize',             fntsiz + 5
            'HorizontalAlignment',  'right'
            'VerticalAlignment',    'middle'
            'Position',             [-0.15, 0.5, 0]
            'FontWeight',           'bold'
            'Rotation',             0
            });
        
        for ii = 1:n
            h_ax(ii) = glaxes(h_ax0(ii,:), 'ylabel', t{ii}, C{:});
        end
        
    case 'col'
        n = size(h_ax0, 2);
        if verLessThan('matlab', '8.4')
            h_ax = zeros(1, n);
        else
            h_ax = gobjects(1, n);
        end
        
        C = varargin2C(S.title_args, {
            'FontSize',             fntsiz + 5
            'HorizontalAlignment',  'center'
            'Position',             [0.5 1.01, 0]
            });
        
        for ii = 1:n
            h_ax(ii) = glaxes(h_ax0(:,ii), 'title', t{ii}, C{:});
        end
end