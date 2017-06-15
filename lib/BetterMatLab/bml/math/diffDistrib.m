function c = diffDistrib(a, b, varargin)
% c = diffDistrib(a, b, varargin)
%
% 'op', 'exact' % 'exact' or 'random'
% 'n',  1000    % ignored if op == 'exact'

S = varargin2S(varargin, {
    'op', 'exact' % 'exact' or 'random'
    'n',  1000    % ignored if op == 'exact'
    });

switch S.op
    case 'exact'
        c = bsxfun(@minus, a(:), b(:)');
        c = c(:);
        
    case 'random'
        error('Not implemented yet!');
end