function varargout = arrayFunAny(varargin)
% ARRAYFUNANY   Similar to arrayfun but allows any class of function/in/output.
%
% Note that this will be slower than MATLAB's arrayfun, although more
% flexible in that any class of output is allowed. Use as a convenience function
% only.
%
% [res success] = arrayFunAny(op, v, 'opt1', val1, ...)
%
%     op            : Any function that receives one input and returns one 
%                     output, e.g., a number, (cell) array, or struct (array).
%
%     v             : An array of any class, including cell or user-defined
%                     classes. Giving cell array will feed v{ii} to op().
%
%     success       : Logical vector. False if error occured for the file.
%
% Options
%
%     uniformOutput : If false, res is a cell array. Defaults to true.
%
%     catDim        : If nonzero, res is concatenated along specified dimension.
%                     When uniformOutput = true, output is a concatenated array.
%                     When uniformOutput = false, output is a cell vector
%                     along the specified dimension.
%
%                     If zero, res has the same size as v.
%                     Defaults to zero.
%
%     errorBehav    : Behavior when error occurs.
%                     If 'error', rethrows error.
%                     If 'default', substitutes the result with default.
%                     If 'skip', skips the file. It shortens res, 
%                     so that length(res) == nnz(success). 
%
%     default       : The value to assign to res when errorBehav = 'default'
%                     for the files resulted in an error. Defaults to [].
%
%     verbose       : If 0, hide messages. Defaults to 1. For more, set to 2.
%
% See also ARRAYFUN, CELLFUN, FILEFUN.
%
% Written by Hyoung Ryul "Yul" Kang (2012). hk2699 at columbia dot edu.
[varargout{1:nargout}] = arrayFunAny(varargin{:});