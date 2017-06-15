function copied = fig2subplot(src, dst, varargin)
% Moves an axes to replace another one.
%
% copied = fig2subplot(src, dst, ...)
%
% src : a .fig file name or a handle of a figure or an axes,
%       or a cell array of them.
% dst : a handle of an axes or a cell array of them.
%
% copied : the handle of the copied axes.
%
% OPTIONS:
% 'delete_src', true
% 'delete_dst', true
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'delete_src', true
    'delete_dst', true
    });

% Process cell inputs
if iscell(src)
    assert(isequal(size(src), size(dst)));
    if isscalar(src)
        src = src{1};
    else    
        copied = cellfun(@bml.plot.fig2subplot, src, dst);
        return;
    end
end
% Process non-cell inputs
if ischar(src)
    src = openfig(src, 'new', 'invisible');
end
% Process handle inputs
assert(ishandle(src));
if strcmpi(get(src, 'Type'), 'figure')
    src = findobj(src, 'Type', 'axes');
    assert(isscalar(src), 'The figure must contain a single axes!');
end
% Process axes inputs
assert(strcmpi(get(src, 'Type'), 'axes'));
assert(isscalar(src));

assert(strcmpi(get(dst, 'Type'), 'axes'));
assert(isscalar(dst));

% Copy
dst_fig = get(dst, 'Parent');
copied = copyobj(src, dst_fig);

% Position
dst_siz = get(dst, 'Position');
if S.delete_dst
    delete(dst);
end
set(copied, 'Position', dst_siz);

% Delete src
if S.delete_src
    src_fig = get(src, 'Parent');
    if isscalar(findobj(src_fig, 'Type', 'axes'))
        delete(get(src, 'Parent'));    
    else
        delete(src);
    end
end