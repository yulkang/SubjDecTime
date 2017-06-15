function cl = get_class_rel(obj, suffix, varargin)
% cl = get_class_rel(obj, suffix, varargin)
%
% OPTIONS:
% ...
% ... % 'rel_level' 
% ... % How many 'words' to remove from the last.
% 'rel_level', -1
% ...
% ... % 'add_period'
% ... % Adds a period in front of the suffix.
% ... % Set false to modify existing name
% 'add_period', true 
%
% EXAMPLE:
% >> cl = bml.pkg.get_class_rel(Fit.D2.Bounded.Main, 'Plot')
% cl =
% Fit.D2.Bounded.Plot
%
% >> cl = bml.pkg.get_class_rel(Fit.D2.Bounded.Main, 'Plot', 'rel_level', -2)
% % Removes two words from the last: 'Bounded.Main', then adds
% cl =
% Fit.D2.RT.Plot
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    ...
    ... % 'rel_level' 
    ... % How many 'words' to remove from the last.
    'rel_level', -1
    ...
    ... % 'add_period'
    ... % Adds a period in front of the suffix.
    ... % Set false to modify existing name
    'add_period', true 
    });

if ischar(obj)
    cl0 = obj;
else
    cl0 = class(obj);
end

if ~exist('suffix', 'var')
    suffix = '';
end
if S.add_period
    suffix = ['.' suffix];
end

assert(S.rel_level <= 0);

pkg = get_pkg_by_level(cl0, S.rel_level, 'first');
cl = [pkg suffix];