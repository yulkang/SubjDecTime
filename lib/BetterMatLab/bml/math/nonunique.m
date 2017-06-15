function [ix v ixUnique vUnique] = nonunique(a, cellIx)
% NONUNIQUE     Search for duplicate values and their locations efficiently.
%
% [ix v] = nonunique(a, [cellIx=true])
% 
% a must be a numerical vector. Complexity is O(n*log(n)), rather than O(n^2).
%
% Example 1:
% >> a = [3 2 1 3 3 2 4];
%
% >> [ix v] = nonunique(a, false)
% ix =
%      2     1     4     % a(6) == a(2), and so on.
%      6     4     5     % Here, ix only shows pairs. 
% v =
%      2     3     3     % There are still duplicate values.
%
% Example 2:
% [ix v] = nonunique(a)
% ix = 
%     [2 6]    [1 4 5]   % all(a([1 4 5]) == 3).
%                        % Now that ix is a cell array,
%                        % we get a complete list for each unique v.
% v =
%      2     3           % Now every element of v is unique.
%
% See also: UNIQUE, SORT.
%
% by HR Kang, 2013.

if ~exist('cellIx', 'var'), cellIx = true; end

[sortA sortIx] = sort(a);
dSortA = [false (diff(sortA) == 0)];

if nargout >= 3, ixUnique = sortIx(find(~dSortA)); end
if nargout >= 4, vUnique  = a(ixUnique); end

if cellIx
    
    ixSt   = find(diff(dSortA) == 1);
    ixEn   = find(diff(dSortA) == -1);
    
    v      = sortA(ixSt);
    
    nV     = length(v);
    ix     = cell(1,nV);
    
    for ii = 1:nV
        ix{ii} = sortIx(ixSt(ii):ixEn(ii));
    end
    
else
    v  = sortA(dSortA);

    ix = [sortIx(find(dSortA)-1); sortIx(dSortA)];
end