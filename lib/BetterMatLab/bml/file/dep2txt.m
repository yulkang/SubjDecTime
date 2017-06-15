function	varargout = dep2txt(src, varargin)
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

if iscellstr(varargin)
	strargin2var(varargin);
else
	varargin2var(varargin);
end
allParent = {};
depsrc    = {};
depres    = {};

src = which(src);

if ~exist('outFile', 'var'),	outFile = '';		end
if ~exist('nameOnly', 'var'),	nameOnly = 2;		end
if ~exist('filtIn', 'var'),		filtIn = 0;			end
if ~exist('filt', 'var'),		filt = {'toolbox'}; end
if ~exist('verbose', 'var'),	verbose = 2;		end
if ~exist('zipFile', 'var')
	zipFile = '';		
else
	if ~isempty(zipFile) %#ok<NODEF>
		if ~exist('maxDepth', 'var')
			maxDepth = inf;
		end
		if ~any(zipFile=='.')
			zipFile = [zipFile '.zip'];
		end
		if ~exist('zipAdd', 'var'), zipAdd = {}; end
	end
end
if ~exist('maxDepth', 'var'),	maxDepth = inf;	 end

nFilt = length(filt);
srcDir = fileparts(src);

if ~exist('root_dir', 'var'),
    try
        root_dir = DIR_('CODE_BASE');
    catch err
        warning(err_msg(err));
        try
            root_dir = pth_above_pkg(srcDir); 
        catch err
            warning(err_msg(err));
            root_dir = '';
        end
    end
end

% Because default depfun often crashes, use '-toponly' option to go step by step..
% filtering takes place within chldrenTreesPrudent
% since the whole list is not available at the beginning, needs to carry cellStr of full paths
if verbose == 2
    fprintf('\n');
end

meStr = src;

if verLessThan('matlab', '8.4')
    ancestorsCell = {};
    treeListCell = childrenTreesPrudent(meStr, ancestorsCell, maxDepth);

    if verbose == 2
        fprintf('\n');
    end

    % print out tree structure
    if ~isempty(outFile)
        treeCell2Txt(treeListCell, outFile, nameOnly);
    end

    % zip
    if ~isempty(treeListCell)
        uniqueFiles = cellstr(unique(char(treeListCell(:,1)),'rows'));
    else
        uniqueFiles = {};
    end
    
    productList = [];
else
    [uniqueFiles, productList] = matlab.codetools.requiredFilesAndProducts(meStr);
    fprintf('Required MathWorks products:\n');
    nProduct = numel(productList);
    for ii = 1:nProduct
        disp(productList(ii));
    end
    
    treeListCell = {};
end

if ~isempty(zipFile)
    filesToZip = vertcat(uniqueFiles, zipAdd(:));
    
    zip_packages(filesToZip, zipFile, verbose==2, root_dir);
    
    if ~isempty(zipAdd) && verbose == 2
        fprintf('Additional files zipped together:\n');
        fprintf('\t%s\n', zipAdd{:});
        fprintf('\n');
    end
end
	
% return unique paths
if ~isempty(uniqueFiles)
    uniquePaths = unique(cellfun(@fileparts, uniqueFiles, 'UniformOutput', false));
else
    uniquePaths = {};
end

if verbose >= 1
    fprintf('\n');
    fprintf('Unique files that %s depends on:\n', src);
    fprintf('  %s\n', uniqueFiles{:});
    fprintf('\n');
    fprintf('Unique paths that %s depends on:\n', src);
    fprintf('  %s\n', uniquePaths{:});
    fprintf('\n');
end

if nargout>0
    varargout = {treeListCell, uniquePaths, uniqueFiles, productList};
