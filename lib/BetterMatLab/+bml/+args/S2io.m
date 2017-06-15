function varargout = S2io(varargin)
% Input and output from a struct's fields
%
% S = S2io(S, f, out, in, ...) % Ignored if in = out = {}. In that case, S = f(S).
%
% OPTIONS
% -------
% 'use_varargout', true
%
% Give {} for out or in to specify S itself as the input or output.
%
% Otherwise,
% S = S2io(S, f, {'out1', out2'}, {'in1', 'in2', 'in3'}) calls
% [S.out1, S.out2] = f(S.in1, S.in2, S.in3)
%
% S = S2io(S, f, {'out1', out2'}, {'in1', 'in2', 'in3'}, 'use_varargout', false) calls
% {S.out1, S.out2} = f(S.in1, S.in2, S.in3),
% where f() is expected to give a cell vector of length 2.
%
% 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.
[varargout{1:nargout}] = S2io(varargin{:});