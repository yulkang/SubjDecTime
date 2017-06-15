function varargin2V(varargin)
% varargin2V({'argName1', arg1, 'argName2', arg2, ...}, [defaults = struct_or_cell, restrictInput = false])
%
% Creates variables named 'argName1' with value arg1, and so on, in the caller's workspace.
%
% Examples:
%
% Use
%   varargin2V(varargin, {'defaultArg1', defaultArg1, ...})
% in a function to create variables with defaults.
%
% Use
%   varargin2V(varargin, {'defaultArg1', defaultArg1, ...}, true)
% in a function to issue error when a variable name that's not in the defaults 
% is given in varargin.
%
% See also: demoVarargin2S, varargin2S
%
% 2013 Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin{:});

fieldS = fieldnames(S);
nfieldS = numel(fieldS);

for cfield = 1:nfieldS
    assignin('caller', fieldS{cfield}, S.(fieldS{cfield}) );
end
end