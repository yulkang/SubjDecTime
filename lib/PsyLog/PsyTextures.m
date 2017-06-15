classdef PsyTextures < PsyPTB
properties
    % MakeTexture arguments
    imageMat             = []; % (y,x,c,fr).
    
    tex                  = []; % handles.
    
    % DrawTexture arguments
    % dstRect: calculated from PsyPTB.xyPix.
    whichImage           = 1;
    
    % Fallback option when Texture is not working. alpha is not supported yet.
    usePutImage = false;
    
    % Additional properties
    alpha = 1;
end

properties (Constant)
end

methods
    function me = PsyTextures(cScr, imageMat, varargin)
        % me = PsyTextures(cScr, imageMat, varargin)
        
        me = me@PsyPTB;
        me.xyDeg = [0 0]';
        me.sizeDeg = [2.5 2.5]';
        me.commPsy = 'FillCircle';
        
        if nargin >= 1
            me.Scr = cScr;
        end
        
        if nargin >= 2
            me.init(imageMat, varargin{:});
        end
    end
    
    
    function init(me, imageMat, varargin)
        % init(me, imageMat, varargin)
        
        varargin2fields(me, varargin, true);
        
        me.copyScrInfo;
        me.initPsyProps(me.commPsy, me.color, me.xyDeg, me.sizeDeg);
        me.argsPsy2PTB;
        
        if nargin >= 2 && ~isempty(imageMat)
            if ischar(imageMat)
                imageMat = {imageMat};
            end
            
            if iscell(imageMat)
                files = imageMat;
                imageMat = [];
                
                for ii = 1:length(files)
                    imageMat = cat(4, imageMat, imread(files{ii}));
                end
            end
            
            me.imageMat = imageMat;
        end
    end
    
    
    function open(me, ix)
        % open(me, ix)
        
        if nargin < 2, ix = 1:size(me.imageMat, 4); end
        
        if ~me.usePutImage
            if isempty(me.win)
                me.win = me.Scr.win;
            end
            
            for iImage = ix
                me.tex(iImage) = ...
                    Screen('MakeTexture', me.win, me.imageMat(:,:,:,iImage));
            end
        end
    end
    
    
    function close(me, ix)
        % close(me, ix)
        if nargin < 2, ix = 1:size(me.imageMat, 4); end
        
        if ~me.usePutImage
            if islogical(ix), ix = find(ix); end
            Screen('Close', me.tex(ix));
        end
    end
    
    
    function replace(me, ix, imageMat)
        % replace(me, ix, imageMat)
        
        if isempty(ix), ix = 1:size(imageMat,4); end
        
        me.imageMat(:,:,:,ix) = imageMat;
        
        if ~me.usePutImage
            if islogical(ix), ix = find(ix); end
            Screen('Close', me.tex(ix));
            
            open(me, ix);
        end
    end
    
    
    function show(me, ix)
        if nargin >= 2 && ~isempty(ix)
            me.whichImage = ix;
        end
        show@PsyPTB(me);
    end
    
    
    function res = draw(me, c_win)
        % res = draw(me, [c_win = 1])
        if nargin < 2, c_win = me.win; end
        
        if me.usePutImage
            Screen('PutImage', c_win, me.imageMat(:,:,:,me.whichImage), ...
                me.xyPix2RectPix(me.xyPix,me.sizePix));
        else
            if length(me.whichImage) > 1 || size(me.xyPix, 2) > 1
                Screen('DrawTextures', me.win, me.tex(me.whichImage), ...
                       [], PsyPTB.xyPix2RectPix(me.xyPix, me.sizePix), ...
                       [], [], me.alpha);
            else
                Screen('DrawTexture',  me.win, me.tex(me.whichImage), ...
                       [], PsyPTB.xyPix2RectPix(me.xyPix, me.sizePix), ...
                       [], [], me.alpha);
            end
        end
        
        res = 1;
    end
    
    
    function clearImages(me)
        % Clear imageMat e.g., for saving.
        me.imageMat = [];
    end
end

methods (Static)
    function [Texture, Scr] = test(file, ixFile)
        
        if nargin < 1 || isempty(file)
            file = {
                psyLogPath('Data/PsyTextures/img1.png')
                psyLogPath('Data/PsyTextures/img2.png')
                psyLogPath('Data/PsyTextures/img3.png')
                };
        elseif ischar(file)
            file = {file};
        end
        
        if nargin < 2
            ixFile = 1;
        end
        
        %%
        Scr = PsyScr('refreshRate', 60, 'skipSyncTests', 1);
        
%         im  = [];
%         for iFile = 1:length(file)
%             im  = cat(4, im, imread(file{iFile}));
%         end
%         
%         Texture = PsyTextures(Scr, im);

        Texture = PsyTextures(Scr, file);
        Scr.addObj('Vis', Texture);
        
        %%
        Scr.open;
        Texture.open;
        
        Scr.initLogTrial;
        
        Texture.show(ixFile);
        Scr.wait('wait', @() false, 'for', 3, 'sec');
        
        Scr.closeLog;
        Texture.close;
        Scr.close;
    end
end
end