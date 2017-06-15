function [ds, count, incl] = tabulate(ds0, vars)
if isempty(ds0)
    ds = dataset;
    count = zeros(0,1);
    return;
end
assert(isa(ds0, 'dataset'));
if exist('vars', 'var')
    assert(iscell(vars) && all(cellfun(@ischar, vars(:))));
    assert(all(ismember(vars(:)', ds0.Properties.VarNames)));
else
    vars = ds0.Properties.VarNames;
end

% The first row is always included.
n_row = size(ds0, 1);
ds(n_row,:) = ds0(1, vars); % Just to preassign.
count = zeros(n_row, 1);
incl = cell(n_row, 1);

n_unique = 1;
count(1) = 1;
incl{1} = 1;
ds(1,:) = ds0(1, vars);

for row = 2:n_row
    is_unique = true;
    for i_unique = 1:n_unique
        if isequal(ds(i_unique, :), ds0(row, vars))
            is_unique = false;
            count(i_unique) = count(i_unique) + 1;
            incl{i_unique}(end + 1) = row;
            break;
        end
    end
    if is_unique
        n_unique = n_unique + 1;
        ds(n_unique, :) = ds0(row, vars);
        count(n_unique) = 1;
        incl{n_unique} = row;
    end
end

ds = ds(1:n_unique, :);
count = count(1:n_unique, 1);
incl = incl(1:n_unique, 1);

ds.count_tabulate = count;
ds.incl_tabulate = incl;

