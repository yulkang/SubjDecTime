function res = save_filt(res_who, excl)
% res = save_filt(res_who, excl=char_or_cellstr)
%
% EXAMPLE 1:
% save_list = save_filt(who, {'A'});
% save('test.mat', save_list{:});
%
% EXAMPLE 2:
% save_list = save_filt(who, {'A*', 'B'});
% save('test.mat', save_list{:});

if isstruct(res_who), res_who = {res_who.name}; end
if ischar(excl), excl = {excl}; end
assert(iscell(excl), 'class(excl) should be char or cell!');

excl = excl(:)';

for ii = 1:length(excl)
    if excl{ii}(end) == '*'
        excl = [excl, res_who(strcmpFirst(excl{ii}(1:(end-1)), res_who))]; %#ok<AGROW>
    end
end

res = setdiff(res_who, excl);