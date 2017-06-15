function title(ax, str)
% Wrap text and replace '_' with '-' for title
%
% title(ax, str)

if ischar(ax)
    str = ax;
    ax = gca;
end

title(ax, bml.str.wrap_text(strrep(str, '_', '-')));