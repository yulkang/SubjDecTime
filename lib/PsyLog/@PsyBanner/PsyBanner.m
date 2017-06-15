classdef PsyBanner < PsyPTB
    properties
        txt = ' ';
        
        txtColor
        bkgColor
        
        txtSizeDeg % txtSizeDeg(1) is unused.
        txtSizePix % txtSizePix(1) is unused.
        txtRectPix % bounding box's size. [x; y].
        
        txtXYDeg
        txtXYPix
        
        sx = 'center'
        sy = 'center'
        
        vSpacing = 1;
        
        sizeXYDeg
        yMarginDeg
        
        draw_box = true;
        
        disable_clipping = true;
    end
    
    
    methods
        function me = PsyBanner(cScr, varargin)
            % Banner = PsyBanner(Scr, txt, txtColor = [255 255 255], bkgColor = [255 0 0], 
            %             xyDeg = [0 0], sizeXYDeg = 1, yMarginDeg = [0.1 0.1])
            %
            % See also: PsyBanner.init.
            
            if ~exist('cScr', 'var'), cScr = []; end
            me = me@PsyPTB(cScr);
            
            me.tag = 'Banner';
            me.xyDeg = [0 0]';
            me.txtColor = [255 255 255];
            me.bkgColor = [0 0 0];
            me.sizeXYDeg = [20 1.4];
            me.yMarginDeg = [0.3 0.3];
            
            if ~isempty(cScr)
                init(me, varargin{:});
            end
            
            initLogEntries(me, 'propCell', ...
                               {'txt', 'color', 'txtColor', 'xyDeg', 'txtSizeDeg', 'vSpacing'}, ...
                               'fr', ...
                               {blanks(20), zeros(3,1), zeros(3,1), [0;0], 0.8, 1});
        end
        
        
        function init(me, txt, txtColor, bkgColor, xyDeg, sizeXYDeg, yMarginDeg, varargin)
            % Banner.init(txt, txtColor = [255 255 255], bkgColor = [255 0 0], 
            %             xyDeg = [0 0]', sizeXYDeg = 1, yMarginDeg = [0.1 0.1]', ...)
            %
            % Give empty to leave unchanged (except for txt).
            %
            % If sizeXYDeg is a scalar, it will be sizeXYDeg(2), i.e., y-size,
            % and sizeXYDeg(1) will be set to fit the screen horizontally.
            %
            % If sizeXYDeg is a two-element vector, it will be taken as it is.
            %
            % xyDeg and sizeXYDeg will accurately determine the box's location
            % and center the text in it.
            %
            % Capital letters' vertical size will be accurately specified by 
            % sizeXYDeg(2) - sum(yMarginDeg).
            %
            % Relative offset from the top and bottom of the box are set by
            % yMarginDeg, specified as [topMargin bottomMargin]
            % to the box boundary. The sum will be accurate, but
            % the relative size of the margins will be inaccurate.
            % Still, they will have linear relationship with the actual 
            % margins. Experiment with them.
            
            global ptb_drawformattedtext_disableClipping
            
            if exist('txt',      'var')
                if isempty(txt)
                    me.txt = ' ';
                else
                    me.txt = txt;
                end
            end
            if exist('txtColor', 'var') && ~isempty(txtColor)
                me.txtColor = txtColor;
            end
            if exist('bkgColor', 'var') && ~isempty(bkgColor)
                me.bkgColor = bkgColor;
            end
            if exist('xyDeg',     'var') && ~isempty(xyDeg)
                me.xyDeg = xyDeg(:);
            end
            if exist('sizeXYDeg', 'var') && ~isempty(sizeXYDeg)
                if numel(sizeXYDeg)==1
                    me.sizeXYDeg(2) = sizeXYDeg;
                    me.sizeXYDeg(1) = round(me.Scr.info.rect(3) / me.Scr.info.pixPerDeg);
                else
                    me.sizeXYDeg = sizeXYDeg(:);
                end
            end
            if exist('yMarginDeg','var') && ~isempty(yMarginDeg),
                me.yMarginDeg = yMarginDeg; 
            end
            
            me = varargin2fields(me, varargin);
            
            % Box
            init@PsyPTB(me, 'FillRect', me.bkgColor, me.xyDeg, me.sizeXYDeg);
            
            % Text
            me.txtSizeDeg = me.sizeXYDeg(2) - sum(me.yMarginDeg);
            me.txtXYDeg   = [me.xyDeg(1); me.xyDeg(2) + diff(me.yMarginDeg) / 2];
            
            me.txtSizePix = round([0; me.txtSizeDeg * me.Scr.info.pixPerDeg]);
            me.txtXYPix   = me.Scr.deg2pix( me.txtXYDeg );
            
            oldSize = Screen('TextSize', me.Scr.info.win, me.txtSizePix(2));
            rectTxt = Screen('TextBounds', me.Scr.info.win, me.txt, 0, 0);
            Screen('TextSize', me.Scr.info.win, oldSize);
            
            ptb_drawformattedtext_disableClipping = me.disable_clipping;
            
            me.txtRectPix = vVec(rectTxt(3:4));
        end
        
        
        function show(me, varargin)
            % show(me, txt, txtColor = [255 255 255], bkgColor = [255 0 0], 
            %             xyDeg = [0 0], sizeXYDeg = 1, yMarginDeg = [0.1 0.1])
            
            if nargin>1
                init(me, varargin{:});
            end
            addLog(me, setdiff(me.names_, {'on', 'off'}), me.Scr.cFr);
            
            show@PsyVis(me);
        end
        
        
        function res = draw(me, win)
            % Draw box and text centered at Banner.txtXYPix.
            
            if nargin < 2, win = me.win; end
            
            if me.draw_box
                % Draw box
                me.draw@PsyPTB; 
            end
            
            % Draw text centered at me.txtXYPix.
            Screen('TextSize', me.win, me.txtSizePix(2));
            
            n_line  = max(nnz(me.txt == 10) + 1, 1); % 10 == double(sprintf('\n'))
            y_scale = n_line * me.vSpacing;
            
            wxy = [me.xyPix(:)' - me.sizePix(:)' .* [1, y_scale], ...
                   me.xyPix(:)' + me.sizePix(:)' .* [1, y_scale]];
            
            if ischar(me.sx), c_sx = me.sx; else c_sx = me.sx + wxy(1); end
            if ischar(me.sy), c_sy = me.sy; else c_sy = me.sy + wxy(2); end
            
            DrawFormattedText(win, me.txt, c_sx, c_sy, me.txtColor, ...
                [], [], [], me.vSpacing, [], ... [0 0 1920 1080]); ...
                wxy);
                
