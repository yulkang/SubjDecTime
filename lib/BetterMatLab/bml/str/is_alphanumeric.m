function tf = is_alphanumeric(c)
% Returns true if each character is alphanumeric or underscore.
% tf = is_alphanumeric(c)
tf = ismember(c, ['a':'z', 'A':'Z', '0':'9', '_']);