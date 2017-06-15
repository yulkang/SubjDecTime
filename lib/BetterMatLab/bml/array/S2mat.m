function m = S2mat(S, f)
% S2mat: Concatenates vector in a struct vector into a S x v matrix.
%
% m = S2mat(S, f)
%
% Example:
%
% >> aa(1).b = [1 2 3];
% >> aa(2).b = [1 2 3]+10;
% >> S2mat(aa, 'b')
% ans = 
%      1     2     3
%     11    12    13

if size(S(1).(f),1) > size(S(1).(f),2)
    m = cell2mat({S.(f)})';
else
    m = cell2mat({S.(f)}');
end