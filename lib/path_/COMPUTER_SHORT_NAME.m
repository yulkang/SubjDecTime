function nam = COMPUTER_SHORT_NAME
% Gives short nickname of the computer.

persistent c_nam

if isempty(c_nam)
    nam = getComputerName;
    
    if any(strcmpStart({'bb17yul01.cpmc.columbia.edu', 'Hudson'}, nam))
        c_nam = 'Hudson';
    elseif any(strcmpStart({'MBR-YK', 'MBR_YK'}, nam)) ...
            || strcmpLast(nam, 'vpn.core.nyp.org')
        c_nam = 'MBR_YK';
    elseif strcmpStart('Jonas', nam)
        c_nam = 'Jonas';
    else
        c_nam = getComputerName;
%         c_nam = input_def('Verify computer name - edit COMPUTER_SHORT_NAME to register', ...
%             'default', getComputerName);
    end
end

nam = c_nam;