function ds = rename_column(ds, src, dst, varargin)
% ds = rename_column(ds, src, dst, varargin)
%
% USAGE:
% ds = rename_column(ds, 'src', 'dst')
% ds = rename_column(ds, {
%     'src1', 'dst1'
%     'src2', 'dst2'
%     })
%
% OPTIONS:
% 'skip_absent', false

% 2016 Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'skip_absent', false
    });

if iscell(src)
    assert(size(src, 2) == 2);
    n = size(src, 1);
    dst = src(:,2);
    src = src(:,1);
    for ii = 1:n
        ds = bml.ds.rename_column(ds, src{ii}, dst{ii});
    end
    return;
else
    assert(ischar(src));
    assert(ischar(dst));
end

ix = find(strcmp(ds.Properties.VarNames, src));
if isempty(ix) 
    if S.skip_absent
        return;
    else
        error('Column absent: %s\n', src);
    end
else
    assert(isscalar(ix));
end

ds.Properties.VarNames{ix} = dst;