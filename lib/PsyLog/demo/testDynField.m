% testDynField

nField = 20;
fieldNames = cell(1,nField);

for ii = 1:nField
    fieldNames{ii} = char('aaa'+ii-1);
end

v = 1:nField;
vc = num2cell(v);

st = cell2struct(vc, fieldNames, 2);

nRep = 1000;
nRep2 = 1;

stT = GetSecs;
for ii = 1:nRep
    for jj = 1:nRep2
        st.('hhh') = st.('hhh') + 1;
%         st.('iii') = st.('iii') + 1;
    end
end
disp(GetSecs - stT);


stT = GetSecs;
for ii = 1:nRep
    ci = find(strcmp(fieldNames, 'hhh'));
    
    for jj = 1:nRep2
        vc{ci} = vc{ci} + 1;
    end
    
%         ci = find(strcmp(fieldNames, 'iii'));
%         v(ci) = v(ci) + 1;
end
disp(GetSecs - stT);

