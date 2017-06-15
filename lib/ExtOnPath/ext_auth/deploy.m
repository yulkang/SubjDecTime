function deploy( source, destination, varargin)
% DEPLOY creates p-coded files and the associated help text of a given
% source to a given destination folder. Works recursive on folder trees,
% including Package folders (+Package) and classes as well as class folders
% (@Class). For classes no help is created for the private functions in the
% private folder, but help is also created for all public get / constant
% properties.
%
%
% Syntax: deploy( source, destination, varargin)
%
% Inputs:
%   -source:        Can be a single M-file or a folder, also works for
%                   packages and Classes
%   -destination:   Has to be an empty folder
%   -varargin:      The folowing options can be added:
%                   'excludes'      - the files to exclude, always excluded
%                                     is this file itself
%                   'includes'      - the additional files to deploy, e.g.
%                                     {'*.pdf', '*.png'}
%                   'recursive'     - default is true, can be set to false.
%                                     Packages and Class directories are
%                                     always included and cannot be
%                                     excluded
%                   'includeDLL'    - Dll's are by default included. To
%                                     exclude Dll's set this option to false 
%                   'includeMex'    - Mex files are by default included, To
%                                     exclude Mex files, set this option to
%                                     false
%                   'includeHiddenDirs    - by default . presceded folders
%                                           and files are excluded by default, 
%                                           set this option to true to
%                                           include . preceded folders,
%                                           e.g. .svn or .git
%                   'purgeDestination'    - ATTENTION, if this option is
%                                           set to true, the destination
%                                           will be deleted and all its
%                                           subdirectories without further
%                                           warning.
%
% Outputs:
%   -none
% Example:
%   deploy( 'myfun.m', 'for_public' ); % where myfun.m is a function and
%                                        for_public a folder
%   deploy( 'myproject', 'for_public' ); % where myproject is a folder
%                                           and for_public a folder
%   deploy('myproject', 'project_v1.0', 'recursive', true, ...
%           'includeHiddenDirs', true, 'purgeDestination', true, ...
%           'includes', {'*.pdf', '*.png'});
%
% Other m-files required:
%   None
%
% Other files required:
%   MATLAB
%
% See also: pcode

% About and copyright
% Author: Adrian Etter
% http://www.econ.uzh.ch/faculty/etter.html
% E-Mail: etteradrian@gmail.com
% © Department of Economics,
% University of Zurich
% Version 1.51 2013/June/26
% Last changes:
%   2013/June/26
%   - destination was created before checked if there were any files to
%     process
%   - fixed a bug that made that single files couldnt be processed
%   - fixed a bug that caused, that when deploying @class as direct source,
%     the @class folder structure wasn't kept.
%   - fixed a bug that caused, that when deploying +package as direct source,
%     the +package folder structure wasn't kept.
%   2013/June/19
%   - added recursion for subfolders
%   - added support for Matlab Classes
%   - added support for Matlab ClassFolders
%   - added support for Matlab PackageFolders
%   2013/Mar/01
%   - finished
% 

