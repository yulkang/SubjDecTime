function ix = ix_wrap(st, n, tot)
% ix = ix_wrap(st, n, tot)
%
% >> ix_wrap(8,5,10)
% ans =
%      8     9    10     1     2

ix = mod((st:(st+n-1)) - 1, tot) + 1;