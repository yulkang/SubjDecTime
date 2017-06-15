function varargout = alphanumeric_name(varargin)
% alphanumeric_name  Enforces alphanumeric name format.
%
% Useful e.g., for converting excel column headers into MATLAB variable names.
%
% dst = alphanumeric_name(src, ['option1', option1, ...])
%
% (1) Replaces disallowed characters with allowed ones.
% (2) Enforces character array(s) into row vector(s).
% (3) Puts prefix to names with disallowed beginning.
%
% Options and defaults
% --------------------
% 'allowed_characters',                       ['a':'z', 'A':'Z', '_', '0':'9'], ...
% 'substitute_disallowed_characters_to',      '_', ...
% 'disallowed_beginning',                     ['0':'9', '_'], ...
% 'prefix_for_names_w_disallowed_beginning',  'a__', ...
%
% EXAMPLE:
% >> dst = alphanumeric_name({'a(b)c 2', '2.ab'})
% dst = 
%     'a_b_c_2'    'a__2_ab'
%
% 2013 (c) Yul Kang, hk2699 at columbia dot edu.
[varargout{1:nargout}] = alphanumeric_name(varargin{:});