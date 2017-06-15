function jdisp(varargin)
% jdisp  Similar to jdisp but journals output. Also allows script form.
%
% EXAMPLE:
% jdisp any message 
%
% See also: journal

journal(sprintf('%s\n', funPrintfBridge(' ', varargin{:})));