end

    function treeListCell = childrenTreesPrudent(meStr, ancestorsCell, maxDepth)
        % treeList = childrenTrees(me, ancestors, maxDepth)
        % treeList(,;) = [iEntry depth recursive]

        % show depth structure immediately
        depth = length(ancestorsCell) + 1;
        if verbose == 2
            fprintf(repmat('\t', [1  depth-1]));
            if nameOnly==2
                [pathStr name] = fileparts(meStr); %#ok<ASGLU>
                fprintf(name);
            elseif nameOnly==1
                [pathStr name] = fileparts(meStr);
                if strcmp(pathStr,srcDir)
                    fprintf(name);
                else
                    fprintf(meStr);
                end
            else
                fprintf(meStr);
            end
        end
        
        if isempty(meStr)
            treeListCell = {};
            return;
        end

        % get list of immediate parents
        depix = find(strcmp(meStr, depsrc));
        if isempty(depix)
            if verLessThan('matlab', '8.4')
                topList = ... [topList builtIns matlabClasses probFiles probSymbols evalStrings topParent] = ...
                    depfun(meStr, '-quiet', '-toponly'); %#ok<DEPFUN>
            else
                topList = matlab.codetools.requiredFilesAndProducts(meStr, 'toponly');
            end
            depix  = length(depsrc) + 1;
            depsrc{depix} = meStr;
            depres{depix} = topList;
        else
            topList = depres{depix};
        end
        nList = length(topList);

        % filter
        toIncl = ones(nList,1) * (~filtIn);
        for iFilt = 1:nFilt
            cFilt = filt{iFilt};

            for iList = 2:nList
                if ~isempty(strfind(topList{iList},cFilt))
                    toIncl(iList) = filtIn;
                end
            end
        end
        toIncl = setdiff(find(toIncl)', 1);

        % meStr
        % ancestorsCell
        % topList
        % toIncl

        % find out tree structure
        if anyMatchCellStr(ancestorsCell, topList(toIncl)) % if recursive
            treeListCell = {meStr depth 1};
            if verbose == 2
                fprintf('*\n');
            end
            return;
        else
            if verbose == 2
                fprintf('\n');
            end
            treeListCell = {meStr depth 0};	
            if depth >= maxDepth, return; end

            for iEntry = toIncl
                cEntry = topList{iEntry};
                treeListCell = vertcat(treeListCell, ...
                            childrenTreesPrudent(cEntry, horzcat(ancestorsCell, {meStr}), maxDepth));
            end
        end
    end

    function treeList = childrenTrees(me, ancestors, maxDepth)
        % treeList = childrenTrees(me, ancestors, maxDepth)
        % treeList(,;) = [iEntry depth recursive]

        depth = length(ancestors) + 1;
        treeList = [me  depth  0];

        if depth >= maxDepth, return; end

        for iEntry = setdiff(toIncl,me)
            if any(allParent{iEntry} == me)
                if any(iEntry == ancestors)
                    treeList(end+1,:) = [iEntry  depth+1  1]; %#ok<AGROW>
                else
                    treeList = [treeList; 
                                childrenTrees(iEntry, [ancestors me], maxDepth)]; %#ok<AGROW>
                end
            end
        end
    end
end


function res = anyMatchCellStr(cellStr1, cellStr2)
% receives two one-dimensional cellStr, and tell if any of the strings are identical.
len1 = length(cellStr1); len2 = length(cellStr2);

if len1 > len2
	for iStr = 1:len2
		if any(strcmp(cellStr2{iStr}, cellStr1)), res = true; return; end
	end
else % len1 <= len2
	for iStr = 1:len1
		if any(strcmp(cellStr1{iStr}, cellStr2)), res = true; return; end
	end
end
res = false;
end


function treeCell2Txt(treeListCell, outFile, nameOnly)
% function treeCell2Txt(treeListCell, outFile, nameOnly)

if ~isempty(outFile)
	fids = fopen(outFile, 'w'); % [fids fopen(outFile, 'w')];
end
srcDir = fileparts(treeListCell{1,1});

for iTreeList = 1:size(treeListCell,1)
	cEntry		= treeListCell{iTreeList,1};
	cDepth		= treeListCell{iTreeList,2};
	cRecursive	= treeListCell{iTreeList,3};
	
	if (nameOnly==2) || (nameOnly=='2')
		[pathStr name] = fileparts(cEntry); %#ok<ASGLU>
		outStr = name;
	elseif (nameOnly==1) || (nameOnly=='1')
		[pathStr name] = fileparts(cEntry);
		if strcmp(pathStr,srcDir)
			outStr = name;
		else
			outStr = cEntry;
		end
	else
		outStr = cEntry;
	end
	
	for cFid = fids
		fprintf(cFid,repmat('\t', 1, cDepth-1));
		fprintf(cFid, '%s', outStr);
		
		if cRecursive
			fprintf(cFid, '*\n');
		else
			fprintf(cFid, '\n');
		end
	end
end

if ~isempty(outFile)
	fclose(fids(fids~=1));
end
fprintf('\n');
end


function tree2Txt(treeList, allList, outFile, nameOnly, verbose)
% function treeToTxt(treeList, allList, outFile, nameOnly, verbose)

if verbose == 2
	fids = 1; % Screen
	fprintf('\n');
else
	fids = []; 
end
if ~isempty(outFile)
	fids = [fids fopen(outFile, 'w')];
end
srcDir = fileparts(allList{1});

for iTreeList = 1:size(treeList,1)
	iEntry		= treeList(iTreeList,1);
	cDepth		= treeList(iTreeList,2);
	cRecursive	= treeList(iTreeList,3);
	
	if nameOnly==2
		[pathStr name] = fileparts(allList{iEntry}); %#ok<ASGLU>
		outStr = name;
	elseif nameOnly==1
		[pathStr name] = fileparts(allList{iEntry});
		if strcmp(pathStr,srcDir)
			outStr = name;
		else
			outStr = allList{iEntry};
		end
	else
		outStr = allList{iEntry};
	end
	
	for cFid = fids
		fprintf(cFid,repmat('\t', 1, cDepth-1));
		fprintf(cFid, '%s', outStr);
		
		if cRecursive
			fprintf(cFid, '*\n');
		else
			fprintf(cFid, '\n');
		end
	end
end

if ~isempty(outFile)
	fclose(fids(fids~=1));
end
fprintf('\n');
end


function varargin2var(vararginCell)
nVar = length(vararginCell)/2;
for iVar = 1:nVar
	assignin('caller', vararginCell{iVar*2-1}, vararginCell{iVar*2});
end
end


function strargin2var(vararginCell)
nVar = length(vararginCell)/2;
for iVar = 1:nVar
	try
		assignin('caller', vararginCell{iVar*2-1}, eval(vararginCell{iVar*2}));
	catch
		assignin('caller', vararginCell{iVar*2-1}, vararginCell{iVar*2});
	end
end
end