function [res, S] = eqLum_RDK_col(varargin)

S = varargin2S(varargin, {...
    'colRDK',   [199 220 1; 1 220 255]' ...
    'colFP',    [103 103 103] ...
    'col_red',  199 ...
    'Scr',      [] ...
    'maxSec',   5 ...
    'bef_RDK_sec',  1 ...
    'intertrial_sec', 1 ...
    'coh_mot_fun',  [] ...
    'coh_mot',      0 ...
    'coh_col_fun',  [] ...
    'coh_col',      0 ...
    'step_size',    [1 10] ...
    'RDK_seeds', {'shuffle', 'shuffle', 'shuffle'} ...
    'K', struct( ...
        'up2', 'SColonColon', ...
        'up',  'l', ...
        'dn',  'k', ...
        'dn2', 'j', ...
        'show_info', 'v', ...
        'abort',     'escape', ...
        'accept',    'space') ...
    'RDKCol_opt', {} ...
    'attribute', 'col_red' ...
    });

if isempty(S.Scr)
    S.Scr    = PsyScr('scr', 1, 'refreshRate', 75, 'distCm', 55, 'widthCm', 35.1, ...
    'hideCursor', true, 'maxSec', S.maxSec + S.bef_RDK_sec, 'bkgColor', 1);
end
if ~S.Scr.opened
    S.Scr.open;
end

switch S.attribute
    case 'col_red'
        balanced_fr = 1:(75*(S.maxSec+1));
    otherwise
        balanced_fr = [];
end

S.colRDK(1) = S.col_red;
RDKCol_opt = varargin2S(S.RDKCol_opt, { ...
    'dotDensity', 16.7, ...
    'dotSizeDeg', 0.075, ...
    'apInnerRDeg', 0.5, ...
    'apRDeg', 2.5, ...
    'colors', S.colRDK, ...
    'nFrSet', round(S.Scr.info.refreshRate * 0.04), ...
    'maxSec', S.Scr.info.maxSec, ...
    'balanced_fr', balanced_fr ...
    });

Key = PsyKey(S.Scr, hVec(struct2cell(S.K)), 'freq', 2);
Key.get; % workaround to work with tablets.

FP     = PsyPTB(S.Scr, 'FillCircle', S.colFP', [0 0]', 0.1);
RDKCol = PsyRDKConst(S.Scr);

for c_coh = {'coh_col', 'coh_mot'}
    if ~isempty(S.([c_coh{1}, '_fun']))
        S.(c_coh{1}) = S.([(c_coh{1}), '_fun'])();
    end    
end

C_RDKCol_opt = S2C(RDKCol_opt);
RDKCol.init(0, invLogit(S.coh_col), S.RDK_seeds, C_RDKCol_opt{:});

S.Scr.addObj('Vis', FP, RDKCol);
S.Scr.addObj('Inp', Key);

res.aborted  = false;
res.accepted = false;
res.(S.attribute) = S.(S.attribute);

ListenChar(2);
while ~(res.aborted || res.accepted)
    S.colRDK(1) = res.col_red;
    C_RDKCol_opt = varargin2C({'colors', S.colRDK});
    RDKCol.init(S.coh_mot, invLogit(S.coh_col), S.RDK_seeds, C_RDKCol_opt{:});
    
    fprintf('%s: %1.0f\n', S.attribute, res.(S.attribute));
    
    S.Scr.initLogTrial;
    
    Key.activate;
    FP.show;
    RDKCol.showAt(GetSecs + S.bef_RDK_sec);
    
    S.Scr.wait('waitKey', @() any(Key.logged), 'for', max(S.maxSec, 0), 'sec');
    
    Key.deactivate;
    S.Scr.hide('all');
    S.Scr.wait('blank', @() false, 'for', 1, 'fr');
    
    if any(Key.logged)
        cKey = Key.loggedNames;
        
        switch cKey{1}
            case S.K.up2
                res.col_red = min(res.col_red + S.step_size(2), 255);
                
            case S.K.up
                res.col_red = min(res.col_red + S.step_size(1), 255);
                
            case S.K.dn
                res.col_red = max(res.col_red + S.step_size(1), 1);
                
            case S.K.dn2
                res.col_red = max(res.col_red + S.step_size(2), 1);
                
            case S.K.accept
                res.accepted = true;
                break;
                
            case S.K.abort
                res.aborted = true;
                break;
        end
    end
    
    WaitSecs(S.intertrial_sec);
end

S.RDKCol_opt = RDKCol_opt;
S.Scr.closeLog;
ListenChar(0);