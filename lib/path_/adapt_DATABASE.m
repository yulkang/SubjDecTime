function pth = adapt_DATABASE(pth)
% Adapt data base part of pth to pth

if iscell(pth), pth1 = pth{1}; else pth1 = pth; end

ptn     = [pth1(1:strfind(pth1, '/Data/')), 'Data'];
pth     = strrep(pth, ptn, DATA_BASE_);
