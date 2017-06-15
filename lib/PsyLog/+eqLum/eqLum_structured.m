function [res LAdj toEscape o] = eqLum(varargin)
% EQUILUM   Ensure two colors are equiluminent.
%
% [newColAdj o toEscape res] = eqLum(['opt1', opt1, ...])
%
% OUTPUTS
%     newColAdj : Adjusted colAdj.
%     o       : Struct containing input parameters.
%     res       : Struct containing all workspace variables in the function.
%
% OPTIONS (partial list. refer to the struct o in the code.)
%     Scr     = PsyScr('scr', 0, 'refreshRate', 60, 'distCm', 35.1); % adjust to match your screen.
%     spFreq  = 1; % spatial  freq (cyc/deg).
%     tmFreq  = 1; % temporal freq (cyc/sec).
%     spForm  = 'sinusoidal'; % 'sinusoidal', or 'square'
%     tmForm  = 'sinusoidal'; % 'sinusoidal', or 'square'
%     apRDeg  = 3;   % aperture size.
%     apRSig  = 1.5; % sigma of radial gaussian mask. Set to a very big number, say, 1e3, to get an all-or-none mask.
%     colBase = [254 0 0]; % color to keep constant.
%     colAdj  = [0 254 0]; % color to adjust.
%     colBkg  = [1 1 1]; % nonzero to keep CRT beams running.
%     LBase   = 200/255; % luminance of colBase.
%     LAdj    = 200/255; % luminance of colAdj.
%     m = 0.1; % m in eqs (1)-(2) of Cavanagh 1987.
%     mvDur   = 1; % How long should the stim be. (it will be repeated during onDur).
%     onDur   = 10; % How long should the stim turned on (sec).
%     offDur  = 1; % How long should the stim turned off (sec).
%     toShowInfo = true; % To show color values and patches or not.
%     dontCloseScr = false; % For repetitive testing.
%
% Reference : Cavanagh et al. (1987) JOSA.
%
% 2013 (c) Yul Kang. hk2699 at columbia dot edu.

import eqLum.*

o  = initOpt(varargin{:});
Scr  = initScr(o);
res  = showGrating(o, Scr, grat);
res  = closeScr(o, Scr, res);
end


function o = initOpt(varargin)
o.Scr     = PsyScr('scr', 0, 'refreshRate', 60, 'distCm', 35.1); % adjust to match your screen.
o.spFreq  = 1; % spatial  freq (cyc/deg).
o.tmFreq  = 1; % temporal freq (cyc/sec).
o.apRDeg  = 5;   % aperture size.
o.apRSig  = 1.5; % sigma of radial gaussian mask. Set to a very big number, say, 1e3, to get an all-or-none mask.

o.maskRDeg = 0.5; % radius of central mask.
% maskRSig = 0.5; % width of central radial gaussian mask. Hides macular region.

o.colBase = [1 0 0]; % color to keep constant.
o.colAdj  = [0 0 1]; % color to adjust.
o.colBkg  = [0 1 0]; % color common to colBase and colAdj, painted inside the aperture.
o.colBkgOut = [1 1 1]; % nonzero to keep CRT beams running.
o.colFP   = [100 100 100];
o.LBase   = 189; % luminance of colBase.
o.LAdj    = 123; % luminance of colAdj.
o.LBkg    = 50;  % luminance of colBkg.
o.LBkgOut = 50;  % luminance of colBkgOut.
o.m       = 0.1; % contrast of luminance in eqs (1)-(2) of Cavanagh 1987.
o.mvDur   = 1; % How long should the stim be. (it will be repeated during onDur).
o.onDur   = 10; % How long should the stim turned on (sec).
o.offDur  = 1; % How long should the stim turned off (sec).
o.fadeDur = 1; % Fade in/out duration (sec).
o.toShowInfo = true; % To show color values and patches or not.
o.dontCloseScr = false; % For repetitive testing.
o.usePutImage  = false; 
o.toEscape     = false;
o.returnWS     = false; % Return whole workspace.

o = varargin2fields(o, varargin);
end

function Scr = initScr(o)
%% Initialize Scr
Scr = o.Scr;
Scr.info.bkgColor = o.colBkgOut*o.LBkgOut;

%% Initialize Key
Key = PsyKey(Scr, {'N7And', 'u', 'j', 'm', 'i', 'k', 'v', 'escape', 'space', 'return'}, ...
                  'freq', 2);
Key.get; % workaround to work with tablets.
if ~Scr.opened
    Scr.open;
end

