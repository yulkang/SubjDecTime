function [res, bak, S] = name_only(src, varargin)
% Same as logging.archive(..., 'keep_log', false);
%
% [res, bak, S] = name_only(src, varargin)
%
% See also: logging.archive

C = varargin2C(varargin, {
    'keep_log', false
    });

[res, bak, S] = logging.archive(src, C{:});
end