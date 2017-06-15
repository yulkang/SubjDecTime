function P = PsyImport(o, P, varargin)
% o: Struct with fields of PsyLog objects

if nargin < 2
    P = struct;
end

S = varargin2S(varargin, {
    'fields', {'on', 'off', 'enter', 'exit', 'hold'}
    });

