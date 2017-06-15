function txt = last_history(varargin)
% txt = last_history(...)
%
% OPTIONS:
% 'max_byte', 5000
% 'max_line', 1000
% 'verbose',  true
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'max_byte', 5000
    'max_line', 1000
    'verbose',  true
    });

file = fullfile(prefdir, 'history.m');
fid = fopen(file, 'r');
try
    fseek(fid, S.max_byte, 'eof');
catch
    fseek(fid, 0, 'bof');
end

c_line = '';
n_line = 0;
txt    = cell(1,100);

while ~isequal(c_line, -1)
    c_line = fgetl(fid);
    n_line = n_line + 1;
    txt{n_line} = c_line;
end
n_line = n_line - 1;
txt      = txt(max(1, n_line - S.max_line + 1):n_line);

fclose(fid);

if S.verbose
    disp('==========');
    disp('History');
    disp('==========');
    cfprintf('%s\n', txt);
    disp('==========');
end