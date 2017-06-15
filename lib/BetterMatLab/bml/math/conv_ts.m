function v = conv_ts(a, b, bix)
% CONV_TS  convolve and return the first part of the result that has the same length as the 1st argument.
%
% v = conv_t(a, b, bix)
%
% a: a vector or a matrix. If an array of a higher dimension, works on the first dimension.
%    if matrix, convolution works on the first dimension.
%
% b: a vector or a matrix.
%    If matrix, and if bix is given, works like bsxfun.
%    That is,
%       v(:,k) = conv_t(a(:,k), b(:,bix(k)))
%    This works without actually replicating b, potentially saving time and memory.
%
% bix: numerical index into b's columns. Ignored if b is a vector.
%      If a is a multidimensional array, works on an index squashed from second dimension and up.
%
% Note: when convolving back in time (to find original distribution from a delayed data),
%       use conv_t_back to appropriately account for truncation of the filter
%       for the early data.
% 
% See also: conv_t_back

if isvector(b) 
    v = conv_t(a, b);
    
elseif isvector(a)
    v = conv_t(b, a, length(a));
    
else
    % Squash dimensions higher than 2, if any.
    siz = size(a);
    isMatrix = length(siz) <= 2;
    if ~isMatrix
        a = reshape(a, siz(1), []);
    end
    
    % Exapnd bix
    if nargin < 3 || isempty(bix)
        bix = 1:size(b,2);
    elseif size(a,2) ~= length(bix)
        error('When a is a matrix and bix is given, length(bix) must equal size(a,2)');
    end

    % Convolve
    c = arrayfun(@(ii) conv_t(a(:,bix==ii), b(:,ii)), 1:max(bix), 'UniformOutput', false);
    
    % Gather results
    v = zeros(size(a), 'like', a);
    for ii = 1:max(bix)
        tf = bix == ii;
        v(:,tf) = c{ii};
    end
    
    % Restore dimensions higher than 2, if any.
    if ~isMatrix
        v = reshape(v, siz);
    end
end
