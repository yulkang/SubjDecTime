function res = catFields(s, fs, varargin)
% res = catFields(s, fs, varargin)
%
% 'dim',  []
% 'cell', false

S = varargin2S(varargin, {
    'dim',  []
    'cell', false
    });

if isempty(S.dim)
    siz = size(fs);
else
    siz = ones(1, max(S.dim, 2));
    siz(S.dim) = numel(fs);
end

if S.cell
    res = cell(siz);
    for ii = 1:numel(fs)
        res{ii} = s.(fs{ii});
    end
else
    res = zeros(siz);
    for ii = 1:numel(fs)
        res(ii) = s.(fs{ii});
    end
end