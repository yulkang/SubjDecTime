function h = subplot_children2struct(fig)
% Combines subplot_by_pos and figure2struct.
% h{row, col} is a struct with fields with handles to lines, etc.
%
% h = subplot_children2struct(fig)
%
% See also: subplot_by_pos, figure2struct

% Yul Kang (c) 2016. hk2699 at columbia dot edu.

if nargin < 1, fig = gcf; end

ax = bml.plot.subplot_by_pos(fig);
h = cell(size(ax));
for ii = 1:size(ax, 1)
    for jj = 1:size(ax, 2)
        try
            h{ii,jj} = bml.plot.figure2struct(ax(ii,jj));
        catch
            disp(lasterr);
        end
    end
end