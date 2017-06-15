function pth = adapt_CODEBASE(pth)
% Adapt code base part of pth to pth

if iscell(pth), pth1 = pth{1}; else pth1 = pth; end

ptn     = [pth1(1:strfind(pth1, '/Code/')), 'Code'];
pth     = strrep(pth, ptn, CODE_BASE_);
