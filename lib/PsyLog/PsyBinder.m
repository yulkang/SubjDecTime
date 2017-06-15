classdef PsyBinder < handle
    % PSYBINDER Performs time-consuming calculations only on new entries.
    
    properties
        binderFile  = '';   % Where results will be saved.
        
        fUpdatedIDs = @(me) {};     % Gives updated IDs, use e.g., dirCell().

        % IDs: false after recalcBinder. c: false after saveBinder.
        updated  = struct('c', false, 'IDs', false);
        
        % success: whether error occured during calculation.
        success  = [];
        
        % calcInParallel: to use parfor or not.
        calcInParallel = false;
    end
    
    properties (SetObservable, AbortSet)
        IDs    = {}; % 1xN cell vector of string IDs. e.g., file names.
    end
    
    properties (SetObservable)
        c      = {}; % 1xN cell vector of results of calculation.
    end
    
    methods (Abstract)
        res = fCalc(me, ID);    % Given a string ID, calculate result.
    end
    
    methods
        function me = PsyBinder(cBinderFile, IDorFUpdatedIDs, varargin)
            % me = PsyBinder(binderFile, IDorFUpdatedIDs, ...)
            % 
            % binderFile  : If the file exists, other arguments are ignored.
            % fCalc       : Given a string ID, calculate result.
            % IDs         : 1xN cell vector of string IDs. e.g., file names.
            % fUpdatedIDs : Function that gives updated IDs, use e.g., dirCell().
    
            %% binderFile
            if ~exist('cBinderFile', 'var') || isempty(cBinderFile)
                cBinderFile = 'binder.mat';
            end
            
            % If binderFile exists, other arguments are ignored.
            if exist(cBinderFile, 'file')
                fprintf('%s exists: ', cBinderFile);
                me = PsyBinder.loadBinder(cBinderFile);
                
                % Nothing else to do.
                return;
            end
            
            %% Set binderFile and listeners
            me.binderFile = cBinderFile;
            me.setListener;
            
            %% Other fields
            varargin2fields(me, varargin);
            
            %% ID or fUpdatedIDs
            switch class(IDorFUpdatedIDs)
                case 'function_handle'
                    me.fUpdatedIDs = IDorFUpdatedIDs;
                    me.IDs = me.fUpdatedIDs();
                    
                case 'cell'
                    me.IDs = IDorFUpdatedIDs;
                    
                otherwise 
                    error('Please provide a function handle or a cell array!');
            end
            
            if inputYN('Do you want to process %d entries for %s now? (y/n) ', ...
                    numel(me.IDs), me.binderFile)
                
                recalcBinder(me);
            else
                fprintf('Process entries with Binder.recalcBinder later.\n');
            end
        end
        
        
        function saveBinder(me, onlyIfUpdated)
            % saveBinder(me, [onlyIfUpdated=1])
            %
            % onlyIfUpdated
            %   0   : Always save.
            %   1   : Ask if not updated.
            %   2   : Skip if neither file list nor the contents is updated.
            
            if ~exist('onlyIfUpdated', 'var')
                onlyIfUpdated = 1;
            end
            
            if ~me.updated.IDs && ~me.updated.c
                
                fprintf(['Neither the file list nor the contents ' ...
                         '(.c) are updated! ']);
                
                switch onlyIfUpdated
                    case 1
                        if ~inputYN('Save anyway? (y/n) ')
                            return;
                        end
                    case 2
                        fprintf('Skipping. To save anyway, call saveBinder(0).\n');
                        return;
                    case 0
                        fprintf('Saving anyway..\n');
                end
                
            elseif me.updated.IDs && ~me.updated.c
               
                fprintf('File list is updated but the contents are not! ');
                
                switch onlyIfUpdated
                    case {1,2}
                        if inputYN('Update contents before saving? (y/n)')
                            me.updateBinder;
                        end
                    case 0
                        fprintf(['Saving anyway.. To update before saving, ' ...
                                 'call saveBinder(1) or updateBinder.\n']);
                end
            end
            
            Binder = me; %#ok<NASGU>
            
            stSec = GetSecs;
            fprintf('Saving Binder to %s ... ', me.binderFile);
            
            % Now that the contents are saved, turn the flag down.
            % Note that updated.IDs are set to false in recalcBinder,
            % which is called also by updateBinder.
            me.updated.c     = false;
            
            save(me.binderFile, 'Binder');
            fprintf('Saved in %1.2f seconds.\n', GetSecs - stSec);
        end
        
        
        function [upToDate, compRes, cUpdatedIDs] = isIDsUpToDate(me, verbose)
            % [upToDate, compRes, IDsFromFilt] = isIDsUpToDate(me, verbose = false)
            
            if ~exist('verbose', 'var'), verbose = false; end
            
            cUpdatedIDs  = me.fUpdatedIDs();
            
            [anyChange, ~, ~, compRes] = strcmpShow(me.IDs, cUpdatedIDs, verbose);
            upToDate = ~anyChange;
        end
        
        
        function updateBinder(me, compRes, cUpdatedIDs)
            % updateBinder(me, [compRes])
            % 
            % Checks update in file list compared to the filter.
            % Calcs added IDs and reorder existing ones if necessary.
            
            if ~exist('compRes', 'var') || ~exist('cUpdatedIDs', 'var')
                [~, compRes, cUpdatedIDs] = me.isIDsUpToDate;
            end
            
            toReorder   = find(~isnan(compRes));
            toCalc      = find(isnan(compRes));
            
            % Reorder
            me.c(toReorder) = me.c(compRes(toReorder));
            me.success(toReorder) = me.success(compRes(toReorder));
            
            % Delete
            if numel(me.c) > numel(cUpdatedIDs)
                me.c = me.c(1:numel(cUpdatedIDs));
                me.success = me.success(1:numel(cUpdatedIDs));
            end
                
            % Calc
            me.IDs = cUpdatedIDs;
            me.recalcBinder(me.IDs(toCalc), toCalc);
        end
        
        
        function recalcBinder(me, IDs, toIx)
            % RELOADBINDER  Calcs all IDs, if unspecified.
            %
            % recalcBinder(me, IDs, [toIx=all])
            % 
            % In pseudocode, 
            % me.c{toIx} = load(IDs{:})
            
            stSec = GetSecs;
            if ~exist('IDs', 'var')
                IDs = me.IDs;
            end
            
            nCalc = length(IDs);
            
            if ~exist('toIx', 'var')
                me.c = cell(1, nCalc);
                me.success = true(1, nCalc);
                toIx  = 1:nCalc;
            else
                if max(toIx) > numel(me.c)
                    me.c{max(toIx)} = [];
                end
                
                me.success(toIx) = true;
            end
            
            if me.calcInParallel
                cC       = cell(1, nCalc);
                cSuccess = true(1, nCalc);
                cFCalc   = me.fCalc;
                
                parfor iCalc = 1:nCalc
                    fprintf('Calculating %s as entry #%d (%d/%d)...', ...
                            IDs{iCalc}, toIx(iCalc), iCalc, nCalc);
                    try
                        cC{iCalc} = cFCalc(me, IDs{iCalc}); %#ok<PFBNS>
                        fprintf('done.\n');

                    catch lastErr
                        cC{iCalc} = [];
                        cSuccess(iCalc) = false;

                        warning('Error calculating %s: %s\n', ...
                            IDs{iCalc}, lastErr.message);
                    end
                end
                
                me.c(toIx) = cC;
                me.success(toIx) = cSuccess;
                
            else 
                for iCalc = 1:nCalc
                    cIx = toIx(iCalc);

                    fprintf('Calculating %s as entry #%d (%d/%d)...', ...
                            IDs{iCalc}, cIx, iCalc, nCalc);
                    try
                        me.c{cIx} = me.fCalc(IDs{iCalc});
                        fprintf('done.\n');

                    catch lastErr
                        me.c{cIx}       = [];
                        me.success(cIx) = false;

                        warning('Error: %s\n', lastErr.message);
                    end
                end
            end
            
            % Now that IDs are calculated, turn the flag down.
            me.updated.IDs = false;
            
            fprintf('Calculated in %1.2f seconds.\n', GetSecs - stSec);
        end
        
        
        function setListener(me)
            addlistener(me, 'c',   'PostSet', @setUpdated);
            addlistener(me, 'IDs', 'PostSet', @setUpdated);
        end
        
        
        function res = ix(me, ID)
            % res = ix(me, ID)
            
            res = strcmpfinds(ID, me.IDs);
        end
    end        
    
    
    methods (Static)
        function me = loadBinder(cBinderFile)
            % me = loadBinder(binderFile)
            
            stSec = GetSecs;
            fprintf('Loading Binder from %s ...', cBinderFile);
            load(cBinderFile, 'Binder');
            fprintf('Loaded in %1.2f seconds.\n', GetSecs - stSec);
            
            me = Binder;
                        
            % In case the file is moved, should save to the moved location.
            me.binderFile = cBinderFile;            

            % In case the way to listening to the properties change,
            % should listen in the updated way.
            me.setListener;
            
            fprintf('Looking for updates..\n');
            [upToDate, compRes, cUpdatedIDs] = me.isIDsUpToDate(true);
            
            if ~upToDate
                fprintf('Discrepancy in file lists found!\n');
                
                if inputYN('Update now? (y/n) ')
                    me.updateBinder(compRes, cUpdatedIDs);
                end
            end 
        end
    end
end