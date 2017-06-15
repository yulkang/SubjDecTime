function tf = test_shuffle_wi_group(tr0, group0)
% Returns true if shuffle_wi_group preserves the number of trials 
% within each group.
%
% See also : test_shuffle_wi_group

if ~exist('tr0', 'var')
    tr0 = [1 1 2 3 4 5 6 7]';
end
if ~exist('group0', 'var')
    group0 = [1 1 1 1 2 2 2 2]';
end

tr = bml.stat.shuffle_wi_group(tr0, group0);

disp([group0, tr0, tr]);

n_in_group0 = accumarray([tr0, group0], 1, [], @sum);
n_in_group1 = accumarray([tr, group0], 1, [], @sum);

disp(n_in_group0);
disp(n_in_group1);

tf = isequal(n_in_group0, n_in_group1);

disp(tf);
end
