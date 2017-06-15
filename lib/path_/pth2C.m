function C = pth2C(pth)
% Convert path string to a cell array

pth_en  = find(pth == ':') - 1;
pth_st  = [1, pth_en(1:(end-1)) + 2];
C       = arrayfun(@(st, en) pth(st:en), pth_st, pth_en, 'UniformOutput', false);
