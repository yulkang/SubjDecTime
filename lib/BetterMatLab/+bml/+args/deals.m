function varargout = deals(C)
% Return variables suitable for for loop
%
% varargout = deals(C)
%
% EXAMPLE 1
% ---------
% [a, b, ix] = bml.args.deals({
% 'AA', 20
% 'BB', 30
% })
%
% a = 
%     'AA'    'BB'
% b = 
%     [20]    [30]
% ix =
%      1     2
%
% EXAMPLE 2
% ---------
% [a, b, c, ix] = bml.args.deals({
% {'AA', 30}
% {'BB'}
% {'CC', 50, 100}
% })
% 
% a = 
%     'AA'    'BB'    'CC'
% b = 
%     [30]    []    [50]
% c = 
%     []    []    [100]    
% ix =
%      1     2     3

C = bml.matrix.cc2cmat(C);

n = size(C, 1);
p = size(C, 2);
ix = 1:n;

varargout = cell(nargout, 1);

for ii = ix
    varargout{ii} = C(:, ii)';
end

if nargout >= p + 1
    varargout{p + 1} = ix;
end

