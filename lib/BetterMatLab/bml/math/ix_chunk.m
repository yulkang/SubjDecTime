function ix = ix_chunk(n, i_chunk, siz_chunk)
% ix_chunk  Give indices of i_chunk-th chunk, ix, sized siz_chunk, from 1:n.
%
% ix = ix_chunk(n, i_chunk, siz_chunk)
%
% EXAMPLE:
% ix_chunk(5, 1, 3)
% ans =
%      1     2     3
% 
% ix_chunk(5, 2, 3)
% ans =
%      4     5
     
ix_st = (i_chunk - 1) * siz_chunk + 1;
ix_en = min(i_chunk * siz_chunk, n);

ix = ix_st:ix_en;