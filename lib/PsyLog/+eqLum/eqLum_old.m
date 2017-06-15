function [res LAdj toEscape opt] = eqLum(varargin)
% EQUILUM   Ensure two colors are equiluminent.
%
% [newColAdj opt toEscape res] = eqLum(['opt1', opt1, ...])
%
% OUTPUTS
%     newColAdj : Adjusted colAdj.
%     opt       : Struct containing input parameters.
%     res       : Struct containing all workspace variables in the function.
%
% OPTIONS (partial list. refer to the struct opt in the code.)
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
%     lumContrast = 0.1; % m in eqs (1)-(2) of Cavanagh 1987.
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

%% Initialize arguments
Scr     = PsyScr('scr', 0, 'refreshRate', 60, 'distCm', 35.1); % adjust to match your screen.
spFreq  = 1; % spatial  freq (cyc/deg).
tmFreq  = 1; % temporal freq (cyc/sec).
spForm  = 'sinusoidal'; % 'sinusoidal', or 'square'
tmForm  = 'sinusoidal'; % 'sinusoidal', or 'square'
apRDeg  = 5;   % aperture size.
apRSig  = 1.5; % sigma of radial gaussian mask. Set to a very big number, say, 1e3, to get an all-or-none mask.

maskRDeg = 0.5; % radius of central mask.
% maskRSig = 0.5; % width of central radial gaussian mask. Hides macular region.

colBase = [1 0 0]; % color to keep constant.
colAdj  = [0 0 1]; % color to adjust.
colBkg  = [0 1 0]; % color common to colBase and colAdj, painted inside the aperture.
colBkgOut = [1 1 1]; % nonzero to keep CRT beams running.
colFP   = [100 100 100];
LBase   = 189; % luminance of colBase.
LAdj    = 123; % luminance of colAdj.
LBkg    = 50;  % luminance of colBkg.
LBkgOut = 50;  % luminance of colBkgOut.
lumContrast = 0.1; % m in eqs (1)-(2) of Cavanagh 1987.
mvDur   = 1; % How long should the stim be. (it will be repeated during onDur).
onDur   = 10; % How long should the stim turned on (sec).
offDur  = 1; % How long should the stim turned off (sec).
fadeDur = 1; % Fade in/out duration (sec).
toShowInfo = true; % To show color values and patches or not.
dontCloseScr = false; % For repetitive testing.
usePutImage  = false; 
toEscape     = false;
returnWS     = false; % Return whole workspace.

varargin2var(varargin);
opt = ws2s;
% When colAdj >> colBase, the apparent motion is to the right.

%% Initialize Scr
Scr.info.bkgColor = colBkgOut*LBkgOut;

%% Initialize Key
Key = PsyKey(Scr, {'N7And', 'u', 'j', 'm', 'i', 'k', 'v', 'escape', 'space', 'return'}, ...
                  'freq', 2);
Key.get; % workaround to work with tablets.
if ~Scr.opened
    Scr.open;
end

