classdef PsyFiles < handle
    properties (SetAccess = protected)
        files_ = {};
        matfile_
    end
    
    methods
        function me = PsyFiles(name, filter, ui, varargin)
            % me = PsyFiles(name, filter, ui, options)
            % 
            % name   : Name of the merged file.
            %          If the file already exists, defaults to open read-only.
            %          Set options as 'Writable', true, to enable writing.
            %          If the file doesn't exist, creates one.
            %          
            % filter : Filter string, file name, or file list.
            %
            % options: As in matfile(). See help matfile for more information.
            
            if nargin < 3 || isempty(ui), ui = false; end
            
            me.matfile_ = matfile(name, varargin{:});
            
            % If filter is unspecified,
            if (nargin < 2)  ||  isempty(filter)
                
                % And if the file is new,
                if isempty(who(me.matfile_))
                    
                    % Load *.mat files into the new file.
                    filter = '*.mat';
                    replaceFiles(me, filter, ui);
                end
                
            % Create & merge files, or replace existing files.
            else
                replaceFiles(me, filter, ui);
            end
        end
        
        
        function disp(me)
            % Display merged files, followed by information from MatFileUnsealed.
            
            fprintf('  Merged file:\n');
            fprintf('    %s\n', me.matfile_.Properties.Source);
            fprintf('\n');
            
            disp(me.matfile_);            
        end
        
        
        function [todo, S] = preprocSubs(me, S)
            % [todo, S] = preprocSubs(me, S)
            %
            % todo: 'builtin' or 'matfile_'
            
            if ~strcmp(S(1).type, '.')
                error('Only dot indexing is allowed at first!');
            
            elseif strcmp(S(1).subs, 'files_')
                todo = 'builtin';
                
            elseif strcmp(S(1).subs, 'matfile_')
                
                if length(S) >= 2
                    todo = 'matfile_';
                    [~, S] = preprocSubs(me, S(2:end));
                
                elseif length(S) == 1
                    todo = 'builtin';
                end
                
            elseif length(S) > 2
                error('Cannot refer to contents of indexed variables!');
                
            elseif length(S) == 2
                
                if length(S(2).subs) == 1
                    S(2).subs = {1, S(2).subs{1}};
                    
                elseif ~isequal(S(2).subs{1}, 1) || length(S(2).subs) > 2
                    error('Only (n) or (1,n) is allowed!');
                end
                
                if max(S(2).subs{2}) > length(me.files_)
                    error('Use setFile() or addFile() to expand the array!');
                end
                
                todo = 'matfile_';
                
            else
                todo = 'matfile_';
            end
        end
        
        
        function res = conc(me, name, ix, dim)
            % res = conc(me, name, [ix=':'], [dim=2])
            
            if nargin < 3 || isequal(ix, ':'), ix = 1:length(me.files_); end
            if nargin < 4, dim = 2; end
            
            rCell = me.matfile_.(name)(1, ix);
            
            if dim == 2
                res = [rCell{:}];
            else
                refCell = cell(1,max(2,dim));
                refCell(setdiff(1:max(2,dim), dim)) = {1};
                
                res = cell2mat(reshape(rCell, refCell{:}));
            end
        end
        
        
        function res = subsref(me, S)
            % me.files_ and me.Properties will return the respective property.
            %
            % Otherwise, me.(variableName) will try to load the relevant variable.
            % 
            % Note that you should use functionName(me, ...) instead of 
            % me.functionName(...) if you want to run function, rather than 
            % to load the variable.
            
            [todo, S] = preprocSubs(me, S);
            
            switch todo
                case 'builtin'
                    res = builtin('subsref', me, S);
                    
                case 'matfile_'
                    res = subsref(me.matfile_, S);
            end
        end
        
        
        function me = subsasgn(me, S, V)
            % me.files_ = value and me.Properties = value
            % will set the respective property.
            %
            % Otherwise, me.(variableName) = value 
            % will try to save the relevant variable.
            
            [todo, S] = preprocSubs(me, S);
            
            switch todo
                case 'builtin'
                    builtin('subsasgn', me, S);
                    
                case 'matfile_'
                    if ~iscell(V)
                        error('Only assign a cell array!');
                    else
                        subsasgn(me.matfile_, S, V);
                    end
            end
        end
        
        
        function replaceFiles(me, filter, ui)
            % replaceFiles(me, filter, [ui = false])
            %
            % filter: filter string, file name, or file list.
            
            if nargin < 3, ui = false; end
            
            if nargin < 2
                filter = '*.mat';
            end
            
            setFiles(me, dirCell(filter, ui, 'MultiSelect', 'on'));
        end
        
        
        function addFiles(me, filter, ui)
            % addFiles(me, filter, [ui = false])
            %
            % filter: filter string, file name, or file list.
            
            if nargin < 3, ui = false; end
            
            if nargin < 2
                filter = '*.mat';
            end
            
            setFiles(me, [me.files_, ...
                          dirCell(filter, ui, 'MultiSelect', 'on')]);
        end
        
        
        function setFiles(me, list)
            % me = setFiles(me, list)
            %
            % list  : either one file name or multiple file names.
            
            prevFiles = me.files_;
            me.files_ = list;
            
            if ~isequal(prevFiles, list)
                
                pLen = length(prevFiles);
                cLen = length(me.files_);
                
                if (pLen == 0) || (cLen == pLen)
                    reload(me);
                    
                elseif cLen < pLen
                    % If the change is shortening the list,
                    if all(strcmp(me.files_, prevFiles(1:cLen)))
                        
                        % Just shrink the array.
                        for cVar = who(me.files_)
                            me.(cVar{1}) = me.(cVar{1})(1:cLen);
                        end
                    else
                        reload(me);
                    end
                
                elseif cLen > pLen
                    % If the change is appending files,
                    if all(strcmp(me.files_(1:pLen), prevFiles))
                        
                        % Just load the appended part.
                        reload(me, (pLen+1):cLen);
                    else
                        reload(me);
                    end
                end
            end
        end
        
        
        function reload(me, ix)
            % Reload indicated files in me.files_. Indices default to all files.
            %
            % reload(me, [ix])
            
            if nargin < 2
                ix = 1:length(me.files_);
            else
                ix = sort(ix);
            end
            
            if ~isempty(ix)
                nFiles   = length(me.files_);
                
                if max(ix) < nFiles
                    oldVars  = who(me.matfile_)';
                    newVars  = {};
                    
                    cMatFile = me.matfile_;

                    for iFile = ix
                        cFile = load(me.files_{iFile});
                        fprintf('Loaded %s to %d-th entry.\n', ...
                                    me.files_{iFile}, iFile);
                        
                        newVars = unionCellStr(newVars, ...
                                    setdiff(filednames(cFile)', oldVars));

                        for cVar = fieldnames(cFile)'
                            cMatFile.(cVar{1})(1, iFile) = {cFile.(cVar{1})};
                        end
                    end
                    
                    for cVar = newVars
                        cMatFile.(cVar{1})(1, nFiles) = {};
                    end
                    
                elseif max(ix) == nFiles
                
                    cMatFile = me.matfile_;

                    for iFile = ix
                        cFile = load(me.files_{iFile});
                        fprintf('Loaded %s to %d-th entry.\n', ...
                                    me.files_{iFile}, iFile);
                        
                        for cVar = fieldnames(cFile)'
                            cMatFile.(cVar{1})(1, iFile) = {cFile.(cVar{1})};
                        end
                    end
                    
                    missingAtLast = setdiff(fieldnames(cFile), who(cMatFile))';

                    for cVar = missingAtLast
                        cMatFile.(cVar{1})(1, nFiles) = {};
                    end
                    
                else
                    error('Cannot reload files not added yet!');
                end
            end
        end
    end
end