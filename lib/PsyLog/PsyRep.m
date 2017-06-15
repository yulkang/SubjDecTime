classdef PsyRep < handle
    % PSYREP  Repertoire.
    
    properties
        v      % nRepertoire x nParam numerical or cell matrix.
        nDrawn % number of draw happened for each repertoire.
        
        names   % Names of the params. If nonempty, sample() returns a struct.
        history % Which repertoire was sampled on each draw.
        undrawn % Whether the draw was undrawn.
        drawID  % Cell vector of ID given to each draw. Usually the trial's ID.
        
        nAttempt % Total number of draw, whether it was undrawn or not.
        
        % nOrig:
        % When replace = true:
        %   total number of draw allowed for each repertoire.
        % When replace = false:
        %   ones(nRep, 1) * expected number of draw for each repertoire.
        %   used only for 
        nOrig
        
        replace = true;
        
        r = PsyRStream;
    end
    
    properties (Dependent)
        nLeft
        nRep
        nParam
    end
    
    methods
        function me = PsyRep(varargin)
            if nargin > 0, init(me, varargin{:}); end
        end
        
        
        function init(me, v, names, nTot, varargin)
            if ~exist('nTot', 'var'), nTot = 1; end
            if exist('names', 'var'), me.names  = names; end
            
            varargin2fields(me, varargin);
            
            me.v        = factorize(v);
            
            me.nOrig    = ones(me.nRep, 1) .* nTot;
            me.nDrawn   = zeros(me.nRep, 1);
            
            me.nAttempt = 0;
            
            me.history  = nan(sum(me.nOrig), 1);
            me.undrawn  = false(sum(me.nOrig), 1);
            me.drawID   = cell(sum(me.nOrig), 1);
        end
        
        
        function [samp iSamp] = draw(me, ID)
            % samp = draw(me)
           
            if me.replace
                iSamp = ceil(rand(me.r.rStream, 1) * me.nRep);
                
            else
                iSamp = find(cumsum(me.nLeft) ...
                           < ceil(rand(me.r.rStream, 1) * sum(me.nLeft)), ...
                           1, 'first');
            end
            
            me.nDrawn(iSamp)         = me.nDrawn(iSamp) + 1;
            me.nAttempt              = me.nAttempt + 1;
            
            me.history(me.nAttempt)  = iSamp;
            me.undrawn(me.nAttempt)  = false;
            
            if ~exist('ID', 'var'), ID = sprintf('%d', me.nAttempt); end
            me.drawID{me.nAttempt}  = ID;
            
            if isempty(me.names)
                samp = me.v(iSamp,:);
            else
                samp = cell2struct(me.v(iSamp,:), me.names, 2);
            end
        end
        
        
        function add(me, varargin) % TODO: make init to use this.
        end
        
        
        function undraw(me, samp)
            if ~exist('samp', 'var') || isempty(samp)
                % undraw the last one.
                me.undrawn(me.nAttempt) = true;
                me.nDrawn(me.history(me.nAttempt)) = ...
                    me.nDrawn(me.history(me.nAttempt)) - 1;
                
            % May extend to the following cases, if necessary.
%             elseif ischar(samp) % draw ID
%                 
%                 
%             elseif isnumeric(samp) % iSamp
%                 
%                 
%             elseif iscell(samp) % samp
%                 
%                 
%             elseif isstruct(samp) % samp
                
            else
                error('Unparseable samp');
            end
        end
        
        
        function n = get.nLeft(me)
            n = me.nOrig - me.nDrawn;
        end
        
        
        function n = get.nRep(me)
            n = size(me.v,1);
        end
        
        
        function n = get.nParam(me)
            n = size(me.v, 2);
        end
    end
end