function str = showdoc(item, indent)

% function str = showdoc(item, indent)
% Display help text for a cfg_branch and all of its children.
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id$

rev = '$Rev$'; %#ok

str = showmydoc(item, indent);
str{end+1} = '';
% Display detailed help for each branch item
citems = subsref(item, substruct('.','val'));
for k = 1:numel(citems)
    str1 = showdoc(citems{k}, sprintf('%s%d.', indent, k));
    str = {str{:} str1{:}};
    str{end+1} = '';
end;