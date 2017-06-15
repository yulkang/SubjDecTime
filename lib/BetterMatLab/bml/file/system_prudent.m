function [res, status, cmd] = system_prudent(cmd, varargin)
% [res, status, cmd] = system_prudent(cmd, varargin)
%
% OPTIONS:
%     'confirm',  true
%     'cmd_only', false
%     'echo',     true

% Set options
S = varargin2S(varargin, {
    'confirm',  true
    'cmd_only', false
    'echo',     true
    });

if S.echo
    C_echo = {'-echo'};
else
    C_echo = {};
end

if ischar(cmd), cmd = {cmd}; end

% Initialize output
n   = length(cmd);
res = cell(1, n);
status = zeros(1, n);

% Preview commands
fprintf('%s\n\n', cmd{:});

% Execute
if ~S.cmd_only
    if S.confirm
        yn = inputYN_def('Execute the commands using system ', true);
        if ~yn
            fprintf('Copy by clicking:\n');
            fprintf('0. '); disp2copy(['cd ' pwd]);
            for ii = 1:n
                fprintf('%d. ', ii); 
                disp2copy(strrep(cmd{ii}, '''', ''''''));
            end
            return; 
        end
    end
    
    for i_cmd = 1:n
        [status(i_cmd), res{i_cmd}] = system(cmd{i_cmd}, C_echo{:});
    end    
end
