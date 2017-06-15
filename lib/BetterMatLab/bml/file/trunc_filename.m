function file = trunc_filename(file, len)
% Truncates file name so that the full path is LEN at maximum.
%
% file = trunc_filename(file, len=230)
%
% Mac OS X : 255 characters max for the file name. Perhaps 1016 for the full path.
% - http://stackoverflow.com/questions/7140575/mac-os-x-lion-what-is-the-max-path-length
% Windows 7: 260 characters max for the full path.
% - http://windows.microsoft.com/en-us/windows/file-names-extensions-faq#1TC=windows-7
%
% LEN is 230 by default to safeguard against the cases when the file is
% copied to a longer path, etc.

if nargin < 2, len = 230; end

c_len = length(file);

if c_len > len
    file_orig = file;
    
    % Separate parts
    [pth, nam, ext] = fileparts(file);
    
    % Truncate name part
    nam = nam(1:(length(nam) - (c_len - len)));
    
    % Recombine parts
    file = fullfile(pth, [nam, ext]);
    
    % Show messages
    warning('Truncated file name to keep full path below %d characters:\n %s \nto\n %s', ...
        len, file_orig, file);
    
    if isempty(nam)
        warning('The path is too long, so when truncated for safety, there''s no file name left from: %s', ...
            file_orig);
    end
end


