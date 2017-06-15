function [a, sub] = ix2array(y, sub, varargin)
% a = ix2array(y, sub, siz, ...)
%
% y     : A vector of values.
% sub   : R x ND matrix of subscripts.
% siz   : A size vector. Defaults to max(sub).
%
% f     : Initialization function that takes a size vector. Defaults to @zeros.
% tol   : Tolerance in determining unique values of sub
%
% a     : ND array where a(sub(k,1), sub(k,2), ...) = y(k).
%
% See also: consolidate, consolidator
% 
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

error('Under construction!');

S = varargin2S(varargin, {
    'siz',  []
    'def',  @zeros
    'tol',  0
    });

C = size(sub, 2);
for ii = 1:C
    [~,~,sub(:,ii)] = consolidate(sub(:,ii), [], [], S.tol);
end

if isempty(S.siz), S.siz = max(sub); end

sub = mat2cell(sub, size(sub,1), ones(1, size(sub,2)));
ind = sub2ind(S.siz, sub{:});

a = S.def(S.siz);
a(ind) = y(:);