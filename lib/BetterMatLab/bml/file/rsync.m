function [status, result] = rsync(varargin)
% [status, result] = rsync(varargin)

if numel(varargin) > 1
    args = '';
    for ii = 1:numel(varargin)
        args = [args, ' ', varargin{ii}]; %#ok<AGROW>
    end
else
    args = varargin{1};
end
[status, result] = system(['rsync ' args]);