%% Initialize Banner
BannerBase = PsyBanner(Scr, ' ', [255 255 255 255], [colBkgOut(:)'*LBkgOut 0], [0 -5]);
BannerAdj  = PsyBanner(Scr, ' ', [255 255 255 255], [colBkgOut(:)'*LBkgOut 0], [0 5]);

%% Initialize Patches & FP
Patch = PsyPTB(Scr, 'FillCircle', bsxfun(@plus,[LBase*colBase; LAdj*colAdj]',LBkg*colBkg'), [-10 0; +10 0]', [5 5]);
FP    = PsyPTB(Scr, 'FillCircle', colFP', [0 0]', 0.1);
Mask  = PsyPTB(Scr, 'FillCircle', colBkgOut(:)*LBkgOut, [0 0]', maskRDeg);

%% Initialize Grating
% fX: x (deg), ph (cyc)
fX       = @(x,ph) sin(2*pi*((x-ph)*spFreq));
if strcmp(spForm, 'square')
    fX = @(x,ph) ((fX(x,ph)>0)-0.5)*2;
end

% fT: fr (frame), ph (cyc)
fT       = @(fr,ph)  sin(2*pi*((fr./Scr.info.refreshRate - ph)*tmFreq));
if strcmp(tmForm, 'square')
    fT = @(fr,ph) ((fT(fr,ph)>0)-0.5)*2;
end

% if maskRSig == 0
%     fMask   = @(r) (normpdf(0, 0, maskRSig) - normpdf(r, 0, maskRSig)) ./ ...
%                     normpdf(0, 0, maskRSig);
%     fR      = @(r) normpdf(r, 0, apRSig)./normpdf(0, 0, apRSig);
% else
    fR      = @(r) (normpdf(r, 0, apRSig)./normpdf(0, 0, apRSig)) .* (r<=apRDeg);
% end

% Eqs (1) and (2).
xVec    = -apRDeg:(1/Scr.info.pixPerDeg):apRDeg;
yVec    = xVec;
nFr     = ceil(mvDur * Scr.info.refreshRate);

fBase   = @(x,fr,L,m) 0.5*L*((1+m*fX(x, 0   ).*fT(fr, 0)) ...
                            +(1+  fX(x,-0.25).*fT(fr,-0.25)));
fAdj    = @(x,fr,L,m) 0.5*L*((1+m*fX(x, 0   ).*fT(fr, 0)) ...
                            +(1-  fX(x,-0.25).*fT(fr,-0.25)));
                            
gratAdj  = putColorGrating(0,     1, lumContrast, 0, 0);
gratBkg  = putColorGrating(LBase, 0, lumContrast, LBkg, 255);

Grating = PsyMovie(Scr, gratAdj*LAdj + gratBkg, ...
                            'xyDeg', [0; 0], ...
                            'sizeDeg', apRDeg, ...
                            'usePutImage', usePutImage);                        
              
%% Open device
Scr.addObj('Vis', Grating, Mask, FP, Patch, BannerBase, BannerAdj);
Scr.addObj('Inp', Key);
Grating.open;

%% Loop
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

%% Close device
Grating.close;

if ~dontCloseScr
    Scr.close;
else
    Scr.hide('all');
    Scr.wait('hideAll', @() false, 'for', 1, 'fr');
end
ListenChar(0);

if Key.logged('escape'), toEscape = true; end

if returnWS
    res = ws2s;
else
    res = [];
end

%% Nested functions
function v = RGBBase
    import eqLum.* 
    v = L2RGB(LBase,colBase,lumContrast,colBkg*LBkg);
end
function v = RGBAdj
    import eqLum.* 
    v = L2RGB(LAdj ,colAdj ,lumContrast,colBkg*LBkg);
end
function imMat = gratingMat
degPerPix   = 1/Scr.info.pixPerDeg;
x           = -apRDeg:degPerPix:apRDeg;
nxy         = length(x);

IFI         = 1/Scr.info.refreshRate;
t           = IFI:IFI:mvDur;
nt          = length(t);

vBase = 0.5*LBase*(1+m*sin(2*pi*tmFreq*t(:))*sin(2*pi*spFreq*x) ... % (t,x)
                  +1+  cos(2*pi*tmFreq*t(:))*cos(2*pi*spFreq*x));
              
vAdj  = 0.5*LAdj *(1+m*sin(2*pi*tmFreq*t(:))*sin(2*pi*spFreq*x) ... % (t,x)
                  +1-  cos(2*pi*tmFreq*t(:))*cos(2*pi*spFreq*x));              

imMat = zeros(nxy,nxy,3,nt);

for iCol = 1:3
    imMat(:,:,iCol,:) = repmat(permute(vBase*o.colBase(iCol), [3 2 4 1]), [1 nxy 1 1])  ...
                      + repmat(permute(vAdj *o.colAdj( iCol), [3 2 4 1]), [1 nxy 1 1]);
end

mask  = normpdf(bsxfun(@plus, x.^2, x(:).^2),0,apRSig);
mask  = mask/max(mask(:));
imMat(:,:,4,:) = repmat(mask,[1 1 1 nt]);
end
end