function v = pad(v, width, varargin)
% v = pad(v, width, varargin)
% 
% OPTIONS:
% 'dim', 2
% 'pad_with', nan
% 
% EXAMPLE:
% >> bml.array.pad(1:3, 5)
% ans =
%      1     2     3   NaN   NaN
% 
% >> bml.array.pad(1:3, 2)
% ans =
%      1     2
% 
% >> bml.array.pad(1:3, 4, 'dim', 1)
% ans =
%      1     2     3
%    NaN   NaN   NaN
%    NaN   NaN   NaN
%    NaN   NaN   NaN
% 
% >> bml.array.pad(magic(3), 2, 'dim', 1)
% ans =
%      8     1     6
%      3     5     7
% 
% >> bml.array.pad(magic(2), 3, 'dim', 1, 'pad_with', 100)
% ans =
%      1     3
%      4     2
%    100   100
   
% 2017 (c) Yul Kang. hk2699 at columbia dot edu.
   
S = varargin2S(varargin, {
    'dim', 2
    'pad_with', nan
    });
siz = size(v);
siz_dim = siz(S.dim);

if siz_dim > width
    n_dim = length(siz);
    siz2 = cell(1, n_dim);
    for ii = 1:n_dim
        if ii == S.dim
            siz2{ii} = 1:width;
        else
            siz2{ii} = ':';
        end
    end
    v = v(siz2{:});
    
elseif siz_dim < width
    siz2 = siz;
    siz2(S.dim) = width - siz_dim;
    v2 = zeros(siz2) + S.pad_with;
    
    v = cat(S.dim, v, v2);
end