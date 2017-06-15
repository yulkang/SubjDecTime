function str = remove_trailing_whitespace(str)
% remove_trailing_whitespace  remove any final character <= ASCII 13.
%
% It will remove \t, \r, and \n, but preserve ' '.
% Useful for postprocessing outputs from system().
%
% See also system

while ~isempty(str) && str(end) <= 13
    str = str(1:(end-1));
end