% CHECK SOURCE
    if isempty(source)
        source = '.';
    end
    assert(ischar(source), 'deploy:source', 'Source must be string, see help!');
    
    flags = processFlags(varargin{:});
        
    % CHECK DESTINATION
    assert(ischar(destination), 'deploy:destination', 'Destination must be string, see help!');
    assert(~isempty(destination), 'deploy:destination', 'Destination variable cannot be empty, see help!');
    

    % CREATE DESTINATION IF IT NOT ALREADY EXISTS
    dirNew = false;
    if isdir(destination)
        if flags.purgeDestination
            rmdir(destination, 's');
            mkdir(destination);
        else
            assert(numel(dir(destination)) < 3, ...
                'deploy:destination:notempty', ...
                'Destination Folder is not empty! Destination folder has to be empty!');
        end
    else
        mkdir(destination);
        dirNew = true;
    end     
    destination = [cd(cd(destination)), filesep];
    
    % GET FILES TO PROCESS   
    if flags.verbose
        disp('Generating files to process tree');
    end
    
    if isdir(source)        
        source = [cd(cd(source)) filesep];
    end
    
    % IF SOURCE IS A PACKAGE, WE WANT TO KEEP THAT STRUCTURE
    addPackToDest = false;
    package = getPackageName(source);
    destPackage = getPackageName(destination);
    if ~isempty(package) 
        if isempty(destPackage)
            addPackToDest = true;
        else
            assert(strcmp(package, destPackage), ...
                'deploy:source:package:missmatch', ...
                'Source and destination folders are packages, but with different names. You cannot rename while deploying!')
        end
    end
    
    addClassToDest = false;
    class = getClassName(source);
    destClass = getClassName(destination);
    if ~isempty(class) 
        if isempty(destClass)
            addClassToDest = true;
        else
              assert(strcmp(class, destClass), ...
                'deploy:source:class:missmatch', ...
                'Source and destination folders are packages, but with different names. You cannot rename while deploying!')
        end
    end
    
    if addPackToDest
        destination = cat(2, destination, filesep, '+', package);
    end
    
    if addClassToDest
        destination = cat(2, destination, filesep, '@', class);
    end
    
    
    files = generateFileProcessList(source, destination, flags); 
    if isempty(files) % nothing to do!
        disp('No files to process found!');
        if dirNew
            rmdir(destination, 's');
        end
        return;
    end    
    

    
    % CREATE DESTINATION FOLDER TREE
    for i = 1:numel(files)
        if ~isdir(files(i).destination)
            mkdir(files(i).destination);
        end
    end
    if flags.verbose
        disp('Processing files... this could take a while!');
    end
    processFiles(files, flags);
end

