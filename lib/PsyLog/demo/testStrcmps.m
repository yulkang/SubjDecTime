% testStrcmps
% verdict: strcmpfinds is just as fast as, if not faster than, strcmps.

strs = cellstr(repmat(('a':'h')', [1 5]))';

%%
stT = GetSecs;
for ii = 1:1000
    if ~isnumeric(strs(1)) && ~islogical(strs(1))
        tt = strcmpfinds(strs(1), strs);
    end
end
enT = GetSecs;
disp(enT - stT);

%
stT = GetSecs;
for ii = 1:1000
    if ~isnumeric(strs(1)) && ~islogical(strs(1))
        tt = strcmps(strs(1), strs);
    end
end
enT = GetSecs;
disp(enT - stT);

%%
tic;
for ii = 1:1000
    isH = strcmp('hhhhh', strs);
    iH  = find(isH);
    tt = strs{find(iH)};
end
toc;



tic;
for ii = 1:1000
    isH = strcmp('hhhhh', strs);
    tt = strs{isH};
end
toc;


