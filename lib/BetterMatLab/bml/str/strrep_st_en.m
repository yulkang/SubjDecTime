function [str, pos_all] = strrep_st_en(str, st, en, dst, pos_all)
% [str, pos_all] = strrep_st_en(str, st, en, dst, pos_all)
assert(isrow(str));

str_head = str(1:(st - 1));
str_tail = str((en + 1):end);
str = [str_head, dst, str_tail];

len_src = en - st + 1;
len_dst = length(dst);

if nargin >= 5
    assert(length(unique(pos_all)) == length(pos_all));
    % NOTE: When len_src == 1, pos_all that equals st does not change.
    %       Use only when pos_all is all unique.
    pos_changed = pos_all > st;
    pos_all(pos_changed) = pos_all(pos_changed) - len_src + len_dst;
end
end