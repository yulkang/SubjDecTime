function [git_hash, all_output] = get_hash(in_dir_src)
% GET_HASH  Return Git hash.
%
% [git_hash, all_output] = get_hash(in_dir)
%
% See also logging, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

import Ext.git

prev_dir = pwd;
if nargin == 0, in_dir_src = pwd; end

% Enforce input into a cell
in_dir = arg2cell(in_dir_src);

git_hash   = cell(1,length(in_dir));
all_output = cell(1,length(in_dir));

for ii = 1:length(in_dir)
    cd(in_dir{ii});

    all_output{ii} = git('log -1 --pretty=format:"%H %s"');
    git_hash{ii}   = all_output{ii}(1:(find(all_output{ii}==' ', 1, 'first')-1));

    if strcmp(git_hash{ii}, 'fatal:'), git_hash{ii} = ''; end

    cd(prev_dir);
end

% Output type matches input type
[git_hash, all_output] = cell2arg(iscell(in_dir_src), git_hash, all_output);
