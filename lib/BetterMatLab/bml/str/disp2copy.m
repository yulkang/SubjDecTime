function disp2copy(cmd, msg)
% Display a link to copy the command.
%
% disp2copy(cmd, msg)
if nargin < 2
    msg = cmd; 
end
disp(cmd2link(['clipboard(''copy'', ''', cmd, ''')'], msg));
end