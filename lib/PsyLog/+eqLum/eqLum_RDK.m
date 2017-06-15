function [res, S] = eqLum_RDK(varargin)

S = varargin2S(varargin, {...
    'colRDK',   [199 220 1; 1 220 255] ...
    'colFP',    [103 103 103] ...
    'Scr',      [] ...
    'Scr_opt',  {} ...
    'maxSec',   5 ...
    'bef_RDK_sec',  1 ...
    'intertrial_sec', 1 ...
    'coh_mot_fun',  [] ...
    'coh_mot',      0 ...
    'coh_col_fun',  [] ...
    'coh_col',      0 ...
    'step_size',     [0.005, 0.05] ...
    'RDK_seeds', {'shuffle', 'shuffle', 'shuffle'} ...
    'K', struct( ...
        'up2', 'N7And', ...
        'up',  'u', ...
        'dn',  'j', ...
        'dn2', 'm', ...
        'show_info', 'v', ...
        'abort',     'escape', ...
        'accept',    'space') ...
    'RDKCol_opt', {} ...
    });

Scr_opt = varargin2S(S.Scr_opt, {...
    'scr', 1, 'refreshRate', 75, 'distCm', 55, 'widthCm', 35.1, ...
    'hideCursor', true, 'maxSec', S.maxSec + S.bef_RDK_sec, 'bkgColor', 1, 'rect', [0 0 1400 1050]' ...
    });
C_Scr_opt = S2C(Scr_opt);

if isempty(S.Scr)
    S.Scr    = PsyScr(C_Scr_opt{:});
end

RDKCol_opt = varargin2S(S.RDKCol_opt, { ...
    'dotDensity', 16.7, ...
    'dotSizeDeg', 0.075, ...
    'apInnerRDeg', 0.5, ...
    'apRDeg', 2.5, ...
    'colors', S.colRDK', ...
    'nFrSet', round(S.Scr.info.refreshRate * 0.04), ...
    'maxSec', S.Scr.info.maxSec ...
    });

Key = PsyKey(S.Scr, hVec(struct2cell(S.K)), 'freq', 2);
Key.get; % workaround to work with tablets.
% if ~S.Scr.opened
    S.Scr.open;
% end

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
res.coh_col  = S.coh_col;

ListenChar(2);
while ~(res.aborted || res.accepted)
    RDKCol.init(S.coh_mot, invLogit(res.coh_col), S.RDK_seeds, C_RDKCol_opt{:});
    
    fprintf('logit: %1.3f, prop: %1.3f\n', res.coh_col, invLogit(res.coh_col));
    
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
                res.coh_col = res.coh_col + S.step_size(2);
                
            case S.K.up
                res.coh_col = res.coh_col + S.step_size(1);
                
            case S.K.dn
                res.coh_col = res.coh_col - S.step_size(1);
                
            case S.K.dn2
                res.coh_col = res.coh_col - S.step_size(2);
                
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
S.Scr.close;
ListenChar(0);