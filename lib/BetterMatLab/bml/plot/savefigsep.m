function savefigsep(fig, files, RC)
% Save children axes of fig as separate .fig files
%
% savefigsep(fig, files, [RC])
%
% RC: [nR, nC]

persistent f

h       = findobj(fig, 'Type', 'axes');

if ~isvalidhandle(f)
    f   = fig_tag('imsepsave_');
end
figure(f);

% Delete existing axes, so that only one axes is saved per file.
delete(findobj(f, 'Type', 'Axes'));

if ischar(files)
    [pth, fnam, ext] = fileparts(files);
    
    if nargin < 3 || isempty(RC), RC = size(h); end
    
    files = cell(RC);
    for r = 1:RC(1)
        for c = 1:RC(2)
            files{r,c} = fullfile(pth, sprintf('%s_%d_%d%s', fnam, r, c, ext));
        end
    end
end

ch       = ghandles;

for ii = 1:numel(files)
    ch(ii) = copyobj(h(ii), f);
    set(ch(ii), 'Position', [0.05 0.05 0.9 0.9]);
    
    savefig(f, files{ii});
    
    fprintf('Saved in %s\n', files{ii});
    
    delete(ch(ii));
end
delete(f);
