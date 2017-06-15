function pth = genpath2(d)
% pth = genpath2(d)

if nargin < 1 || isempty(d), d = pwd; end

pth = rdirnam(fullfile(d, '**', '*'), @validpath);
pth = sprintf('%s:', d, pth{:});
