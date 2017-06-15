classdef PsyColorGabor < PsyMultinomial & PsyVis_xy
properties
    th = [];
    
    xy_pix = [900 500]';
    size_pix = [150 150]';
    
    fr_scr = 0;
    update_every_fr = 20;
    on_for_fr = 10;
    
    gabor_lam_pix = 3;
    gabor_sig_pix = 40;
    
    gabor_contrast = 1;
    gabor_aspectratio = 1;
    
    gabor_n_ph = 10;
    
    gabor_id
    
    use_procedural_gabor = false;
    
    color_reper = [255 255 0; zeros(1,3) + (255-128)*2/3 + 128; 0 255 255]/2; % Adjust to equiluminant values
    angle_reper = [-40 0 40];
    
    history_phase % nuisance parameter    
    
    add_neutral = {'end', 'end'};
end

properties (Transient)
    f_draw % Function handle that retrieves params from history for the trial
    
    gabor_array
end

properties (Dependent)
    rect_pix
    
    xy_deg
    size_deg
    gabor_sig_deg    
    
    update_every_sec
    on_for_sec
    max_sec
    
    n_color_reper
    n_angle_reper
end

properties (Constant)
    dim_angle = 1;
    dim_color = 2;
end

methods
    function me = PsyColorGabor(cScr, varargin)
        if nargin > 0
            me.Scr = cScr;
        end
        
        % Defaults
        me.updateOn = {'befDraw'};
        
        me.dim_names = {'angle', 'color'};
        me.prob = {[0.3 0.3 0.4], [0.3 0.3 0.4]};
        
        me.refresh_rate_Hz = 60;
        
        me.init(varargin{:});
    end
    
    function init(me, varargin)
