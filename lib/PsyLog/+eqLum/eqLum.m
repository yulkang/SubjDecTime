function [res LAdj toEscape S] = eqLum(varargin)
% EQUILUM   Ensure two colors are equiluminent.
%
% [res S.LAdj S.toEscape S] = eqLum(['opt1', opt1, ...])
%
% OUTPUTS
%     res       : Struct containing all workspace variables in the function.
%     S.LAdj      : Adjusted S.colAdj.
%     S         : Struct containing input parameters.
%
% OPTIONS (partial list. refer to the struct S in the code.)
%     Scr     = PsyScr('scr', 0, 'refreshRate', 60, 'distCm', 35.1); % adjust to match your screen.
%     S.spFreq  = 1; % spatial  freq (cyc/deg).
%     S.tmFreq  = 1; % temporal freq (cyc/sec).
%     spForm  = 'sinusoidal'; % 'sinusoidal', or 'square'
%     tmForm  = 'sinusoidal'; % 'sinusoidal', or 'square'
%     S.apRDeg  = 3;   % aperture size.
%     S.apRSig  = 1.5; % sigma of radial gaussian mask. Set to a very big number, say, 1e3, to get an all-or-none mask.
%     S.colBase = [254 0 0]; % color to keep constant.
%     S.colAdj  = [0 254 0]; % color to adjust.
%     S.colBkg  = [1 1 1]; % nonzero to keep CRT beams running.
%     S.LBase   = 200/255; % luminance of S.colBase.
%     S.LAdj    = 200/255; % luminance of S.colAdj.
%     S.m = 0.1; % S.m in eqs (1)-(2) of Cavanagh 1987.
%     S.mvDur   = 1; % How long should the stim be. (it will be repeated during S.onDur).
%     S.onDur   = 10; % How long should the stim turned on (sec).
%     S.offDur  = 1; % How long should the stim turned off (sec).
%     S.toShowInfo = true; % To show color values and patches or not.
%     S.dontCloseScr = false; % For repetitive testing.
%
% Reference : Cavanagh et al. (1987) JOSA.
%
% 2013 (c) Yul Kang. hk2699 at columbia dot edu.

import eqLum.*

%% Initialize arguments
S = varargin2S(varargin, { ...
    'Scr', [] ... % adjust to match your screen.
    'spFreq',  1 ... % spatial  freq (cyc/deg).
    'tmFreq',  1 ... % temporal freq (cyc/sec).
    ... % 'spForm',   'sinusoidal' ... % 'sinusoidal', or 'square'
    ... % 'tmForm',   'sinusoidal' ... % 'sinusoidal', or 'square'
    'apRDeg',  5 ...   % aperture size.
    'apRSig',  1.5 ... % sigma of radial gaussian mask. Set to a very big number, say, 1e3, to get an all-or-none mask.
    ...
    'maskRDeg', 0.5 ... % radius of central mask.
    ... % 'maskRSig',  0.5 ... % width of central radial gaussian mask. Hides macular region.
    'calcMode', 'targetColor' ... % 'targetColor' (for adjusting white) or 'baseRGB' (for adjusting R with G fixed)
    ...
    'colBase', [1 0 0] ... % color to keep constant.
    'colAdj',  [0 0 1] ... % color to adjust.
    'colBkg',  [0 1 0] ... % color common to S.colBase and S.colAdj, painted inside the aperture.
    'colBkgOut', [1 1 1] ... % nonzero to keep CRT beams running.
    'colFP',   [100 100 100] ... 
    'LBase',   189 ... % luminance of S.colBase.
    'LAdj',    123 ... % luminance of S.colAdj.
    'LBkg',    50 ...  % luminance of S.colBkg.
    'LBkgOut', 50 ...  % luminance of S.colBkgOut.
    'm',       0.1 ... % S.m in eqs (1)-(2) of Cavanagh 1987.
    'mvDur',   1 ... % How long should the stim be. (it will be repeated during S.onDur).
    'onDur',   10 ... % How long should the stim turned on (sec).
    'offDur',  1 ... % How long should the stim turned off (sec).
    'fadeDur', 0.5 ... % Fade in/out duration (sec).
    'toShowInfo', true ... % To show color values and patches or not.
    'dontCloseScr', false ... % For repetitive testing.
    'usePutImage',  false ... 
    'toEscape',     false ... 
    'returnWS',     false ... % Return whole workspace.
    'K', struct(...
        'up2', 'j', ...
        'up',  'k', ...
        'dn',  'l', ...
        'dn2', 'SColonColon', ...
        'up_contrast',  'u', ...
        'dn_contrast',  'm', ...
        'show_info',    'v', ...
        'abort',        'escape', ...
        'accept',       'space') ...
    });

