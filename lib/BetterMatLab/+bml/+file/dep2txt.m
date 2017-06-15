function varargout = dep2txt(varargin)
% DEP2TXT - Shows dependency of a program.
%
% [treeList, uniquePaths, uniqueFiles, productList] = dep2txt(src, ['name1', value1, ...])
%
% INPUT:
%   src
%   : .m file or function name to analyze
%
%   options
%   : in the form of 'optionName1', value1, and so on.
%     optionNames are case sensitive.
% 
%     outFile	
%     : text file to write the result. 
%       omit if you don't want a file output.
%
%     maxDepth
%     : maximum depth to search. inf for unlimited. default is inf.
%       if zipFile is specified, the default is inf.
%
%     nameOnly
%     : 1(default): exclude path if the same as src
%       2: exclude all path
%
%     filtIn	
%     : if nonzero, only files that has filt in their full path are INcluded.
%       if zero, only files that has filt in their full path are EXcluded.
%       default is zero.
%
%     filt	
%     : cell array of filter strings. 
%       default is {'toolbox'}. good for filtering out obvious entries.
%
%     verbose	
%     : 1 - display unique paths (default)
%       2 - display whole tree.
%
%     zipFile 
%     : if specified with non-empty string, 
%       zips all the files that the src file depends on, 
%       including the src file itself, with the specified zipFile name.
%
%     zipAdd	
%     : cell string of file names. Added to the zipFile.
%
%     root_dir
%     : If specified, relative paths from root_dir will be preserved within zip.
%       Defaults to the code file's folder.
%       Specify '' to ignore non-package directories.
%				  
% WARNING:
% (1)   Use dynamic calling with function pointer (@) 
%       rather than with function name ('').
%       Otherwise, dep2txt will fail to recognize the dependence.
%       e.g. fminsearch(@poo, ...) rather than fminsearch('poo', ...)
%
% (2)   In a script, first import package.fun and use the function/script, 
%       rather than using package.fun directly in the program.
%
% OUTPUT:
%	treeList(,;) : {'fileName', depth, recursive} (cell array) 
%   uniquePaths  : List of unique paths.
%   uniqueFiles  : List of unique files.
%   productList  : Struct array of required MathWorks products.
%
%	text output:
%		asterisk(*) at the end of an entry means it is called recursively.
%
% COMPATIBILITY:
%   treeList, text output : enabled only in MATLAB ver < 8.4
%   productList : enabled only in MATLAB ver >= 8.4
%
% 
% EXAMPLE:
% 
% >> dep2txt VMFB_GLM
% 
% VMFB_GLM
% 	GLM_RFX
% 		RFX_contrastFnc
% 			sub_makeNCdDstDirs
% 		RFX_specifyChangeFileOnlyFnc
% 			GLM_estimate
% 				sub_makeNCopySpmToDstDir
% 			sub_makeNCdDstDirs
% 		sub_unpackStruct
% 		test
% 	GLM_loadSessions
%
% 2011 (c) Yul Kang. hk2699 at columbia dot edu.
%
% See also: dep2zip, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.
[varargout{1:nargout}] = dep2txt(varargin{:});