function varargout = fileFun(varargin)
% FILEFUN   Apply operation to the specified files and return array.
%           Useful when you extract a summary statistic from an unwieldy
%           size of data in many files. Utilize addArgs and rmField option
%           (below) to conveniently load necessary variables while excluding
%           too large ones.
%
% [res success] = fileFun(op, filt, {'arg1', ...}, 'opt1', val1, ...)
%
%     op            : Any function that receives a scalar struct with
%                     fields of specified variables loaded from the file, 
%                     and returns one output, e.g., a number or a struct.
%                     I.e., the input is such an S from S=load(FILE, 'var1', ..),
%                     where each FILE is specified by FILT (below).
%                     See <a href="matlab:help load">help load</a>
%
%     filt          : Specifies files, e.g., 'test/*.mat',
%                     or cell array of file names.
%                     Fed to dirCell. See <a href="matlab:help dirCell">help dirCell</a>.
%
%     arg           : Variables loaded from the file, packed into a struct,
%                     and feed into op().
%
%     success       : Logical vector. False if error occured for the file.
%
% Options
%
%     uniformOutput : If false, res is a cell array. Defaults to true.
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
%     addArgs       : If true, assuming res is a struct, adds arg's to 
%                     res as fields. Defaults to false.
%
%     rmField       : If cell array of variable names are given,
%                     excludes the variables from fields of the result.
%                     Defaults to {}.
%
%     verbose       : If false, hide messages. Defaults to true.
%
% See also CELLFUN, ARRAYFUN, ARRAYFUNANY, MATFILE, DIRCELL, LOAD.
%
% Written by Hyoung Ryul "Yul" Kang (2012). hk2699 at columbia dot edu.
[varargout{1:nargout}] = fileFun(varargin{:});