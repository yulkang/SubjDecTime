function hax = plot(Scr, relS, varargin)

S = varargin2S(varargin, {
    'hax',     [] 
    'axWidthPix',[]
    'wait_fig_resize', true
    'xLimDeg', [-10, 10]
    'yLimDeg', [-10, 10]
    'to_plot', true
    'vidfile', ''
    'audfile', ''
    'vidprofile', 'MPEG-4' % less noise than avi
    'vidopt',  {}
    'audopt',  {}
    'stepthrough', false
    });

%% Determine relS
if nargin < 2 || isempty(relS)
    relS = hVec(Scr.relSec('frOn'));
end

%% Initialize axes color and size
if S.to_plot
    if ~isvalidhandle(S.hax)
        Scr.hax = gca;
    else
        Scr.hax = S.hax;
    end
    hax  = Scr.hax;
    hfig = get(hax, 'Parent');
    
    if S.wait_fig_resize
        xyLim = Scr.pix2deg([Scr.info.rect(1:2), Scr.info.rect(1:2) + Scr.info.rect(3:4)]);
        if isempty(S.xLimDeg), S.xLimDeg = xyLim([1 3]); end
        if isempty(S.yLimDeg), S.yLimDeg = xyLim([2 4]); end

        % Center the axes
        set(hax,  'Units', 'normalized'); drawnow;
        set(hax,  'Position', [0.5 0.5 0.9 0.9]); drawnow;
        
        % Get the position
        set(hfig, 'Units', 'pixel');
        set(hax,  'Units', 'pixel');
        fpos = get(hfig, 'Position');
        pos  = get(hax,  'Position');

        if isempty(S.axWidthPix)
            S.axWidthPix = pos(3);
        end

        pos(3:4) = S.axWidthPix * [diff(S.xLimDeg), diff(S.yLimDeg)] / diff(S.xLimDeg);
        pos(1:2) = fpos(3:4) / 20; % Since the axes are anchored to the bottom left, it should have space from that corner. % fpos(3:4) / 2 - pos(3:4) / 2; % Center
        set(hax, 'Position', pos);

        axis on; box on;
        input('Resize the figure to include the axes and press enter', 's');
        set(hax, 'Units', 'normalized');
    end

    xlim(S.xLimDeg);
    ylim(S.yLimDeg);
    box off; axis off;

    set(hax,  'Color', Scr.info.bkgColor / 255);
    set(hax, 'XDir', 'normal', 'YDir', 'reverse');
    set(hfig, 'Color', Scr.info.bkgColor / 255);
    cla;

    %% Prepare movie recording
    to_vidrec = ~isempty(S.vidfile);
    if to_vidrec
        pth = fileparts(S.vidfile);
        if ~exist(pth, 'dir'), mkdir(pth); end
        
        writerObj = VideoWriter(S.vidfile, S.vidprofile);
        S.vidopt  = varargin2C(S.vidopt, {
            'FrameRate', Scr.info.refreshRate
            });
        if ~isempty(S.vidopt)
            set(writerObj, S.vidopt{:});
        end
        open(writerObj);
    end

    %% Initialize objects
    vis = Scr.cTags.Vis;
    for cvis = vis(:)'
        Scr.c.(cvis{1}).h = [];
    end

    %% Draw objects
    nrelS = length(relS);
    
    frs = 1:(round((relS(end) - relS(1)) * Scr.info.refreshRate) + 1);
    
    for iFr = frs
        crelS = (iFr - 1) / Scr.info.refreshRate + relS(1);
%         crelS = relS(irelS);

        hold off;
        for cvis = vis(:)'
    %         try
                Scr.c.(cvis{1}).plot(crelS);
                hold on;
    %         catch err
    %             if nrelS == 1
    %                 warning(err_msg(err));
    %             end
    %         end
        end
        drawnow;

        if to_vidrec
            writeVideo(writerObj, getframe);
        end
        if S.stepthrough
            set(hfig, 'Name', sprintf('Frame %d', irelS));
            pause;
        else
            fprintf('.');
            if mod(iFr, Scr.info.refreshRate) == 0, fprintf('\n'); end
%             if mod(irelS, 60) == 0, fprintf('\n'); end
        end
    end
    fprintf('Done.\n');

    %% Finish movie recording
    if to_vidrec
        close(writerObj);
        fprintf('Video is written to %s\n', S.vidfile);
    end
end

%% Record audio
if ~isempty(S.audfile)
    pth = fileparts(S.audfile);
    if ~exist(pth, 'dir'), mkdir(pth); end
    
    t0 = Scr.relSec('frOn');
    t0 = t0(1);
    C = varargin2C({'t0', t0}, S.audopt);
    Scr.c.Aud.record(S.audfile, C{:});
end

%% Output
if nargout >= 1
    hax = Scr.hax;
end
end