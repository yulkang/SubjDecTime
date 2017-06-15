function c = cellstrempty(c)
% Make empty entries ([]) have char class ('').
%
% c = cellstrempty(c)

c(cellfun(@isempty, c)) = {''}; 