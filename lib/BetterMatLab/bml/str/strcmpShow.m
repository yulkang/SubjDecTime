function [anyDiff missing added moved] = strcmpShow(str1, str2, verbose)
% [anyDiff missing added moved] = strcmpShow(str1, str2, [verbose = false])

if ~exist('verbose', 'var'), verbose = true; end

anyDiff = false;

% Moved
anyMoved = false;
moved = strcmpfinds(str2, str1);

for ii = find(~isnan(moved))
    if moved(ii)~=ii
        if ~anyMoved
            if verbose
                fprintf('Moved:\n');
            end
            anyMoved = true;
            anyDiff  = true;
        end
        if verbose
            fprintf('%s from %d to %d\n', str2{ii}, moved(ii), ii);
        end
    end
end
if anyMoved && verbose
    fprintf('\n');
end

% Added
added = setdiff(str2, str1);
if ~isempty(added)
    anyDiff = true;
    
    if verbose
        fprintf('Added:\n');
        cellfprintf('%s\n', added);
    end
end

% Missing
missing = setdiff(str1, str2);
if ~isempty(missing)
    anyDiff = true;
    
    if verbose
        fprintf('Missing:\n');
        cellfprintf('%s\n', missing);
    end
end

