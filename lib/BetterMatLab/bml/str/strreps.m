function res = strreps(src, fromS, toS)
% Runs strrep sequentially for each cell of fromS.
% When fromS is a string rather than a cell array, same as strrep.
%
% res = strreps(src, fromS, toS)
%
% EXAMPLES:
%
% >> strreps('abcce', {'bc', 'Cc'}, 'BC')
% ans =
% aBBCe
%
% >> strreps({'abcce', 'bcdef'}, {'bc', 'Cc'}, 'BC')
% ans = 
%     'aBBCe'    'BCdef'
%
% See also: STRREP, STRREP_CELL

if iscell(fromS)
    res = src;
    
    for ii = 1:numel(fromS)
        res = strrep(res, fromS{ii}, toS);
    end
else
    res = strrep(src, fromS, toS);
end