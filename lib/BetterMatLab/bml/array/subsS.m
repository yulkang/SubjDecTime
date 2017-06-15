function S = subsS(varargin)
% SUBSS substruct for structs.
%
% S = subsS(field1, field2, ...)
%
% gives struct that can be used to access
%   s.(field1).(field2)....
% by 
%   subsref(s, S)
% or
%   s = subsasgn(s, S, value)

C = [repmat({'.'}, [1, length(varargin)])
     varargin];
S = substruct(C{:});
                