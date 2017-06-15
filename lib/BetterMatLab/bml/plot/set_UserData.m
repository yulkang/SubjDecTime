function set_UserData(h, field, v)
% set_UserData(h, field, v)

S = get(h, 'UserData');
if ~isstruct(S)
    if ~isempty(S)
        warning('Non-struct UserData was overwritten!');
    end
    S = struct; 
end
S.(field) = v;
set(h, 'UserData', S);
