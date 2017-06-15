classdef testCellArray < PsyDeepCopy
    properties
        names
        ns
        maxNs
        vs
        t
        appendDims
        srcs
    end
    
    
    methods
        function init(me, cNames, cMaxNs, cSrcs, cVs, cAppendDims)
            me.names = cNames;
            me.maxNs = cMaxNs;
            me.ns    = zeros(1, length(cNames));
            me.srcs  = cSrcs;
            
            me.appendDims = cAppendDims;
            
            vals = find(strcmp('val', cSrcs));
            
            for ii = vals
                toRep = ones(1,3);
                toRep(me.appendDims(ii)) = me.maxNs(ii);
                
                me.vs{ii}    = repmat(cVs{ii}, toRep);
                
                me.t{ii}     = nan(1, me.maxNs(ii));
            end
        end
        
        
        function add(me, names, vs, t)
            ix = zeros(1, length(names));
            
            for ii = 1:length(names)
                ix(ii) = find(strcmp(names{ii}, me.names));
            end
            
            me.ns(ix)   = me.ns(ix) + 1;
            cNs         = me.ns;
            
            %% val
            vals        = strcmp('val', me.srcs);
            cAppendDims = me.appendDims;
            
            for ii = find(vals & (cAppendDims == 1))
                me.t{ii}(cNs(ii)) = t;
                me.vs{ii}(cNs(ii),:) = vs{ii};
            end
            
            
            for ii = find(vals & (cAppendDims == 2))
                me.t{ii}(cNs(ii)) = t;
                me.vs{ii}(:,cNs(ii)) = vs{ii};
            end
            
            
            for ii = find(vals & (cAppendDims == 3))
                me.t{ii}(cNs(ii)) = t;
                me.vs{ii}(:,:,cNs(ii)) = vs{ii};
            end
            
            %% prop
            props       = strcmp('prop', me.srcs);
            
            for ii = find(props & (cAppendDims == 1))
                me.t{ii}(cNs(ii)) = t;
                me.vs{ii}(cNs(ii),:) = vs{ii};
            end
            
            
            for ii = find(props & (cAppendDims == 2))
                me.t{ii}(cNs(ii)) = t;
                me.vs{ii}(:,cNs(ii)) = vs{ii};
            end
            
            
            for ii = find(props & (cAppendDims == 3))
                me.t{ii}(cNs(ii)) = t;
                me.vs{ii}(:,:,cNs(ii)) = vs{ii};
            end
            
%                 switch me.appendDims(ii)
%                     case 1
%                     case 2
%                     case 3
%                 end
%             end
        end
        
        
        function addDirect(me, ix, vs, t)
            me.ns(ix)   = me.ns(ix) + 1;
            cNs         = me.ns;
            
            vals        = strcmp('val', me.srcs);
            cAppendDims = me.appendDims;
            
            for ii = find(vals & (cAppendDims == 1))
                me.t{ii}(cNs(ii)) = t;
                me.vs{ii}(cNs(ii),:) = vs{ii};
            end
            
            
            for ii = find(vals & (cAppendDims == 2))
                me.t{ii}(cNs(ii)) = t;
                me.vs{ii}(:,cNs(ii)) = vs{ii};
            end
            
            
            for ii = find(vals & (cAppendDims == 3))
                me.t{ii}(cNs(ii)) = t;
                me.vs{ii}(:,:,cNs(ii)) = vs{ii};
            end
            
%                 switch me.appendDims(ii)
%                     case 1
%                     case 2
%                     case 3
%                 end
%             end
        end

    end
end