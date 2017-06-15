classdef PsyVis_xy < PsyVis
    properties
        win = [];
        win_ = struct('rect', [0 0 1920 1080]', ...
                      'dist_cm', 60, ...
                      'width_cm', 40, ...
                      'refresh_rate_Hz', 60);
                  
        refresh_rate_Hz
    end
    
    properties (Dependent)
        pix2deg
    end
    
    methods 
        function initLogTrial(me)
            me.initLogTrial@PsyVis;
            
            me.copy_scr_info;
        end
        
        function copy_scr_info(me, c_win_ord)
            if nargin < 2, c_win_ord = 1; end
            
            c_Scr = me.Scr;
            
            try % New format with multiwindow support
                me.win      = c_Scr.win(c_win_ord);
                me.win_ = struct( ...
                    'rect',      c_Scr.info_win(c_win_ord).rect, ...
                    'dist_cm',   c_Scr.info_win(c_win_ord).distCm, ...
                    'width_cm',  c_Scr.info_win(c_win_ord).widthCm, ...
                    'refresh_rate_Hz', c_Scr.info_win(c_win_ord).refreshRate);
            catch err % Legacy format
                warning(err_msg(err));
                me.win      = c_Scr.info.win;
                me.win_ = struct( ...
                    'rect',      c_Scr.info.rect, ...
                	'dist_cm',   c_Scr.info.distCm, ...
                	'width_cm',  c_Scr.info.widthCm, ...
                    'refresh_rate_Hz', c_Scr.info.refreshRate);
            end
            
            me.refresh_rate_Hz = me.win_.refresh_rate_Hz;
        end
        
        function set_deg_xy(me, prop, pix, ix)
            
            c_deg = [];
            
            if nargin < 4
                
            else
            end
        end
        
        function deg = get_deg_xy(me, prop, ix)
            % prop : property name (pix).
            % ix   : cell array of indices
            
            if nargin < 3
                c_prop = me.(prop);
            else
                c_prop = me.(prop)(ix{:});
            end
            
            deg = c_prop * me.pix2deg;
        end
        
        function set_deg_rect(me, prop, pix, ix)
        end
        
        function deg = get_deg_rect(me, prop, ix)
        end
        
        %% Get/Set functions
        function v = get.pix2deg(me)
            
            w = me.win_;
            
            % deg / pix
            v = (w.width_cm / w.dist_cm / pi * 180) / (w.rect(3) - w.rect(1));
        end
        
%         function v = set.win_(me, v)
%             if ~isequal(me.win_, v)
%                 
%                 win_center_pix = [(v.rect(1) + v.rect(3)) / 2
%                                   (v.rect(2) + v.rect(4)) / 2];
%                 win_size_pix   = [ v.rect(3) - v.rect(1)
%                                    v.rect(4) - v.rect(2)];
%                 
%                 me.pix2deg = win_center_pix
%             end
%         end
    end
end