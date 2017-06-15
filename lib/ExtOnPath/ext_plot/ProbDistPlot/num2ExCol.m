function anss = num2ExCol(num)
%Converts a column number into an Excel Column Letter

ColString = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

i = 1;
while num > 0
    n = mod(num, 26);
    if n==0, n=26; end
    num = num - n;
    num = num/26;
    anss(i) = ColString(n);
    i = i + 1;
end

anss = fliplr(anss);
