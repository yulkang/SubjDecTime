function s = dprintf(fids, varargin)
% DPRINTF - Print to multiple fids. Includes 1 by default.
%
% Include 1 for standard output, and 2 for standard error.
%
% See also fprintf

if ~any(fids == 1), fids = [fids(:)', 1]; end

for fid = fids(:)'
    fprintf(fid, varargin{:});
end
if nargout > 0
    s = sprintf(varargin{:}); 
end