% testOrderFields
nRep = 1000;
s = cell2struct(num2cell(zeros(1,26)), num2cell('a':'z'), 2);

for ii = 1:nRep
    s = orderfields(s, randperm(26));
end
