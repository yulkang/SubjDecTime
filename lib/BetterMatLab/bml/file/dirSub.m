function c = dirSub(d, excl, add_d, varargin)
% c = dirSub(d, excl, add_d, varargin)
% 
% Recursively finds all subdirectories of d, excluding those starts with '.'.
%
% See also: dirCell, dir

if nargin<1, d = cd; end
if nargin<2, excl = {'^\..*', '^svn'}; end
if nargin<3, add_d = true; end

% Get top-level items from d.
D = dir(d);

% Leave directories only.
c = {D([D.isdir]).name}';

% Exclude those starts with exclusion pattern.
c = c(cellfun(@(s) ~any(regexps(s, excl)), c));

% Attach d in front of each.
c = cellfun(@(s) fullfile(d, s), c, 'UniformOutput', false);

% Add recursively.
n = length(c);
for ii = 1:n
    c = [c; dirSub(c{ii}, excl, false)]; %#ok<AGROW>
end

% Add d on top, if it doesn't start with the exclusion charater.
if d(end)==filesep, d = d(1:(end-1)); end
[~, dName] = fileparts(d);
if add_d && ~any(regexps(dName, excl)), c = [{d}; c]; end