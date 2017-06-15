function tf = inputYN(msg, varargin)
% tf = inputYN(msg, sprintf_args)
%
% See also inputYN_def, misc, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

if nargin < 1, msg = ''; end
if ~isempty(varargin)
    msg = sprintf(msg, varargin{:});
end

resp = input(msg, 's');

while ~strcmpi(resp, 'y') && ~strcmpi(resp, 'n')
    resp = input(msg, 's');
end

tf = strcmpi(resp, 'y');