function [h, S_ui] = uitext(txt, subplot_vec, uicontrol_opt, varargin)
% [h, S_ui] = uitext(txt, subplot_vec, uicontrol_opt, varargin)
%
% txt: String or cell array of strings.
%
% subplot_vec: {nR, nC, r, c}.  See subplotRC.
%
% uicontrol_opt:
% Name                   Default
% ------------------------------
% 'Style',               'text', ...
% 'String',              txt, ...
% 'HorizontalAlignment', 'left', ...
% 'Tag',                 ''
%
% If tag is nonempty and there exists a uitext with the tag, update its
% content rather than creating a new one.
%
% 2013 (c) Yul Kang. hk2699 at columbia dot edu.

txt = arg2cell(txt);

if ~exist('uicontrol_opt', 'var'), uicontrol_opt = {}; end
S_ui = varargin2S(uicontrol_opt, { ...
    'Style',    'text', ...
    'String',   txt, ...
    'HorizontalAlignment', 'left', ...
    'Tag',      '', ...
    });

% If uitext with the given tag exists,
if ~isempty(S_ui.Tag)
    h = findobj('Tag', S_ui.Tag, 'Style', 'text');
    
    if ~isempty(h)
        % Simply set its properties.
        C_ui = S2C(S_ui);
        set(h, C_ui{:});
        return;
    end
end

% If no uitext exists, create one.
if ~isempty(subplot_vec)
    [pos, units] = subplotRC(subplot_vec{1}, subplot_vec{2}, subplot_vec{3}, subplot_vec{4}, ...
        'pos_only', true);

    S_ui.Units    = units;
    S_ui.Position = pos;
end

C_ui = S2C(S_ui);
h = uicontrol(C_ui{:});