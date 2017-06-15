% testIsEqual
clear all;

nRep = 1000;

ttt1 = num2cell('a':'z');
ttt2 = num2cell('a':'z'); ttt2{end} = 'a';

tic; for tt = 1:nRep; a = strcmp(ttt1, ttt2); end; toc;

tic; for tt = 1:nRep; a = isequal(ttt1, ttt2); end; toc;

% Result: strcmp & isequal are comparable.




s1 = cell2struct(ttt1, ttt1, 2);
s2 = cell2struct(ttt2, ttt1, 2);

tic; for tt = 1:nRep; a = strcmp(struct2cell(s1), struct2cell(s2)); end; toc;

tic; for tt = 1:nRep; a = isequal(s1, s2); end; toc;

% Result: again, strcmp & isequal are comparable.