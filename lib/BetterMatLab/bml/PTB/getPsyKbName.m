function [nam cod] = getPsyKbName(varargin)
% [nam cod] = getPsyKbName
%
% Press any key, then the unified alphanumeric keyboard name returned by 
% psyKbName will be displayed.
%
% Press ESC to quit.
%
% Use psyKbName('unifyToAlphaNumeric') then psyKbName(keyCode) or
% psyKbName(keyName) to use unified alphanumeric names that can be used 
% for variable names.
%
% See also: PSYKBNAME.
%
% 2013 (c) Yul Kang. hk2699 at columbia dot edu.

ListenChar(2);
psyKbName('unifyToAlphaNumeric');

n   = 0; 
nam = cell(1,10);
cod = cell(1,10);

disp('Press any key to display unified alphanumeric names');
disp('that is returned by psyKbName()');
disp('after using psyKbName(''unifyToAlphaNumeric'')');
disp('Press ESCAPE to finish.');
fprintf('\n%15s : Keycode(s)\n', 'name');
fprintf('----------------:--------------\n');
    
while n==0 || ~strcmpi(nam{n}, 'escape')
    WaitSecs(0.15);
    pressed = false;
    while ~pressed
        [pressed, ~, tfCod] = KbCheck(varargin{:});
    end
    
    n = n+1;
    nam{n} = setdiff(psyKbName(tfCod), 'NumLockClear');
    if iscell(nam{n}), nam{n} = nam{n}{1}; end
    cod{n} = find(tfCod);
    
    fprintf('%15s :', nam{n});
    fprintf(' %3d', cod{n});
    fprintf('\n');
end

nam = nam(1:n);
cod = cod(1:n);

ListenChar(0);