% When S.colAdj >> S.colBase, the apparent motion is to the right.

%% Initialize Scr
S.Scr.info.bkgColor = S.colBkgOut*S.LBkgOut;

%% Initialize Key
Key = PsyKey(S.Scr, hVec(struct2cell(S.K)), ...
                  'freq', 2);
Key.get; % workaround to work with tablets.
if ~S.Scr.opened
    S.Scr.open;
end

%% Initialize Banner
BannerBase = PsyBanner(S.Scr, ' ', [255 255 255 255], [S.colBkgOut(:)'*S.LBkgOut 0], [0 -5]);
BannerAdj  = PsyBanner(S.Scr, ' ', [255 255 255 255], [S.colBkgOut(:)'*S.LBkgOut 0], [0 5]);

%% Initialize Patches & FP
Patch = PsyPTB(S.Scr, 'FillCircle', bsxfun(@plus,[S.LBase*S.colBase; S.LAdj*S.colAdj]',S.LBkg*S.colBkg'), [-10 0; +10 0]', [5 5]);
FP    = PsyPTB(S.Scr, 'FillCircle', S.colFP', [0 0]', 0.1);
Mask  = PsyPTB(S.Scr, 'FillCircle', S.colBkgOut(:)*S.LBkgOut, [0 0]', S.maskRDeg);

%% Initialize Grating
Grating = PsyMovie(S.Scr, gratingMat, ...
                            'xyDeg', [0; 0], ...
                            'sizeDeg', S.apRDeg, ...
                            'usePutImage', S.usePutImage);                        
              
%% Open device
S.Scr.addObj('Vis', Grating, Mask, FP, Patch, BannerBase, BannerAdj);
S.Scr.addObj('Inp', Key);
Grating.open;

%% Loop
fprintf('\nOriginal colBaseMax: %3.0f %3.0f %3.0f, colAdjMax: %3.0f %3.0f %3.0f\n', ...
    RGBBase, RGBAdj);
commandwindow;

disp(S.K);

ListenChar(2);
while ~Key.logged(S.K.accept)
    S.Scr.initLogTrial;

    Key.activate;
    Mask.show;
    FP.show;
    if S.toShowInfo
        Patch.show;
        BannerBase.show(sprintf('%3.0f ', RGBBase)); 
        BannerAdj. show([sprintf('%3.0f ', RGBAdj), sprintf('%1.1f', S.m)]); 
    end

    %% Draw grating
    Grating.alpha = 0;
    Grating.show;
    Grating.fade('in', GetSecs, GetSecs+S.fadeDur);
    Grating.fade('out', GetSecs+S.onDur-S.fadeDur, GetSecs+S.onDur);
    S.Scr.wait('waitKey', @() any(Key.logged), 'for', S.onDur, 'sec');

    fprintf('.');
    if any(diff(S.Scr.tTrim('frOn')) > 1.5/S.Scr.info.refreshRate)
        fprintf('\nFrame delayed!\n');
    end

    if any(Key.logged)
        Grating.fade('out', GetSecs, GetSecs+S.fadeDur, Grating.alpha, 0);
        S.Scr.wait('fadeOut', @() false, 'for', S.fadeDur, 'sec');
    end
    Grating.hide;    

    %% Respond to key input
    if any(Key.logged)
        S.Scr.wait('blank', @() false, ...
            'for', 1, 'fr');

        cKey = Key.loggedNames;

        switch cKey{1}
            case S.K.up2
                S.LAdj = min(S.LAdj + 10, RGB2L(255,S.m,S.LBkg,S.colAdj));
            case S.K.up
                S.LAdj = min(S.LAdj + 1,  RGB2L(255,S.m,S.LBkg,S.colAdj));
            case S.K.dn
                S.LAdj = max(S.LAdj - 1,  0);
            case S.K.dn2
                S.LAdj = max(S.LAdj - 10, 0);
            case S.K.up_contrast
                S.m = min(S.m+0.1,1);
            case S.K.dn_contrast
                S.m = max(S.m-0.1,0);
            case S.K.show_info
                S.toShowInfo = ~S.toShowInfo;
                if S.toShowInfo
                    show(PsyScr, BannerAdj, BannerBase, Patch);
                else
                    hide(PsyScr, BannerAdj, BannerBase, Patch);
                end
            case {S.K.abort, S.K.accept}
                fprintf('\nUser stopped!\n');
                break;
        end    

        % Apply adjusted color to gratings
%         tic; % debug
        Grating.replace([], gratingMat);
%         toc; % debug

        Patch.color = [RGBBase; RGBAdj]';

        adjStr = sprintf('%3.0f ', RGBAdj);
        BannerAdj.init(adjStr);
        fprintf('\nAdjusted colBaseMax: %3.0f %3.0f %3.0f, colAdjMax: %3.0f %3.0f %3.0f, S.m: %1.1f\n', ...
            Patch.color, S.m);
    else
        S.Scr.wait('blank', @() any(Key.logged(S.K.abort, S.K.accept)), ...
            'for', S.offDur, 'sec');
    end
end
fprintf('\n');

%% Close device
Grating.close;

if ~S.dontCloseScr
    S.Scr.close;
else
    S.Scr.hide('all');
    S.Scr.wait('hideAll', @() false, 'for', 1, 'fr');
end
ListenChar(0);

if Key.logged(S.K.abort), S.toEscape = true; end

if S.returnWS
    res = ws2s;
else
    res = [];
end

toEscape = S.toEscape;
LAdj     = S.LAdj;

%% Nested functions
function v = RGBBase
    v = eqLum.L2RGB(S.LBase,S.colBase,S.m,S.colBkg*S.LBkg);
end
function v = RGBAdj
    v = eqLum.L2RGB(S.LAdj ,S.colAdj ,S.m,S.colBkg*S.LBkg);
end
function imMat = gratingMat
    
% Spatial vector
degPerPix   = 1/S.Scr.info.pixPerDeg;
x           = -S.apRDeg:degPerPix:S.apRDeg;
nxy         = length(x);

% Temporal vector
IFI         = 1/S.Scr.info.refreshRate;
t           = IFI:IFI:S.mvDur;
nt          = length(t);

% Initialize result
imMat = zeros(nxy,nxy,3,nt);

% Weights for cBase and cAdj.
vBase = 0.5*(1+S.m*sin(2*pi*S.tmFreq*t(:))*sin(2*pi*S.spFreq*x) ... % (t,x)
            +1+  cos(2*pi*S.tmFreq*t(:))*cos(2*pi*S.spFreq*x));
              
vAdj  = 0.5*(1+S.m*sin(2*pi*S.tmFreq*t(:))*sin(2*pi*S.spFreq*x) ... % (t,x)
            +1-  cos(2*pi*S.tmFreq*t(:))*cos(2*pi*S.spFreq*x));              

% Two weighted colors
cAdj  = S.colAdj *S.LAdj;
cBase = S.colBase*S.LBase;

dCol  = (cAdj-cBase)/2;
mCol  = (cAdj+cBase)/2;
for iCol = 1:3
    % Blend the two weighted colors linearly.
    imMat(:,:,iCol,:) = repmat(permute((vAdj-vBase)/2*dCol(iCol), [3 2 4 1]), [nxy 1 1 1]) ...
                      + repmat(permute((vAdj+vBase)/2*mCol(iCol), [3 2 4 1]), [nxy 1 1 1]) ...
                      + S.colBkg(iCol);
end

% Mask by distance
d     = sqrt(bsxfun(@plus, x.^2, x(:).^2));
mask  = normpdf(d,0,S.apRSig) .* (d<=S.apRDeg);
mask  = mask*(255/max(mask(:)));
imMat(:,:,4,:) = repmat(mask,[1 1 1 nt]);
end
end