function [ flags ] = processFlags( varargin )

        defaultExcludes                 = {[mfilename '.m']}; %{'*.pdf'; '*.png'};
        defaultRecursive                = true;
        parentClassFolder               = false;
        defaultIncludes                 = {'*.m'};
        mexIncludes                     = cellfun(@(y) ['*.' y], feval(@(x) {x.ext}.' , mexext('all')), 'UniformOutput', false);
        dllIncludes                     = {'*.dll'};
        defaultIncludeDLL               = true;
        defaultIncludeMex               = true;
        defaultIncludeHiddenFolders     = false;
        defaultPurgeDestination         = false;
        defaultVerbose                  = false;
        
        
        p = inputParser;
        p.addParamValue('excludes', defaultExcludes,  @(x) (ischar(x) || iscellstr(x)));
        p.addParamValue('includes', defaultIncludes, @(x) (ischar(x) || iscellstr(x)));
        p.addParamValue('recursive', defaultRecursive, @(x) (islogical(logical(x)) && isscalar(x)));
        p.addParamValue('includeDLL', defaultIncludeDLL, @(x) (islogical(logical(x)) && isscalar(x)));
        p.addParamValue('includeMex', defaultIncludeMex, @(x) (islogical(logical(x)) && isscalar(x)));
        p.addParamValue('includeHiddenDirs', defaultIncludeHiddenFolders, @(x) (islogical(logical(x)) && isscalar(x)));
        p.addParamValue('purgeDestination', defaultPurgeDestination, @(x) (islogical(logical(x)) && isscalar(x)));
        p.addParamValue('verbose', defaultVerbose, @(x) (islogical(logical(x)) && isscalar(x)));
        p.addParamValue('parentClassFolder', parentClassFolder);
        
        p.parse(varargin{:});
        flags = p.Results();        
        flags.recursive = logical(flags.recursive);
        flags.includeDLL = logical(flags.includeDLL);
        flags.includeMex = logical(flags.includeMex);
        flags.includeHiddenDirs = logical(flags.includeHiddenDirs);
        flags.verbose = logical(flags.verbose);
        
        
        if ischar(flags.excludes)
            flags.excludes = {flags.excludes};
        end
        if ischar(flags.includes)
            flags.includes = {flags.includes};
        end
        
        flags.excludes = unique(cat(1, defaultExcludes, flags.excludes{:}));
        flags.includes = unique(cat(1, defaultIncludes, flags.includes{:}));
        
        if flags.includeDLL
            flags.includes = cat(1, flags.includes, dllIncludes);
        end
        
        if flags.includeMex
            flags.includes = cat(1, flags.includes, mexIncludes);
        end        
        
        if ~flags.includeHiddenDirs
            flags.excludes = cat(1, flags.excludes, '.*');
        end       
        
        assert(isempty(intersect(flags.includes, flags.excludes)), ...
            'deploy:includeexclude:intersect', 'Includes and Excludes intersect, you cannot exclude and include the same option!');

end

function processFiles(files, flags)    
        for i = 1 : numel(files)   
            if flags.verbose
                disp(files(i).fullpath);
            end
            if files(i).isMFile
                if files(i).generateHelp                  
                    writeHelpFile(files(i));
                end
                makePCode(files(i));
            else % no mfile, so just make a copy of the file
                [success, msg, ~] = copyfile(files(i).fullpath, files(i).destination,'f');
                assert(success == 1, ...
                'deploy:copyfile:failed', ...
                'Copy file failed and interrupted on file: %s. Message: %s', files(i).fullpath, msg);
            end
            

        end    
end

function makePCode(file)
    actualpath = path();
    path(file.base, actualpath);
    pcode(file.fullpath, '-INPLACE');
    path(actualpath);
    pfile = [file.fullpath(1:end-1) 'p'];
    [success, ~, ~] = movefile(pfile, file.destination, 'f');
    assert(success == 1, ...
        ['Move file failed and interrupted on file: ' pfile]);
end

function writeHelpFile(file)

    actualpath = path();
    path(file.base, actualpath);
    try
        if isempty(meta.class.fromName(file.helpCmd)) % normal file
            writeFunctionHelp(file);
        else % is a class
            writeClassHelp(file);
        end
        path(actualpath);
    catch err
        path(actualpath);
        rethrow(err);
    end
end

function txt = getHelpText(cmdName)
    txt = help(cmdName);
    if isempty(txt)
        return;
    end
    txt = regexp(txt, '\n','split').';
    txt = strcat('%', txt);
end

function writeClassHelp(file)
    
    % CREATING CLASS HEADER
    helptext = getHelpText(file.helpCmd);
    if isempty(helptext)
        return;
    end   
    % ADD classdef line to TOP
    headLine = getHeadLine(file, 'classdef');
    if ~isempty(headLine)
        helptext = vertcat(headLine, helptext);
    end
    
    % GETTING CLASS META INFORMATION
    metainfo = meta.class.fromName(file.helpCmd);
    % PROCESSING PUBLIC GET PROPERTIES
    properties = metainfo.PropertyList(strcmp({metainfo.PropertyList.GetAccess}, 'public') & [metainfo.PropertyList.Hidden] == false);
    helptext  = vertcat(helptext, sprintf('\n\tproperties\n'));
    for i = 1:numel(properties)
        propertyHelp = getHelpText([file.helpCmd '.' properties(i).Name]);
        if ~isempty(propertyHelp)
            propertyHelp = sprintf('\t\t%s; %%%s\n', properties(i).Name, [propertyHelp{:}]);
            helptext  = vertcat(helptext, propertyHelp); %#ok<AGROW> Yes it's growing, ans we have no idea how much, so no preallocating!
        end
    end
    helptext  = vertcat(helptext, sprintf('\n\tend\n'));
    % PROCESSING PUBLIC METHODS    
    df = [metainfo.MethodList.DefiningClass];
    methods = metainfo.MethodList(strcmp({metainfo.MethodList.Access}, 'public') & strcmp({df.Name}, file.helpCmd));
    helptext  = vertcat(helptext, sprintf('\n\tmethods\n'));
    for i = 1:numel(methods)
        methodHelp = getHelpText([file.helpCmd '.' methods(i).Name]);
        if ~isempty(methodHelp)
            functionSignature = sprintf('\t\tfunction');
            
            % HANDLE OUTPUT ARGUMENTS
            if numel(methods(i).OutputNames) > 0
                functionSignature = sprintf('%s [', functionSignature);
                for j = 1:numel(methods(i).OutputNames) - 1
                    functionSignature = sprintf('%s%s, ', functionSignature, methods(i).OutputNames{j});
                end
                functionSignature = sprintf('%s%s] =', functionSignature, methods(i).OutputNames{end});
            end            
            % ADD FUNCTION NAME
            functionSignature = sprintf('%s %s(', functionSignature, methods(i).Name);
            % HANDLE INPUT ARGUMENTS
            if numel(methods(i).InputNames) > 0
                for j = 1:numel(methods(i).InputNames) - 1
                    functionSignature = sprintf('%s%s, ', functionSignature, methods(i).InputNames{j});
                end
                functionSignature = sprintf('%s%s', functionSignature, methods(i).InputNames{end});
            end
            functionSignature = sprintf('%s)', functionSignature);
            methodHelp = cellfun(@(x) sprintf('\t\t\t%s', x), methodHelp, 'UniformOutput', false);
            helptext  = vertcat(helptext, functionSignature, methodHelp, sprintf('\n\t\tend\n')); %#ok<AGROW> Yes it's growing, ans we have no idea how much, so no preallocating!
        end
    end
    helptext  = vertcat(helptext, sprintf('\n\tend\n'));
    % ADDING END TO CLASSDEF
    helptext  = vertcat(helptext, sprintf('\nend\n'));    
    writeFile(file, helptext);
end

function writeFunctionHelp(file)
    helptext = getHelpText(file.helpCmd);
    if isempty(helptext)
        return;
    end
    
    % get function Signature Line
    headLine = getHeadLine(file, 'function');
    if ~isempty(headLine)
        helptext = vertcat(headLine, helptext);
    end

    writeFile(file, helptext);
end


function headLine = getHeadLine(file, keyword)
    fID = fopen(file.fullpath, 'r');
    assert(fID ~= -1, 'DEPLOY:writeHelpFile:getHeadLine', 'Could not get headline because, could not read input: %s!', file.fullpath);
    headLine = '';
    while ~feof(fID)
        line = strtrim(fgetl(fID));
        if strcmp(line(1:min(length(line), length(keyword))), keyword)
            % headline is found return
            headLine = line;
            break;
        end
    end
    fclose(fID);
end

function writeFile(file, text)
    outFilename = [file.destination file.name];
    fid = fopen(outFilename,'w');
    assert(fid ~= -1, 'DEPLOY:writeHelpFile', 'Write helpfile failed, check write permission on destination!');
    fprintf(fid, '%s\n',text{:});
    fclose(fid);
end

function files = generateFileProcessList(source, destination, flags)
    [~, ~, extension] = fileparts(source);
    if ~strcmp(extension, '.m') && ~strcmp(source(end), filesep) % % not single file AND not ending on a filesep
        source = [source filesep];
    end
    if ~strcmp(destination(end), filesep)
        destination = [destination filesep];
    end
    dircontent = dir(source);    
    
    % EXCLUDE LIST
    if numel(dircontent) > 1 % not only a single file
        excludes = cellfun(@(x) feval(@(y) {y.name}, dir([source x])), flags.excludes, 'UniformOutput', false); % a list of all files that are in the ignore list
    else
        excludes = cellfun(@(x) feval(@(y) {y.name}, dir([x])), flags.excludes, 'UniformOutput', false); %#ok<NBRAK> % a list of all files that are in the ignore list
    end
    excludes = [excludes{:}, '.', '..'].';
    
    % INCLUDE LIST    
    if numel(dircontent) > 1 % not only a single file
        includes = cellfun(@(x) feval(@(y) {y.name}, dir([source x])), flags.includes, 'UniformOutput', false); % a list of all files that are in the ignore list    
        includes = [includes{:}].';
    else
        includes = source;
    end
    
    dircontent      = dircontent(logical(cellfun(@(x) ~any(strcmp(x, excludes)), {dircontent.name}).')); % first remove the ones from the ignore list
    directories     = dircontent(logical([dircontent.isdir] == 1));
    includefiles    = dircontent(logical(cellfun(@(x) any(strcmp(x, includes)), {dircontent.name}).')); % remove the ignore list from the list of files to process
    dircontent      = cat(1, directories, includefiles);
    
    
    files = struct('name', {}, 'source', {}, 'destination', {}, 'fullpath', {}, 'isMFile', {}, 'base', {}, 'helpCmd', {}, 'generateHelp', {});
    for i = 1:numel(dircontent)
        if dircontent(i).isdir % if is directory and one of the below conditions    
            if flags.recursive ... recursive
                    || strcmp(dircontent(i).name(1), '+') ... packages will always be recursivly handled
                    || strcmp(dircontent(i).name(1), '@') ... starts with an @
                    || (flags.parentClassFolder && strcmp(dircontent(i).name, 'private')) % parent folder started with an @ and now we  need to process the private folder
                if strcmp(dircontent(i).name(1), '@')
                    flags.parentClassFolder = true;
                else
                    flags.parentClassFolder = false;
                end
                pfiles = generateFileProcessList([source dircontent(i).name filesep], [destination dircontent(i).name filesep], flags);
                files = cat(1, files, pfiles);
            end
        else % not directory, a file to process
            if ~mislocked(dircontent(i).name)
                file.name           = dircontent(i).name;
                if strcmp(file.name, source)
                    file.source     = [pwd filesep];
                else
                    file.source     = source;
                end
                file.destination    = destination;
%                 destPath            = '';
                file.fullpath       = [file.source file.name];
                file.isMFile        = false;
                file.base           = file.source;
                file.helpCmd        = file.name;
                file.generateHelp   = false;
                
                [~, name, extension] = fileparts(file.fullpath);
                % IF WE HAVE AN mfile we need some further investigations:
                if strcmp(extension, '.m') % check if it's an m-file
                    file.isMFile        = true;
                    file.generateHelp   = true; % normaly generate help file, turning it off on specific files
                    
                    basePath            = file.source;
                    
                    helpCmd             = name;
                    
                    
                    privatePattern      = sprintf('\\%s@(\\w*)\\%sprivate\\%s', filesep, filesep, filesep);
                    
                    % CHECK IF IS A PRIVATE METHOD OF A CLASS FOLDER
                    if ~isempty(regexp(file.source, privatePattern, 'ONCE'))
                        file.generateHelp   = false;
                    end
                    
                    % CHECK IF IS A CLASS FOLDER, FLAG CLASS FILE FOR
                    % PROCESSING
                    class = getClassName(file.source);
%                     if ~isempty(regexp(file.source, classpattern, 'ONCE')) % path containing a @class folder
%                         class = regexp(file.source, classDirPattern, 'match');
                    if ~isempty(class)
                        if ~strcmp(name, class) % is public method
                            file.generateHelp   = false;
                        end
%                         className   = class{:};
                        basePath    = strrep(basePath, ['@' class filesep], '');
                        helpCmd     = class;
%                         if isempty(regexp(destination, classpattern, 'ONCE'))
%                             destPath    = cat(2, destPath, '@', className, filesep);
%                         end
                    end
                    
                    % CHECK IF IS A PACKAGE FOLDER, FLAG PACKAGE FILE FOR
                    % PROCESSING
                    package = getPackageName(file.source);
                    if ~isempty(package)
%                     if ~isempty(regexp(file.source, packagepattern, 'ONCE')) % path containing a +package Folder
%                         package = regexp(file.source, packageDirPattern, 'match');
                        basePath        = strrep(basePath, ['+' package filesep], '');
                        helpCmd         = [package '.' helpCmd]; %#ok<AGROW> Not true, helpCmd is reseted on line 78;
%                         if isempty(regexp(destination, packagepattern, 'ONCE'))
%                             destPath    = cat(2, '+', packageName, filesep, destPath);
%                         end
                    end
                    file.helpCmd        = helpCmd;
                    file.base           = basePath;                    
                end
%                 file.destination        = cat(2, destination, filesep, destPath);
                files = cat(1, files, file);
            else
                warning('deploy:generateFileProcessList:lockedFile', ...
                    ['File: ' source dircontent(i).name ' was not added, because file is locked!']);
            end
        end
    end

end

function packageName = getPackageName(path)
    packageDirPattern   = sprintf('(?<=\\+)(.*?)(?=\\%s)', filesep);
    packageName = regexp(path, packageDirPattern, 'match');
    if ~isempty(packageName)
        packageName = packageName{:};
    end
end

function className = getClassName(path)
    classDirPattern     = sprintf('(?<=@)(.*)(?=\\%s)', filesep);    
    className = regexp(path, classDirPattern, 'match');
    if ~isempty(className)
        className = className{:};
    end
end
