function res = userpth
% USERPTH - Returns userpath without the pathsep character at the end.
%
% See also USERPATH

res = userpath;
res = res(1:(find(res == pathsep, 1, 'first')-1));