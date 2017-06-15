function [c, varargout] = varargin2C_pos(varCell, defaults_named, defaults_pos, ...
    varargin)
% [C_named, varargout_positional] ...
% = varargin2C_pos(varCell, defaults_named, defaults_pos, ...)
%
% OPTIONS:
%     'n_pos', []

opt = varargin2S(varargin, {
    'n_pos', []
    });

if nargin < 2, defaults_named = {}; end
if nargin < 3, defaults_pos = {}; end

if isempty(opt.n_pos)
    opt.n_pos = numel(defaults_pos);
end

if nargout >= 2
    n_pos_in = min(opt.n_pos, numel(varCell));
    
    [varargout{1:(nargout-1)}] = dealDef(varCell(1:n_pos_in), ...
        defaults_pos);
end
c = varargin2C(varCell((opt.n_pos + 1):end), defaults_named);
