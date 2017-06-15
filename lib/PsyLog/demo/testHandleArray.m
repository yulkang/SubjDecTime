classdef testHandleArray < PsyDeepCopy
    properties
        name
        n
        maxN
        v
        t
        appendDim
        src
    end
    
    
    methods
        function init(me, names, maxNs, srcs, vs, appendDims)
            for ii = 1:length(names)
                me(ii).name = names{ii};
                me(ii).maxN = maxNs(ii);
                me(ii).src  = srcs{ii};
                me(ii).appendDim = appendDims(ii);
                
                toRep = ones(1,3);
                toRep( me(ii).appendDim ) = me(ii).maxN;
                
                me(ii).v    = repmat(vs{ii}, toRep);
                
                me(ii).n    = 0;
            end
        end
        
        
        function add(me, names, vs, t)
            cNames = {me.name};
            
            for ii = 1:length(names)
                cMe = me( strcmp(names{ii}, cNames ));
                
                cMe.n = cMe.n + 1;
                cMe.t(cMe.n) = t;
                
                if strcmp(cMe.src, 'val')
                    switch cMe.appendDim
                        case 1
                            cMe.v( cMe.n,: ) = vs{ii};

                        case 2
                            cMe.v( :,cMe.n ) = vs{ii};

                        case 3
                            cMe.v( :,:,cMe.n ) = vs{ii};
                    end
                end
            end
        end
    end
end