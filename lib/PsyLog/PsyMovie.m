classdef PsyMovie < PsyTextures
    properties
        fadeInFromAlpha = 0;
        fadeInToAlpha   = 1;
        fadeOutFromAlpha= 1;
        fadeOutToAlpha  = 0;
        
        fadeInFromAbsSec  = nan;
        fadeInToAbsSec    = nan;
        fadeOutFromAbsSec = nan;
        fadeOutToAbsSec   = nan;
    end
    
    
    methods
        function me = PsyMovie(varargin)
            me = me@PsyTextures(varargin{:});
            me.tag = 'Movie';
            
            me.updateOn = unionCellStr(me.updateOn, {'befDraw'});
        end
        
        function fade(me, inOut, fromAbsSec, toAbsSec, fromAlpha, toAlpha)
            % fade(me, inOut='in'|'out', fromAbsSec, toAbsSec, [fromAlpha, toAlpha])
            
            if ~any(strcmpi(inOut, {'in', 'out'}))
                error('inOut should be either ''in'' or ''out''!');
            end
            
            inOut = [upper(inOut(1)), lower(inOut(2:end))];
            
            me.(['fade' inOut 'FromAbsSec']) = fromAbsSec;
            me.(['fade' inOut 'ToAbsSec'])   = toAbsSec;
            
            if exist('fromAlpha', 'var') && exist('toAlpha', 'var')
                me.(['fade' inOut 'FromAlpha'])  = fromAlpha;
                me.(['fade' inOut 'ToAlpha'])    = toAlpha;
            end
        end
        
        function update(me, from)
            if strcmp(from, 'befDraw')
                if ~isnan(me.fadeInFromAbsSec) && ~isnan(me.fadeInToAbsSec) && ...
                    me.fadeInFromAbsSec <= me.Scr.frOnPredAbsSec && ...
                    me.fadeInToAbsSec   >= me.Scr.frOnPredAbsSec
                    
                    me.alpha = me.fadeInFromAlpha ...
                        + (me.fadeInToAlpha - me.fadeInFromAlpha) ...
                        * (me.Scr.frOnPredAbsSec - me.fadeInFromAbsSec) ...
                        / (me.fadeInToAbsSec - me.fadeInFromAbsSec);
                end
                
                if ~isnan(me.fadeOutFromAbsSec) && ~isnan(me.fadeOutToAbsSec) && ...
                    me.fadeOutFromAbsSec <= me.Scr.frOnPredAbsSec && ...
                    me.fadeOutToAbsSec   >= me.Scr.frOnPredAbsSec
                    
                    me.alpha = me.fadeOutFromAlpha ...
                        + (me.fadeOutToAlpha - me.fadeOutFromAlpha) ...
                        * (me.Scr.frOnPredAbsSec - me.fadeOutFromAbsSec) ...
                        / (me.fadeOutToAbsSec - me.fadeOutFromAbsSec);
                end
                
                me.whichImage = me.whichImage + 1;
                if me.whichImage > size(me.imageMat, 4), 
                    me.whichImage = 1; 
                end
            end
        end
        
        function [h im] = imageFr(me, fr, varargin)
            im  = me.imageMat(:,:,1:3,fr)./255;
            h   = image(im, varargin{:});
        end
        
        function [h cAll] = plotPix(me, x, y, c, varargin)
            % [h cAll] = plotPix(me, x, y, c, varargin)
            
            cAll = squeeze(me.imageMat(x,y,c,:));
            h    = plot(cAll, varargin{:});
        end
        
        function [h cAll] = plotSpTm(me, isXY, xy, c, varargin)
            % [h cAll] = plotSpTm(me, isXY = 'x'|'y', xy=(middle), c, varargin)
            
            if ~exist('isXY', 'var')
                isXY = 'x';
            end
            switch isXY
                case 'x'
                    if ~exist('xy', 'var') || isempty(xy)
                        xy = floor(size(me.imageMat,1)/2);
                    end
                    nPix = size(me.imageMat, 2);
                case 'y'
                    if ~exist('xy', 'var') || isempty(xy)
                        xy = floor(size(me.imageMat,2)/2);
                    end
                    nPix = size(me.imageMat, 1);
            end
            if ~exist('c', 'var'), c = 1; end
            
            nFr  = size(me.imageMat, 4);
            cAll = zeros(nFr, nPix);
            
            for iFr = 1:nFr
                switch isXY
                    case 'x'
                        cAll(iFr,:) = squeeze(me.imageMat(xy,:,c,iFr))';
                    case 'y'
                        cAll(iFr,:) = squeeze(me.imageMat(:,xy,c,iFr))';
                end
            end
            
            h = imagesc(cAll, varargin{:});
            xlabel(isXY);
            ylabel('frame');
            colormap gray;
            axis xy;
        end
    end
end