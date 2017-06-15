% Script form for ws2base. Works even in debug mode on an arbitrary stack level.
%
% Set S_ws2base2_ = 'struct_name' like an argument. The default is 'ws'.
%
% See also ws2base3
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

% try
    % To avoid restriction in adding variables to a static workspace
    global S_ws2base2_ ws_ws2base2_ v_ws2base2_ 

    ws_ws2base2_ = struct;
    fprintf('Copied');
    for v_ws2base2_ = setdiff(who', {'S_ws2base2_', 'ws_ws2base2_', 'v_ws2base2_'})
        ws_ws2base2_.(v_ws2base2_{1}) = eval(v_ws2base2_{1});
        fprintf(' %s', v_ws2base2_{1});
    end
    fprintf('\n');

    if isempty(S_ws2base2_)
        S_ws2base2_ = 'ws';
    end

    assignin('base', S_ws2base2_, ws_ws2base2_);
    fprintf('Copied the current workspace into a struct ws in base.\n');

    clear S_ws2base2_ ws_ws2base2_ v_ws2base2_
% catch
%     assignin('base', 'ws', ws2s);
% end