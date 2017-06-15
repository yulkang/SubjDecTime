classdef PsyDeepCopy2 < matlab.mixin.Copyable
    % PsyDeepCopy2: Recursive copy of the reference links.
    %               Circular links are handled properly.
    % matlab.mixin.Copyable: Shallow copy. Use only when no child is handle.
    %
    % Use Copyable only when the object has no Handle property at all.
    % Use Handle only when the object is never copied at all.
    % In short, use PsyDeepCopy whenever uncertain.
    %
    % In each PsyDeepCopy object, 'parent' should be the direct parent.
    % Avoid referring to multiple steps up the tree., 
    %   e.g., me.(me.parentName).(me.parent.parentName),
    % because it depends on the context the object is used.
    %
    % Refer to the root, or provide the required Handle as an argument.
    
    
    properties
        % Property name that should be passed on across multiple generations.
        %
        % Be careful not to include the handle to the root in
        % obj.(deepCpNames), obj.(deepCpCellNames){}, or 
        % obj.(deepCpStructNames).() !
        rootName            = '';
        
        % Property name that indicates the parent. The name or the property
        % itself can be empty.
        %
        % Be careful not to include the handle to the parent in
        % obj.(deepCpNames), obj.(deepCpCellNames){}, or 
        % obj.(deepCpStructNames).() !
        parentName          = '';
        
        % Self identifier
        tag                 = '';
        
        % Copied self
        copiedSelf          = [];
    
        %% Deep copied handles
        % Row cell vector of names of the properties that are matlab.mixin.Copyable
        % or its subclasses.
        deepCpNames         = {};
        
        % Properties that are cell arrays of Copyables.
        deepCpCellNames     = {};
        
        % Properties that are struct with fields of Copyables.
        deepCpStructNames   = {};
        
        %% Handles that are circular. (outside the tree.) Not visited during init or del.
        %  PsyDeepCopy2: All PsyDeepCopy handles are retained.
        tempNames           = {};
        tempCellNames       = {};
        tempStructNames     = {};
        
        %% The rest of the handles will be shallow-copied.
    end
    
    
    methods
        function me2 = copyTree(me, parent, root)
            
            if nargin < 2, parent = []; end
            if nargin < 3, root = [];   end
            
            me2 = linkTree(me, parent, root, 'copy');
        end
        
        
        function me2 = initTree(me, parent, root)
            
            if nargin < 2, parent = []; end
            if nargin < 3, root = [];   end
            
            me2 = linkTree(me, parent, root, 'init');
        end
        
        
        function delTree(me, parent, root)
            
            if nargin < 2, parent = []; end
            if nargin < 3, root = []; end
            
            linkTree(me, parent, root, 'del');
        end
        
        
        function [me2 link2me] = linkTree(link2me, parent, root, mode)
            % me2 = linkTree(me, parent, root, mode, link2me)
            %
            %  mode
            %--------------------------------------------------------------------
            % 'copy': Make a new copy and link new parents & root, recursively.
            %
            % 'init': Link existing parents & root recursively without copying any.
            %
            % 'del' : Delete objects in the entire tree, starting from the leaves.
            
            
            %% Whether to copy me
            switch mode
                case 'copy'
                    if isempty(link2me.copiedSelf)
                        me2 = copy(link2me);
                        link2me.copiedSelf  = me2;
                        
                        link2me = me2; % relink 'me' to 'me2'.
                        
                    else
                        link2me = link2me.copiedSelf; % relink 'me' to 'me2'.
                        
                        return;
                    end
                    
                case {'init', 'del'}
                    me2 = link2me;
                    
                otherwise
                    error('Unsupported mode: %s', mode);
            end
            
            
            %% Linking root & parent
            if strcmp(link2me.rootName, link2me.tag)
                root = me2; 
            end
            
            if ~isempty(link2me.parentName)
                if isempty(parent)
                    error('Parent is not given, although parentName is not empty!');
                else
                    me2.(link2me.parentName) = parent;
                end
            end
            
            if ~isempty(link2me.rootName)
                if isempty(root)
                    error('Root is not given, although rootName is not empty!');
                elseif ~strcmp(link2me.rootName, link2me.tag)
                    me2.(link2me.rootName) = root;
                end
            end
            
            
            %% Recursive operation
            for cDeepCp = me2.deepCpNames
                if isempty(cDeepCp{1}), continue; end
                if isa(me2.(cDeepCp{1}), 'PsyDeepCopy')                 
                    % PsyDeepCopy: recursive copy of the reference tree.
                    me2.(cDeepCp{1}) = linkTree(me2.(cDeepCp{1}), ...
                                                me2, root, mode); 
                else
                    try
                        % matlab.mixin.Copyable: Shallow copy. 
                        % Use only when no child is handle.
                        me2.(cDeepCp{1}) = copy(me2.(cDeepCp{1})); 
                    catch
                        error(['A nonempty property .%s is neither PsyDeepCopy ' ...
                               'nor matlab.mixin.Copyable!'], cDeepCp{1});
                    end
                end
            end

            for cCell = me2.deepCpCellNames
                for iCell = 1:length(me2.(cCell{1}))
                    if isempty(me2.(cCell{1}){iCell}), continue; end
                    if isa(me2.(cDeepCp{1}), 'PsyDeepCopy')                 
                        % PsyDeepCopy: recursive copy of the reference tree.
                        me2.(cCell{1}){iCell} = linkTree(me2.(cCell{1}){iCell}, ...
                                                         me2, root, mode);
                    else
                        try
                            % matlab.mixin.Copyable: Shallow copy. 
                            % Use only when no child is handle.
                            me2.(cCell{1}){iCell} = copy(me2.(cCell{1}){iCell});
                        catch
                            error(['A nonempty property .%s{%d} is neither PsyDeepCopy ' ...
                                   'nor matlab.mixin.Copyable!'], cCell{1}, iCell);
                        end
                    end
                end
            end

            for cStruct = me2.deepCpStructNames
                if isempty(me2.(cStruct{1})), continue; end
                for cField = fieldnames(me2.(cStruct{1}))'
                    if isempty(me2.(cStruct{1}).(cField{1})), continue; end
                    if isa(me2.(cDeepCp{1}), 'PsyDeepCopy')                 
                        me2.(cStruct{1}).(cField{1}) = linkTree(me2.(cStruct{1}).(cField{1}), ...
                                                                me2, root, mode);
                    else
                        try
                            me2.(cStruct{1}).(cField{1}) = copy(me2.(cStruct{1}).(cField{1}));
                        catch
                            error(['A nonempty property .%s.%s is neither PsyDeepCopy ' ...
                                   'nor matlab.mixin.Copyable!'], cStruct{1}, cField{1});
                        end
                    end
                end
            end
            
            
            %% Postprocess
            switch mode
                case 'copy'
                    % Delete temporary handles, if copyTree.
                    for cProp = me2.tempNames
                        delete(me2.(cProp{1}));
                    end
                    
                    for cCell = me2.tempCellNames
                        for iCell = 1:length(me2.(cCell{1}))
                            delete(me2.(cCell{1}){iCell});
                        end
                    end
                    
                    for cStruct = me2.tempStructNames
                        for cField = fieldnames(me2.(cStruct{1}))'
                            delete(me2.(cStruct{1})(cField{1}));
                        end
                    end
                    
                case 'del'
                    % Delee me, if delTree.
                    delete(link2me);
            end
        end
    end
end