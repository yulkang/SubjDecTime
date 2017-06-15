classdef FitWorkspace6 < matlab.mixin.Copyable
properties
    Params = FitParams;
end
methods
%% Parameter interface with Fl
function v = get_struct_all(W, kind)
    if nargin < 2 || isempty(kind), kind = 'th'; end
    v = W.Params.get_struct_all(kind);
end
function set_struct_all(W, v, kind, field)
    if nargin < 3 || isempty(kind), kind = 'th'; end
    if nargin >= 4 && ~isempty(field)
        S = W.get_struct_all(kind);
        S.(field) = v;
        W.set_struct_all(S, kind);
    else
        W.Params.set_struct_all(v, kind);
    end
end
function v = get_vec_all(W, kind)
    if nargin < 2 || isempty(kind), kind = 'th'; end
    v = W.Params.get_vec_all(kind);
end
function set_vec_all(W, v, kind)
    if nargin < 3 || isempty(kind), kind = 'th'; end
    v = W.Params.set_vec_all(v, kind);
end

%%
function init_th(W)
    W.Params.set_struct_all(W.Params.get_struct_all('th0'), 'th');
end
function th2Params(W)
    W.Params.set_struct_all(Fl.th);
end
function th_vec2Params(W, v)
    W.Params.set_vec(v);
end
function Params2th(W, Fl)
    Fl.th = W.Params.get_struct_all;
    Fl.constr = W.Params.get_cond_cell_all;
end
function Params2W(W, Params)
    if nargin < 2
        Params = W.Params;
    end
    th = Params.get_struct; % Not struct_all - only direct properties.
    copyFields(W, th);
end

%% Interface for fitting steps with Fl
function [W, Fl] = init_bef_fit(W, Fl, varargin)
    % [W, Fl] = init_bef_fit(W, Fl, varargin)
    % Initialize W itself
    % Add Params and Constr to Fl.
end
function [c, W, Fl] = pred(W, Fl, varargin)
    % [c, W, Fl] = pred(W, Fl, varargin)
    % Doesn't involve v, unlike get_cost
    % Subclasses need to modify only this, leaving get_cost alone.
    c = nan;
end
function [c, W, Fl] = get_cost(W, v, Fl, varargin)
    W.Params.set_vec(v);
    [c, W, Fl] = pred(W, Fl, varargin{:});
end
function W = load_data(W, varargin)
    error('Not implemented yet! Modify in the subclass.');
end

%% Copy
function W2 = deep_copy(W)
    W2 = copy(W);
    W2.Params = deep_copy(W.Params);
end
end
end