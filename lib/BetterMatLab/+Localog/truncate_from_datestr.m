function f = truncate_from_datestr(f)
% Truncate from Localog.datefmt, saving file extension.
%
% f = truncate_from_datestr(f)

n = numel(f);
%%
ex = '_[12][90][0-9][0-9][01][0-9][0-3][0-9]T[0-2][0-9][0-6][0-9][0-6][0-9]\.[0-9]{3}';
%%
for ii = 1:n
    [p, n, e] = fileparts(f{ii});
    
    st = regexp(n, ex, 'start', 'once');
    
    if ~isempty(st)
    	f{ii} = fullfile(p, [n(1:(st-1)), e]);
    end
end
end