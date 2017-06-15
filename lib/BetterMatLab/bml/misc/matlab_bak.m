function varargout = matlab_bak(op, name, pth)
% Backs up and restores matlab environment

c_env_file = fullfile(prefdir, 'MATLABDesktop.xml');
p_env_file = fullfile(prefdir, 'MATLABDesktop.xml.prev');

if ~exist('name', 'var')
    name = datestr(now, 'yyyymmddTHHMMSS');
end
if ~exist('pth', 'var')
    pth = cd;
end

switch op
    case 'backup'
        src = c_env_file;
        dst = env_file(pth, name);
        
    case 'backup_prev'
        src = p_env_file;
        dst = env_file(pth, name);
        
    case 'restore'
        copyfile_msg(c_env_file, p_env_file);
        src = env_file(pth, name);
        dst = c_env_file;
end
copyfile_msg(src, dst);

if nargout>=1, varargout{1} = src; end
if nargout>=2, varargout{2} = dst; end
        
function f = env_file(p, n)
    f = fullfile(p, sprintf('MATLABDesktop_%s.xml', n));
end
end