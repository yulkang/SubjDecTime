function jprintf(fmt, varargin)
% JPRINTF - Print formatted string to command window and keep journal.
%
% See also journal
journal(fmt, varargin, 'verbose', true);