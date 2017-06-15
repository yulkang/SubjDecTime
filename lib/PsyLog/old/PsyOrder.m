classdef PsyOrder
    properties
        str = sprintf('\n');
    end
    
    methods
        function me = PsyOrder(varargin)
            % Order = PsyOrder(entry1, [entry2, ..])
            %
            % : Creates a PsyOrder object with entries that are initially on,
            %   in the specified order. Entry names are strings that should be unique within
            %   a PsyOrder object. They should follow the same rule as MATLAB variables,
            %   and should not be either 'st_' or 'en_'.
            %            
            % Order = PsyOrder;
            %
            % : Creates an empty PsyOrder object.
            %
            % See help PsyOrder.init.
            
            if nargin > 0
                me = me.on(varargin{:});
            end
        end
        
        
        function disp(me)
            % First things appear at the top.
            
            for ii = 1:numel(me)
                disp(me(ii).str);
            end            
        end
        
        
        function me = on(me, varargin)
            % Order = Order.on([order,] entry1, [entry2, ...])
            % 
            % Turns on the entry, at the designated position.
            %
            % order     ''        : [entry1, entry2, ..] comes last.
            %
            %           '^entryP' : [entry1, entry2, ..] comes next to entryP.
            %           '_entryP' : [entry1, entry2, ..] comes previous to entryP.
            %
            %           '^en_'    : [entry1, entry2, ..] comes last.
            %           '_st_'    : [entry1, entry2, ..] comes first.
            %
            % entry1, ..          
            %
            % : Entry names are strings that should be unique within
            %   a PsyOrder object. They should follow the same rule as MATLAB variables,
            %   and should not be either 'st_' or 'en_'.
            
            switch varargin{1}(1)
                case '^' % next to
                    entryFrom = 2;
                    me = me.off(varargin{entryFrom:end});
                    
                    if strcmp(varargin{1}(2:end), 'en_')
                        insNextTo = length(me.str);
                    else
                        insNextTo = strfind(me.str, [me.str(1) ...
                                                     varargin{1}(2:end) ...
                                                     me.str(1)]) ...
                                  + length(varargin{1});
                    end
                    
                    

                case '_' % previous to
                    entryFrom = 2;
                    me = me.off(varargin{entryFrom:end});
                    
                    if strcmp(varargin{1}(2:end), 'st_')
                        insNextTo = 1;
                    else
                        insNextTo = strfind(me.str, [me.str(1) ...
                                                     varargin{1}(2:end) ...
                                                     me.str(1)]);
                    end
                    
                otherwise
                    if isempty(varargin{1})
                        entryFrom = 2;
                    else
                        entryFrom = 1;
                    end
                    me = me.off(varargin{entryFrom:end});
                    
                    insNextTo = length(me.str); 
            end
            
            me.str = [me.str(1:(insNextTo-1)) ...
                      sprintf('\n%s', varargin{entryFrom:end}) ...
                      me.str(insNextTo:end)];
        end
        
        
        function me = off(me, varargin)
            % Order = Order.off(entry1, [entry2, ...]);
            
            for cEntry = varargin
                delFrom = strfind(me.str, [me.str(1) cEntry{1} me.str(1)]);
                
                if ~isempty(delFrom)
                    delTo = delFrom + length(cEntry{1}) + 2;
                    me.str = me.str([1:delFrom, delTo:end]);
                end
            end
        end
        
        
        function nam = cell(me)
            % nam = Order.cell;
            %
            % nam   : a cell arrays of strings of entry names
            %         in order, specified by Order.on and Order.off.
            %
            % See also PsyOrder.on and PsyOrder.off.
            %
            % Use PsyOrder.cellfun to apply functions to all 'on' entries.
            
            sep     = find(me.str == me.str(1));
            nSep    = length(sep);
            nam     = cell(1, nSep-1);
            
            for iSep = 1:(nSep-1)
                nam{iSep} = me.str((sep(iSep)+1) : (sep(iSep+1)-1));
            end
        end
        
        
        function me2 = copyobj(me)
            me2 = struct2obj(PsyOrder, me);
        end
    end
end