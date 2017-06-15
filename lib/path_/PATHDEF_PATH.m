function [pth, upth] = PATHDEF_PATH
upth = userpath;
upth = upth(1:(find(upth==pathsep, 1, 'first')-1));

pth = fullfile(upth, 'pth', COMPUTER_SHORT_NAME);
end