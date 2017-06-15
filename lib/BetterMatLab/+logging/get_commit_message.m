function [comment, all_output] = get_commit_message(in_dir)
% [comment, all_output] = get_commit_message(in_dir)
%
% See also logging, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

import Ext.git

if ~exist('in_dir', 'var'), in_dir = pwd; end

prev_dir = cd(in_dir);

all_output = git('log -1 --pretty=format:"%H %s"');
ix = find(all_output == ' ', 1, 'first');

comment_cell = line2cell(all_output((ix+1):end));
comment = comment_cell{1};

cd(prev_dir);
end