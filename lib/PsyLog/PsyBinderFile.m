classdef PsyBinderFile < PsyBinder
    % PSYBINDERFILE Combines multiple .mat files into one using a cell array.
    
    properties
%         binderFile    = '';
        
        filt     = ''; % File filter.
        fromFile = '';
        toFile   = '';
        
        loadOpt  = {}; % Option for loading each file.
        
%         % files: false after reloadBinder. c: false after saveBinder.
%         updated  = struct('c', false, 'IDs', false);
    end
    
    methods
        function me = PsyBinderFile(cBinderFile, varargin)
            % me = PsyBinderFile(binderFile, 'filt', filter, options)
            % 
            % binderFile: If the file exists, other arguments are ignored.
            % filter : Filter string, file name, or file list.
    
            me = me@PsyBinder(cBinderFile, @(me, fName) load(fName, me.loadOpt), ...
                @(me) dirCell(me.filt, me.fromFile, me.toFile), varargin{:});
        end
        
        
        function res = getField(fieldName, uniformOutput, ix)
            % res = getField(fieldName, uniformOutput, ix)
            
            if ~exist('uniformOutput', 'var'), uniformOutput = true; end
            if ~exist('ix', 'var'), ix = 1:numel(me.c); end
            
            res = cellfun(@(c) c.(fieldName), me.c(ix), ...
                'UniformOutput', uniformOutput);
        end
    end
end