%             disp( ...
%                 [me.xyPix(:)' - me.sizePix(:)', ...
%                  me.xyPix(:)' + me.sizePix(:)']);
            
%             oldSize = Screen('TextSize', me.win, me.txtSizePix(2));
%             Screen('DrawText', me.win, me.txt, ...
%                 me.txtXYPix(1)-me.txtRectPix(1)/2, me.txtXYPix(2)-me.txtRectPix(2)/2, ...
%                 me.txtColor);
%             Screen('TextSize', me.win, oldSize);            

            res = 1;
        end
        
        h = plot(me, relS);
    end
    
    methods (Static)
        function [Banner, Scr] = test(Banner_opts, Scr_opts)
            % [Banner, Scr] = test(Banner_opts, Scr_opts)
            
            if ~exist('Banner_opts', 'var'), Banner_opts = {}; end
            if ~exist('Scr_opts', 'var'), Scr_opts = {}; end
            
            if isempty(Banner_opts) || isempty(Banner_opts{1})
                Banner_opts{1} = sprintf('%1.1f\n', 1:10);
            end
            
            S_Scr = varargin2S(Scr_opts{:}, {
                });
            
            C_Scr = S2C(S_Scr);
            
            % opening
            Scr     = PsyScr(C_Scr{:});
            Scr.open;
            
            Banner  = PsyBanner(Scr, Banner_opts{:});
            Scr.addObj('Vis', Banner);
            
            % trial
            Scr.initLogTrial;
            Banner.show;
            Scr.wait('Banner', @() false, 'for', 3, 'sec');
%             Banner.hide;
            Scr.closeLog;
            
            % closing
            Scr.close;
        end
    end
end