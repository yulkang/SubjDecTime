function colors = colors2mat(colors, n)
% Given a colormap function handle, 
%
% colors = colors2mat(colors, n)

if nargin < 2 || isempty(n)
    n = 1; 
end

if ischar(colors)
    colors = feval(colors, n);
    
elseif isa(colors, 'function_handle')
    colors = colors(n);
    
elseif isnumeric(colors) && isrow(colors)
    colors = repmat(colors, [n, 1]);
    
elseif isnumeric(colors) && ismatrix(colors)
    % No further processing
    
else
    error('Give a function handle or 1x3 or Nx3 numeric!');
end

% Make sure it is the correct format: N x 3 numeric.
assert(isnumeric(colors) && ismatrix(colors) ...
    && (size(colors,1) == n) && (size(colors,2) == 3));

end