function r = gamrnd_ms(m,s,varargin)
% r = gamrnd_ms(m,s,varargin)
%
% See also: gamrnd

if length(varargin) == 1 && isscalar(varargin{1})
    varargin{1} = [1, varargin{1}];
end

k       = m.^2./(s.^2);
beta    = (s.^2);

r = gamrnd(k, beta, varargin{:});