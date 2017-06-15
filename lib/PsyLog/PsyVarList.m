classdef PsyVarList < PsyBanner & TxtVarList
    properties
        edit_mode = false; 
        
        keys = struct % prev, next, inc, dec, inc_scale, dec_scale, toggle_edit
        Key
    end
    
    methods
        %% PsyLog interface
        function me = PsyVarList(cScr, vars, VarList_opt, Banner_opt)
            % me = PsyVarList(cScr, vars, VarList_opt, Banner_opt)
            %
            % See also: TxtVarList, TxtVarList.init_vars, PsyBanner
            
            if ~exist('cScr', 'var'), cScr = []; end
            if ~exist('vars',        'var'), vars = {}; end
            if ~exist('VarList_opt', 'var'), VarList_opt = {}; end
            if ~exist('Banner_opt',  'var'), Banner_opt  = {}; end
            
            me = me@PsyBanner(cScr, Banner_opt{:});
            me.updateOn = {'Key'};
            
            % PsyKey interface
            me.keys = varargin2S({}, {
                'prev'          'UpArrow'       
                'next'          'DownArrow'     
                'inc'           'LeftArrow'     
                'dec'           'RightArrow'    
                'inc_scale'     'PeriodRBrack'  
                'dec_scale'     'CommaLBrack'   
                'toggle_edit'   'LPrimeTilde'   
                });
            
            % Init variables
            if ~isempty(vars)
                init_vars(me, vars, VarList_opt{:});
            end
        end
        
        function update(me, from)
            if ~me.visible, return; end
            
            switch from
%                 case 'befDraw'
                case 'Key'
                    if ~me.Key.keyDown, return; end
                    
                    cKeyNames = me.Key.cKeyNames;
                    
                    if me.edit_mode
                        me.change_var(me, me.key2op(cKeyNames{1}));
                        
                    elseif any(strcmp(me.keys.toggle_edit, cKeyNames))
                        me.edit_mode = true;
                    end
            end
        end
        
        function res = draw(me, varargin)
            % res = draw(me, [win])
            
            me.txt = me.L2txt;
            res = me.draw@PsyBanner(varargin{:});
        end
        
        %% Internal
        function op = key2op(me, keyName)
            % op = key2op(me, keyName)
            
            ops    = fieldnames( me.keys);
            c_keys = struct2cell(me.keys);
            
            tf     = strcmp(keyName, c_keys);
            
            if any(tf)
                op = ops{tf};
            else
                op = '';
            end
        end
    end
    
    methods (Static)
        function me = test(varargin)
            me = PsyVarList(varargin{:});
        end
    end
end