function src = set_sub_struct(src, sub, prefix)
% src = set_sub_struct(src, sub, prefix)
%
% See also: get_sub_struct
%
% 2015 (c) Yul Kang.
assert(isstruct(src));
assert(isstruct(sub));
assert(ischar(prefix));

fs = fieldnames(sub)';
for f = fs
    src.([prefix f{1}]) = sub.(f{1});
end
return;

%% Test
src = struct; %#ok<UNRCH>
sub_targ = varargin2S({'a', 3, 'b', 4});
src = set_sub_struct(src, varargin2S({'a', 1, 'b', 2}), 'test__');
src = set_sub_struct(src, sub_targ, 'test2__');
sub = get_sub_struct(src, 'test2__');
disp(sub);
passed = isequal(sub, sub_targ);
fprintf('Passed: %d\n', passed);
assert(passed);