function [res LAdj LAdjInit] = eqLumAuto(varargin)
% [res LAdj LAdjInit] = eqLumAuto(options)
%
% 2013 (c) Yul Kang. hk2699 at columbia dot edu.

import eqLum.*

S = varargin2S(varargin, {...
   'tmFreq', [], ...
   'spFreq', [], ...
   'speed',  5, ...
   'nTrial', 12, ...
   'colBase', [0 220 255]/220, ... CW_bright % [0 111 123]/111, ... CW_dark % [0 0 1], ... CY % 
   'colAdj',  [1 1 1], ... CW % [1 0 0], ... % CY % 
   'colBkg',  [1 1 1], ... CW % [1 111 1], ... CY_dark % [1 220 1], ... CY_bright % ./50, ...[1 1 1], ... 
   'LBase', [], ...
   'LAdj', [], ...
   'LBkg', [], ... 50, ... % 215, ...
   'LBkgOut', [], ... 50, ...
   'm', [], ...
   'dontCloseScr', true, ...
   'toShowInfo', false, ...
   'usePutImage', false, ... 
   'mvDur', 1, ... 
   'apRSig', 1000, ...
   'apRDeg', 2.5, ...
   'maskRDeg', 0.5, ...
   'calcMode', 'targetColor', ...
   'Scr', [] ...
   'runName', [] ...
   });

if isempty(S.Scr)
    S.Scr = PsyScr('scr', 1, 'refreshRate', 75, 'distCm', 55, 'widthCm', 35.1, ...
                 'maxSec', 10, 'skipSyncTests', false); % true); % 
end
if isempty(S.tmFreq)
    S.tmFreq = S.Scr.info.refreshRate / 3 / 4; % /3 because RDK.nFrSet. /4 because we want 90 deg shift in phase per dot cycle
end
if isempty(S.spFreq)
    S.spFreq = S.tmFreq / S.speed;
end

LAdjInit = zeros(1,S.nTrial);
LAdj     = zeros(1,S.nTrial);

fprintf('===== New run settings:\n');
disp(S);

if ~inputYN_def('Continue (Y/n)? ', true)
    fprintf('User stopped!\n');
    return; 
end

if isempty(S.runName)
    S.runName = input('Run name: ', 's');
end
file_diary = name_par('diary', S.runName, '.txt');
file_mat   = name_par('mat', S.runName, '.mat');
diary(file_diary);
fprintf('Keeping diary to %s\n', file_diary);

for iTrial = 1:S.nTrial
    LBkgOut = 1;
    LBkg    = LBkgOut;
    m       = 0.2;
    LAdjInit(iTrial)  = RGB2L(255,m,LBkg,1)*rand; % CY_bright, CW_bright % RGB2L(170,m,LBkg,1)*rand; % CY_dark, CW_dark % 
    LBase             = RGB2L(220,m,LBkg,1); % CW_dark % RGB2L(123,m,LBkg,1); % CY_dark % RGB2L(255,m,LBkg,1); % CY_bright % 
    
    S.LBase = LBase;
    S.LAdj  = LAdjInit(iTrial);
    S.LBkg  = LBkg;
    S.LBkgOut = LBkgOut;
    S.m     = m;
    
    fprintf('-----\n');
    fprintf('Trial %d/%d\n', iTrial, S.nTrial); 
    
    C = S2C(S);
    [ws, LAdj(iTrial), toEscape, opt] = eqLum(C{:});
                     
    if toEscape
        if iTrial > 1
            iTrial = iTrial - 1; %#ok<FXSET>
        end
        break; 
    end
                           
	WaitSecs(2); % For recovery from adaptation
end

LAdj = LAdj(1:iTrial);

WaitSecs(1);

S.Scr.initLogTrial;
S.Scr.hide('all');

RGBBase = L2RGB(opt.LBase ,opt.colBase,opt.m,opt.colBkg*opt.LBkg);
RGBAdj  = L2RGB(mean(LAdj),opt.colAdj, opt.m,opt.colBkg*opt.LBkg);

S.Scr.c.Patch.color = [RGBBase; RGBAdj]';
S.Scr.c.Patch.show;
S.Scr.c.Key.activate;
S.Scr.wait('patches', @() S.Scr.c.Key.logged('escape'), 'for', 600, 'sec')
S.Scr.c.Key.deactivate;

S.Scr.c.Grating.close;
S.Scr.close;

res = packStruct(ws, opt, LAdj); % ws2s;
% ws2 = ws;
% 
% % Clear unnecessary variables before saving
% if isstruct(ws)
%     ws2.gratAdj  = [];
%     ws2.gratBkg = [];    
%     
%     for cField = fieldnames(ws)'
%         if isa(ws2.(cField{1}), 'function_handle')
%             ws2.(cField{1}) = [];
%         end
%     end    
% end
% 
% ws2.S.Scr.c.Grating = copy(S.Scr.c.Grating, true);
% ws2.S.Scr.c.Grating.clearImages;
% 
% res.ws = ws2;

%% Save results
res.opt.S.Scr = copy(S.Scr);
res.opt.S.Scr.c.Grating = copy(S.Scr.c.Grating);
res.opt.S.Scr.c.Grating.clearImages;

save(file_mat, 'res');
fprintf('Saved results to %s\n', file_mat);
res.ws = ws;
res.opt = opt;

%% Display results
fprintf('----- Results:\n');
eprintf('LAdj');
eprintf('mean(LAdj)');
eprintf('std(LAdj)');

fprintf('\nMean adjusted colBaseMax: %3.0f %3.0f %3.0f, colAdjMax: %3.0f %3.0f %3.0f\n', ...
            S.Scr.c.Patch.color);

fprintf('Saved diary to %s\n', file_diary);
diary off;