classdef PsyRStream < handle
    properties
        rStream     = [];
        randAlg     = 'mlfg6331_64';
        rSeed       = [];
    end
    
    methods
        function me = PsyRStream(varargin)
            if nargin > 0
                me.initRStream(varargin{:});
            end
        end
        
        function initRStream(me, cRSeed, varargin)
            % initRStream(me, cRSeed)
            
            varargin2fields(me, varargin);
            
            if isempty(cRSeed)
                if isempty(me.rStream) || isempty(get(me.rStream, 'Seed'))
                    cRSeed = 'shuffle';
                else
                    cRSeed = 'reset';
                end
            end            
            
            switch cRSeed
                case 'reset'
                    reset(me.rStream);
                    me.rSeed = get(me.rStream, 'Seed');

                case 'shuffle'
                    pSeed = get(me.rStream, 'Seed');
                    if isempty(pSeed)
                        cRSeed = sum(clock*1e6);
                    else
                        cRSeed = 'shuffle';
                    end
                        
                    me.rStream = RandStream(me.randAlg, 'Seed', cRSeed);
                    me.rSeed = get(me.rStream, 'Seed');
                    
                    fprintf('%s''s rSeed: %d -(shuffle)-> %d\n', me.tag, ...
                            pSeed, me.rSeed);
                    
                otherwise
                    me.rSeed = cRSeed;
                    me.rStream = RandStream(me.randAlg, 'Seed', cRSeed);
            
            end
        end
        
        
        function me2 = copyRStream(me)
            me2 = copyFields(PsyRStream, me);
            
            me2.rStream = RandStream(me.randAlg, 'Seed', me.rSeed);
            me2.rStream.State = me.rStream.State;
        end
    end
end