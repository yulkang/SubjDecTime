function [res ix2] = unionAdd(str1, str2)

len1 = length(str1);
len2 = length(str2);
lenRes = len1;

res = cell(1, len1 + len2);
res(1:len1) = str1;

ix2 = zeros(1, len2);

for ii = 1:length(str2)
    cIx = find(strcmp(str2{ii}, str1));
    
    if isempty(cIx)
        lenRes = lenRes + 1;
        res(lenRes) = str2(ii);
        
        ix2(ii) = lenRes;
    else
        ix2(ii) = cIx;
    end
end

res = res(1:lenRes);
end