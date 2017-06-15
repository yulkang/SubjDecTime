classdef PsyFilesSub < MatFileUnsealed
    properties (SetAccess = protected)
        files_ = {};
    end
    
    methods
        function me = PsyFilesSub(name, filter, varargin)
            % me = PsyFilesSub(name, filter, options)
            % 
            % name   : Name of the merged file.
            %          If the file already exists, defaults to open read-only.
            %          Set options as 'Writable', true, to enable writing.
            %          If the file doesn't exist, creates one.
            %          
            % filter : Filter string, file name, or file list.
            %
            % options: As in matfile(). See help matfile for more information.
            
            me = me@MatFileUnsealed(name, varargin{:});
            
            % If filter is unspecified,
            if (nargin < 2)  ||  isempty(filter)
                
                % And if the file is new,
                if isempty(allVars(me))
                    
                    % Load *.mat files into the new file.
                    filter = '*.mat';
                    replaceFiles(me, filter);
                end
                
            % Create & merge files, or replace existing files.
            else
                replaceFiles(me, filter);
            end
        end
        
        
        function disp(me)
            % Display merged files, followed by information from MatFileUnsealed.
            
            fprintf('  Merged file:\n');
            fprintf('    %s\n', me.Properties.Source);
            fprintf('\n');
            
            disp@MatFileUnsealed(me);
            
%             fprintf('  Writable: %s\n', tfStr(me.Properties.Writable));
%             fprintf('\n');
%             
%             fprintf('  Sources:\n');
%             if isempty(me.files_)
%                 fprintf('    (none)\n');
%             else
%                 cfprintf('    %s\n', me.files_);
%             end            
%             
%             if feature('hotlinks')
%                 fprintf('\n  <a href="matlab:methods %s">Methods</a>\n',class(me))
%             end
%             fprintf('\n')
        end
        
        
        function res = subsref(me, S)
            % me.files_ and me.Properties will return the respective property.
            %
            % Otherwise, me.(variableName) will try to load the relevant variable.
            % 
            % Note that you should use functionName(me, ...) instead of 
            % me.functionName(...) if you want to run function, rather than 
            % to load the variable.
            
            if strcmp(S(1).type, '.') && strcmp(S(1).subs, 'files_')
                res = builtin('subsref', me, S);
            else
                res = subsref@MatFileUnselaed(me, S);
            end
        end
        
        
        function subsasgn(me, S, V)
            % me.files_ = value and me.Properties = value
            % will set the respective property.
            %
            % Otherwise, me.(variableName) = value 
            % will try to save the relevant variable.
            
            if strcmp(S(1).type, '.') && strcmp(S(1).subs, 'files_')
                builtin('subsref', me, S, V);
            else
                subsasgn@MatFileUnsealed(me, S, V);
            end
        end
        
        
        function replaceFiles(me, filter)
            % replaceFiles(me, filter)
            %
            % filter: filter string, file name, or file list.
            
            if nargin < 2
                filter = '*.mat';
            end
            
            setFiles(me, uigetfileCell(filter, 'MultiSelect', 'on'));
        end
        
        
        function addFiles(me, filter)
            % addFiles(me, filter)
            %
            % filter: filter string, file name, or file list.
            
            if nargin < 2
                filter = '*.mat';
            end
            
            setFiles(me, [me.files_, ...
                          uigetfileCell(filter, 'MultiSelect', 'on')]);
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
                        for cVar = allVars(me)
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
            end
            
            for iFile = ix
                cFile = load(me.files_{iFile});

                for cVar = fieldnames(cFile)'
                    subsasgn(me, ...
                        substruct('.' , cVar{1}, ...
                                  '()', {1, iFile}), ...
                             {cFile.(cVar{1})});
                end
            end
        end
        
        
        function res = allVars(me)
            % All variable names.
            %
            % res = allVars(me)
            
            res = setdiff(properties(me), {'files_', 'Properties'});
        end
    end
end