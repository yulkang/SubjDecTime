function list = links2list(from)
% list = links2list(from)
%
% Extract '.tags' from a linked list of objects with a field '.next'
% into a cell array, until .next is empty.

list = {};

while ~isempty(from.next)
    list{end+1} = from.tag; %#ok<AGROW>
    from = from.next;
end
end