%% Initialize Banner
BannerBase = PsyBanner(Scr, ' ', [255 255 255 255], [o.colBkgOut(:)'*o.LBkgOut 0], [0 -5]);
BannerAdj  = PsyBanner(Scr, ' ', [255 255 255 255], [o.colBkgOut(:)'*o.LBkgOut 0], [0 5]);

%% Initialize Patches & FP
Patch = PsyPTB(Scr, 'FillCircle', bsxfun(@plus,[o.LBase*o.colBase; o.LAdj*o.colAdj]',o.LBkg*o.colBkg'), [-10 0; +10 0]', [5 5]);
FP    = PsyPTB(Scr, 'FillCircle', o.colFP', [0 0]', 0.1);
Mask  = PsyPTB(Scr, 'FillCircle', o.colBkgOut(:)*o.LBkgOut, [0 0]', o.maskRDeg);

%% Initialize Grating
Grating = PsyMovie(Scr, initGrating(o), ...
                            'xyDeg', [0; 0], ...
                            'sizeDeg', o.apRDeg, ...
                            'usePutImage', o.usePutImage);                        
              
%% Open device
Scr.addObj('Vis', Grating, Mask, FP, Patch, BannerBase, BannerAdj);
Scr.addObj('Inp', Key);
Grating.open;
end

function imMat = initGrating(o)
degPerPix   = 1/o.Scr.info.pixPerDeg;
x           = -o.apRDeg:degPerPix:o.apRDeg;
nxy         = length(x);

IFI         = 1/o.Scr.info.refreshRate;
t           = IFI:IFI:o.mvDur;
nt          = length(t);

vBase = 0.5*LBase*(1+m*sin(2*pi*fT*t(:))*sin(2*pi*fS*x) ... % (t,x)
                  +1+  cos(2*pi*fT*t(:))*cos(2*pi*fS*x));
              
vAdj  = 0.5*LAdj *(1+m*sin(2*pi*fT*t(:))*sin(2*pi*fS*x) ... % (t,x)
                  +1-  cos(2*pi*fT*t(:))*cos(2*pi*fS*x));              

imMat = zeros(nxy,nxy,3,nt);

for iCol = 1:3
    imMat(:,:,iCol,:) = repmat(permute(vBase, [3 2 4 1]), [1 nxy 1 1]) * o.colBase(iCol) ...
                      + repmat(permute(vAdj , [3 2 4 1]), [1 nxy 1 1]) * o.colAdj( iCol);
end
end

function res = showGrating(o, Scr, grat)
fprintf('\nOriginal colBaseMax: %3.0f %3.0f %3.0f, colAdjMax: %3.0f %3.0f %3.0f\n', ...
    RGBBase, RGBAdj);
commandwindow;

ListenChar(2);
while ~Key.logged('space')
    Scr.initLogTrial;

    Key.activate;
    Mask.show;
    FP.show;
    if toShowInfo
        Patch.show;
        BannerBase.show(sprintf('%3.0f ', RGBBase)); 
        BannerAdj. show(sprintf('%3.0f ', RGBAdj)); 
    end

    %% Draw grating
    Grating.alpha = 0;
    Grating.show;
    Grating.fade('in', GetSecs, GetSecs+fadeDur);
    Grating.fade('out', GetSecs+onDur-fadeDur, GetSecs+onDur);
    Scr.wait('waitKey', @() any(Key.logged), 'for', onDur, 'sec');

    fprintf('.');
    if any(diff(Scr.tTrim('frOn')) > 1.5/Scr.info.refreshRate)
        fprintf('\nFrame delayed!\n');
    end

    if any(Key.logged)
        Grating.fade('out', GetSecs, GetSecs+fadeDur, Grating.alpha, 0);
        Scr.wait('fadeOut', @() false, 'for', fadeDur, 'sec');
    end
    Grating.hide;    

    %% Respond to key input
    if any(Key.logged)
        Scr.wait('blank', @() false, ...
            'for', 1, 'fr');

        cKey = Key.loggedNames;

        switch cKey{1}
            case 'N7And'
                LAdj = min(LAdj + 10, RGB2L(255,lumContrast,LBkg,colAdj));
            case 'u'
                LAdj = min(LAdj + 1,  RGB2L(255,lumContrast,LBkg,colAdj));
            case 'j'
                LAdj = max(LAdj - 1,  0);
            case 'm'
                LAdj = max(LAdj - 10, 0);
%             case 'i'
%                 lumContrast = min(lumContrast + 1/(255-LBkgOut), 1);
%             case 'k'
%                 lumContrast = max(lumContrast - 1/(255-LBkgOut), 0);
            case 'v'
                toShowInfo = ~toShowInfo;
                if toShowInfo
                    show(PsyScr, BannerAdj, BannerBase, Patch);
                else
                    hide(PsyScr, BannerAdj, BannerBase, Patch);
                end
            case {'escape', 'space'}
                fprintf('\nUser stopped!\n');
                break;
        end    

        % Apply adjusted color to gratings
        tic; % debug
        Grating.replace(1:nFr, gratAdj*LAdj+gratBkg);
        toc; % debug

        Patch.color = [RGBBase; RGBAdj]';

        adjStr = sprintf('%3.0f ', RGBAdj);
        BannerAdj.init(adjStr);
        fprintf('\nAdjusted colBaseMax: %3.0f %3.0f %3.0f, colAdjMax: %3.0f %3.0f %3.0f\n', ...
            Patch.color);
    else
        Scr.wait('blank', @() any(Key.logged('escape', 'space')), ...
            'for', offDur, 'sec');
    end
end
fprintf('\n');
end

function res = closeScr(o, Scr, res);
end