function [str, pos_all] = str_replace_at(str, pos, len, dst, pos_all)
% [str, pos_all] = str_replace_at(str, pos, len, dst, pos_all)
assert(isrow(str));

str_head = str(1:(pos - 1));
str_tail = str((pos + len):end);
str = [str_head, dst, str_tail];

pos_changed = pos_all > pos;
pos_all(pos_changed) = pos_all(pos_changed) - len + length(dst);
end