function bat = bat2batmat(bat)
% Convert struct or {{bat1, ...}, {bat2, ...}} into {bat1, ...; bat2, ...} form.
% If already the latter form ("cell matrix form"), leave unchanged.
%
% bat = bat2batmat(bat)
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

if isstruct(bat) 
    % If struct form, where the field name is the first entry and 
    % field contents are cell vectors of the same length for arguments,
    bat = S2C(bat);
    bat = cellfun(@(a,b) [{a}, b], bat(1:2:end), bat(2:2:end), 'UniformOutput', false);
    bat = bat2batmat(bat);
    
elseif iscell(bat{1}) % If {{bat1}, {bat2}, ...} form
    bat = bat(:);
    n   = length(bat);
    len = cellfun(@length, bat);
    
    for ii = 1:n
        bat(ii, 1:len(ii)) = bat{ii,1};
    end
end % If {bat1; bat2; ...} for already, leave unchanged.