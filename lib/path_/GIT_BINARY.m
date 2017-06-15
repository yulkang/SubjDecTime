function bin = GIT_BINARY
% Computer-specific path to Git binary

switch COMPUTER_SHORT_NAME
    case 'MBR_YK'
        bin = '/usr/local/bin/git';        
    otherwise
        bin = 'git';
end