%         me.init@PsyMultinomial(varargin{:});
        varargin2fields(me, varargin);

        % Angle and Color
        me.history = rand(me.n_fr, me.n_dim);
        
        % Assuming independent dimensions,
        for i_dim = 1:me.n_dim
            me.history(:,i_dim) = discretize(me.history(:,i_dim), ...
                cumsum(me.prob{i_dim}), 'abs');
            
            switch me.add_neutral{i_dim}
                case 'end'
                    me.history(end,i_dim) = round(length(me.prob{i_dim})/2);
            end
        end
        
        % Phase
        if me.use_procedural_gabor
            me.history_phase = rand(me.n_fr, 1) * 360;
        else
            me.history_phase = randi(me.gabor_n_ph, [me.n_fr, 1]);
        end
        
        % Drawing function
        if me.use_procedural_gabor
            me.f_draw = @(c_fr, c_win) ...
                Screen('DrawTexture', c_win, me.gabor_id, [], ...
                    me.rect_pix, ...
                    me.angle_reper(me.history(c_fr, PsyColorGabor.dim_angle))', [], [], ...
                    me.color_reper(me.history(c_fr, PsyColorGabor.dim_color),:), [], kPsychDontDoRotation, ...
                    [me.history_phase(c_fr), 1/me.gabor_lam_pix, me.gabor_sig_pix, ...
                    me.gabor_contrast * 100, me.gabor_aspectratio, 0, 0, 0]);
        else
            me.f_draw = @(c_fr, c_win) ...
                Screen('DrawTexture', c_win, me.gabor_id(me.history_phase(c_fr)), [], ...
                    me.rect_pix, ...
                    me.angle_reper(me.history(c_fr, PsyColorGabor.dim_angle))', [], [], ...
                    me.color_reper(me.history(c_fr, PsyColorGabor.dim_color),:));
        end
    end
    
    function init_gabor(me, varargin)
        varargin2fields(me, varargin{:});
        
        if isempty(me.win) && isa(me.Scr, 'PsyScr')
            try
                me.win = me.Scr.win(1);
            catch err
                error('Must perform Scr.open() before ColorGabor.init_gabor() !');
            end
        else
            error('Must specify win property to initialize a procedural gabor!');
        end
        
        if me.use_procedural_gabor
            [me.gabor_id, me.gabor_rect_pix] = CreateProceduralGabor(me.win, ...
                me.size_pix(1,:)*2, me.size_pix(2,:)*2, [], [0.5 0.5 0.5 0]);
        else
            for i_ph = 1:me.gabor_n_ph
                me.gabor_array(:,:,:,i_ph) = gabor( ...
                    'size', me.size_pix * 2 + 1, ...
                    'lam_pix', me.gabor_lam_pix, ...
                    'sig_pix', me.gabor_sig_pix, ...
                    'ph_deg', (i_ph - 1) / me.gabor_n_ph * 360);
                me.gabor_id(i_ph) = Screen('MakeTexture', me.win, ...
                    me.gabor_array(:,:,:,i_ph));
            end
        end
    end
    
    function initLogTrial(me)
        me.initLogTrial@PsyVis_xy;
        me.initLogTrial@PsyMultinomial;
        
        me.fr_scr = 0;
    end
    
    function update(me, from)
        % update(me, from)
        
        if strcmp(from, 'befDraw')
            
            me.fr_scr = me.fr_scr + 1;
            
            if mod(me.fr_scr-1, me.update_every_fr) == 0
                me.fr = me.fr + 1;
            end
        end
    end
    
    function res = draw(me, c_win)
        % res = draw(me, c_win)
        
        if nargin < 2, c_win = me.win; end
        
        if mod(me.fr_scr-1, me.update_every_fr) < me.on_for_fr
            if nargin < 2, c_win = me.win; end
        
            c_fr = me.fr;
            
            if c_fr <= me.n_fr
                me.f_draw(c_fr, c_win);
            end
        end
        
        res = true;
    end
    
    function res = get_ev(me, feat, kind, ix)
        % res = get_ev(me, feat, kind, ix)
        
        if nargin < 3, kind = 'mom'; end
        if nargin < 4, ix = 1:me.fr; end
        
        c_dim = PsyColorGabor.(['dim_' feat]);
        
        res = me.history(ix, c_dim);
        
        c_logit = log2(me.prob{c_dim});
        c_logit = c_logit - fliplr(c_logit);
        
        res = c_logit(res);
        
        switch kind
            case 'mom'
            case 'cum'
                res = cumsum(res);
            case 'sum'
                res = sum(res);
        end
    end
    
    %% Get/Set functions
    function v = get.rect_pix(me)
        
        c_xy_pix    = me.xy_pix;
        c_size_pix  = me.size_pix;
        
        v = [c_xy_pix - c_size_pix; c_xy_pix + c_size_pix]';
    end
    
    function set.max_sec(me, v)
        me.n_fr = ceil(v * me.refresh_rate_Hz / me.update_every_fr);
    end
    
    function set.n_angle_reper(me, v)
        me.angle_reper = linspace(-45, 45, v);
%         switch v
%             case 3
%                 me.angle_reper = [-40 0 40];
%             case 5
%                 me.angle_reper = [-60, -30, 0, 30, 60];
%         end
    end
    
    function set.n_color_reper(me, v)
        switch v
            case 3
                me.color_reper = ...
                    [255 255 0; 
                    zeros(1,3) + (255-128)*2/3 + 128; 
                    0 255 255]/2; % Adjust to equiluminant values
            case 5
                me.color_reper = ...
                    [255 0 0; 
                     150 100 0
                    zeros(1,3) + (255-128)*2/3 + 128; 
                    0 150 150
                    0 100 255]/2; % Adjust to equiluminant values
        end
    end
end

methods (Static)
    function ColorGabor = test(varargin)
        C = varargin2C(varargin, {
            'prob', {[0.1 0.45 0.45], [0.1 0.45 0.45]}
            });
        
        Scr = PsyScr('scr', 1, 'skipSyncTests', 1, 'refreshRate', 60, 'bkgColor', [128 128 128]);
        ColorGabor = PsyColorGabor(Scr, C{:});
        
        Scr.open;
        ColorGabor.init_gabor;
        
        Scr.addObj('Vis', ColorGabor);
        Scr.initLogTrial;
        
        ColorGabor.show;
        
        Scr.wait('ColorGabor', @() false, 'for', 10, 'sec');
        
        ColorGabor.hide;
        Scr.closeLog;
        Scr.close;
    end
end
end