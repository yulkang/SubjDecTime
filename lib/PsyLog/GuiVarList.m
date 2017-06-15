classdef GuiVarList < TxtVarList
    properties
        h_fig   % figure
        h_txt   % VarList textbox
        
        edit_mode = true;
        
        % Input - General
        key_map
        interface_input = 'gui'; % 'gui'|'ptb'

        % Input - PsyLog
        Key
        updateOn = {};
    end
    
    properties (Constant)
        key_map_gui = varargin2S({}, {
            'backquote',    'toggle_edit'
            'leftarrow',    'dec'
            'rightarrow',   'inc'
            'downarrow',    'next'
            'uparrow',      'prev'
            'comma',        'dec_scale'
            'period',       'inc_scale'
            'leftbracket',  'prev5th'
            'rightbracket', 'next5th'
            });
        key_map_ptb = varargin2S({}, {
            'LPrimeTilde',  'toggle_edit'
            'LeftArrow',    'dec'
            'RightArrow',   'inc'
            'DownArrow',    'next'
            'UpArrow',      'prev'
            'CommaLBrack',  'dec_scale'
            'PeriodRBrack', 'inc_scale'
            'LSBrackLCBrack', 'prev5th'
            'RSBrackRCBrack', 'next5th'
            });
    end
    
    methods
        function me = GuiVarList(vars, opt_varlist, varargin)
            if nargin < 2, opt_varlist = {}; end
            
            me = me@TxtVarList(vars, opt_varlist{:});
            me = varargin2fields(me, varargin);
            
            switch me.interface_input
                case 'gui'
                    if isempty(me.h_fig), me.h_fig = gcf; end
                    
                    me.key_map = GuiVarList.key_map_gui;
                    set(me.h_fig, 'KeyPressFcn', @(h,e) key(me,h,e));
                    
                case 'ptb'
                    me.key_map = GuiVarList.key_map_ptb;
                    me.updateOn = {'Key'};
            end
            
            % Textbox and Callbacks
            me.h_txt = uicontrol_fill(gca, 'String', me.L2txt, ...
                'Position', [0.05, 0.05, 0.9, 0.9]);
        end
        
        function key(me, ~, evt)
            c_key = evt.Key;
            
            c_key_map = me.key_map;
            
            if isfield(c_key_map, c_key)
%                 if strcmp(c_key_map.(c_key), 'toggle_edit')
%                     me.edit_mode = ~me.edit_mode;
%                 end
%                 
%                 if me.edit_mode
                    change_var(me, me.key_map.(c_key));
%                 end
            end
            
            if me.draw_on_update, draw(me); end
        end
        
        function res = draw(me, ~)
            set(me.h_txt, 'String', me.L2txt);
            
            drawnow('update');
            
            res = true;
        end
        
        function [res, change_in_val, changed_var, changed_val] = update(me, from)
            
            cKey = me.Key;
            
            if ~strcmp(from, 'Key') || ~cKey.keyDown, return; end
                
            cKeyName = cKey.cKeyNames{1};
            
            c_key_map = me.key_map;
            
            if any(strcmp(cKeyName, fieldnames(c_key_map)))
                [change_in_val, changed_var, changed_val] = ...
                    change_var(me, c_key_map.(cKeyName));
            else
                change_in_val = false;
                changed_var = '';
                changed_val = [];
            end
            
            res = true;
        end
    end
    
    methods (Static)
        function me = test(varargin)
            me = GuiVarList(TxtVarList.test_var, varargin{:});
            me.draw_on_update = true;
        end
    end
end

