function varargout = running_fun(y, x, yfun, varargin)
% [yout, xout] = running_fun(y, x=1:size(y,1), yfun=@mean, varargin)
% [yout1, yout2, ..., youtN, xout] = running_fun(y, x, yfun, 'nargout', N)
%
% running_fun works along the first dimension of y.
% It gives yout(k) = yfun(y(st_ix:en_ix, :)), 
% where st_ix is the index of the x that is more than 'step' away from 
% previous elements, and x(en_ix) < x(st_ix) + win.
%
% In this version, youts are always cell arrays.
%
% Give x=[] and/or yfun=[] to use their defaults.
% 
% Options
% -------
% 'win',      10
% 'step',     [] % min(diff(x))
% 'nargout',  1
% 'xfun',     @mean
% 'width',    'same' % 'same' or 'exhaustive' (not implemented yet)
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'win',      10
    'step',     [] % min(diff(x))
    'nargout',  1
    'xfun',     @mean
    'width',    'same' % 'same' or 'exhaustive'
    });

% Enforce column vector
siz_y = size(y);
if siz_y(1) == 1, y = y'; end

% Default x
if nargin < 2 || isempty(x), 
    x = 1:size(y,1); 
else
    % Enforce column vector
    x = x(:);
end
[x, ix] = sort(x);

% Default step
if isempty(S.step)
    S.step = min(diff(x));
end

% Sort y according to x
y = y(ix, :);

% Default fun
if nargin < 3 || isempty(yfun)
    yfun = @mean;
end

% Initial step
n               = size(y,1);
yout            = cell(n,S.nargout);
xout_requested  = (nargout >= S.nargout + 1);
if xout_requested
    xout        = zeros(n, 1);
end

st_ix           = 1;
en_ix           = find(x < x(1) + S.win, 1, 'last');
n_y             = 1;
[yout{1,:}]     = yfun(y(st_ix:en_ix,:));
if xout_requested
    xout(1)     = S.xfun(x(st_ix:en_ix));
end

% Loop
switch S.width
    case 'same'
        while en_ix < n
            st_ix = find(x >= x(st_ix) + S.step, 1, 'first');
            if isempty(st_ix), break; end

            en_ix = find((x >= x(en_ix) + S.step) & (x < x(st_ix) + S.win), 1, 'first');
            if isempty(en_ix), break; end

            n_y   = n_y + 1;

            [yout{n_y, 1:S.nargout}] = yfun(y(st_ix:en_ix, :));
            if xout_requested
                xout(n_y) = S.xfun(x(st_ix:en_ix));
            end
        end
        
    otherwise
        error('Unimplemented width mode!');
end

yout     = yout(1:n_y,:);
    
if xout_requested
    xout = xout(1:n_y);
end

% Output
varargout = cell(1,nargout);

for ii = 1:min(S.nargout, nargout)
    varargout{ii} = yout(:,ii);
end

% xout only if one more output is requested
if xout_requested
    varargout{S.nargout+1} = xout;
end
    