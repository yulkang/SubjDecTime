function dst = alphanumeric_name(src, varargin)
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

S = varargin2S(varargin, { ...
    'allowed_characters',                       ['a':'z', 'A':'Z', '_', '0':'9'], ...
    'substitute_disallowed_characters_to',      '_', ...
    'disallowed_beginning',                     ['0':'9', '_'], ...
    'prefix_for_names_w_disallowed_beginning',  'a__', ...
    });

% Use recursive call with cellfun if the input is a cell array. 
% This may be further optimized by calling cellfun for each operation
% without recursive call, but using recursive call is much simpler to
% understand and maintain.
if iscell(src)
    dst = cellfun(@(s) alphanumeric_name(s(:)', varargin{:}), src, 'UniformOutput', false);    
    return;
    
elseif ischar(src)
    dst = src(:)'; % enforces row vector.
    
else
    error('src should be a cell array of strings or a string!');
end

% Substitute disallowed characters
dst(~any(bsxEq(dst', S.allowed_characters(:)'), 2)) ...
    = S.substitute_disallowed_characters_to;

% Put prefix if the name starts with a disallowed beginning.
if any(dst(1) == S.disallowed_beginning)
    dst = [S.prefix_for_names_w_disallowed_beginning, dst];
end
