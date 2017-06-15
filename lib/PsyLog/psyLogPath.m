function pth = psyLogPath(sub, addToPath)
% PSYLOGPATH    Returns path relative to PsyLog's path.
%
% pth = psyLogPath(sub, [addToPath = 0])
%
% addToPath: 1 to add, 0 to leave, -1 to remove.

if nargin < 1 || isempty(sub)
    sub = '';
% elseif iscell(sub)
%     subs = sub;
% elseif ischar(sub)
%     subs = {sub};
% else
%     error('First arg should be empty or char!'); % , char, or cell array!');
end
    
if nargin < 2, addToPath = 0; end

pth = fullfile(fileparts(mfilename('fullpath')), sub);

switch addToPath
    case 1
        addpath(pth);
        
    case -1
        rmpath(pth);
end
end