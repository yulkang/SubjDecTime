function varargout = bat2batmat(varargin)
% Convert struct or {{bat1, ...}, {bat2, ...}} into {bat1, ...; bat2, ...} form.
% If already the latter form ("cell matrix form"), leave unchanged.
%
% bat = bat2batmat(bat)
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = bat2batmat(varargin{:});