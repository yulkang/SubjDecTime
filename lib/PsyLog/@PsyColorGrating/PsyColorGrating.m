classdef PsyColorGrating < PsyDiscreteCond % & PsyPTB
    properties
        %% Evidence parameter
        n_lev_common = 7;

        %% Temporal paramter
        frac_on = 1; % Proportion of 'on' duration within a cycle.
        t_ph    = 0; % Temporal phase of the stimulus.
        
        %% Spatial parameter
        n_line  = 2; % Number of lines to draw
        s_ph    = 0; % Spatial phase of the stimulus.
        % xyDeg, sizeDeg, centerDeg, penWidthPix: inherited from PsyPTB        
    end
    
    methods
        %% Interface
        function me = PsyColorGrating(cScr, varargin)
            % Set properties
            varargin2fields(me, varargin{:});
            
            % PsyDiscreteCond properties
            me.feat_names = {'A', 'C', 'P'}; % A: angle, C: color, P: spatial phase
            set_common(me, 'n_lev', me.n_lev_common);
            
            % PsyPTB properties
            me.updateOn = {'befDraw'};
            me.tag = 'ColorGrating';
            me.commPsy = 'DrawLines';
            
            % Set Scr
            if nargin > 0, me.Scr = cScr; end
            
            initLogEntries(me, 'prop2', {'t_ph'}, 'fr');
        end
        
        function update(me, from)
            if ~strcmp(from, 'befDraw') || ~me.visible, return; end
            
            s_freq = siz(1) / me.n_line;
            
            % Set xy, etc.
            xy = [ ...
                grating_xy(s_freq, ph, th,    siz), ...
                grating_xy(s_freq, ph, th+90, siz)];
            
            % Set temporal phase
            
            
            % Log timing
            addLog(me, {'on', 't_ph'}, me.Scr.cFr);
        end
        
        function closeLog(me)
            % CLOSELOG  Convert pixel coordinates to degrees.
            
            closeLog@PsyPTB(me, 'pix2deg');
        end
        
        %% Subfunctions
        function p = get_p(me, op, feats, varargin)
            
            if strcmp(feats, 'all'), feats = me.feat_names; end
            
            for cc_feat = feats
                feat = cc_feat{1};
                
                switch op
                    case 'arithmetic'
                        S = varargin2S(varargin, {
                            'ease', 3.5
                            });

                        n_lev = me.n_lev_common;

                        if mod(n_lev, 2) == 1
                            k = [1:ceil(n_lev/2), ceil(n_lev / 2):-1:2] ...
                                * S.ease - S.ease + 1;

                            pr = [flipud(k(:)), k(:)];
                            me.prob.(feat) = bsxfun(@rdivide, pr, sum(pr,1));
                        else
                            error('Unsupported yet!');
                        end
                end
            end
        end
        
        %% Get/Set
        
    end
end