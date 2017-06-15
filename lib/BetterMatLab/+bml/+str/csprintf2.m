function varargout = csprintf2(varargin)
% Similar to csprintf but arguments are replicated both in row and column.
%
% C = csprintf2(fmt, args)
%
% EXAMPLE:
% >> csprintf2('%s_%d_%d', {'AA'}, (1:3)', (1:2))
% ans = 
%     'AA_1_1'    'AA_1_2'
%     'AA_2_1'    'AA_2_2'
%     'AA_3_1'    'AA_3_2'
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = csprintf2(varargin{:});