% testIntersect

str1 = num2cell('a':'z');

nRep = 1000;


%%
tic;
for ii = 1:nRep
    str2 = num2cell(char(('a' + mod(ii,26)):('a' + mod(ii+10, 26))));
    
    [~, iStr] = intersect(str1, str2);
    
    aa = str1(iStr);
end
toc;


%%
tic;
for ii = 1:nRep
    str2 = num2cell(char(('a' + mod(ii,26)):('a' + mod(ii+10, 26))));
    
    iStr = intersectCellStr(str1, str2);
    
    aa = str1(iStr);
end
toc;


%%
tic;
for ii = 1:nRep
    str2 = num2cell(char(('a' + mod(ii,26)):('a' + mod(ii+10, 26))));
    tfStr = false(1, length(str1));
    
    for jj = 1:length(str2)
        tfStr = tfStr & strcmp(str2{jj}, str1);
    end

    aa = str1(tfStr);
end
toc;
