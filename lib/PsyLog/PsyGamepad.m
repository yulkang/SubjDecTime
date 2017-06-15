classdef PsyGamepad < PsyKey
    properties
        h_pad
        
        pad_name
        
        h
        n_all
        n_axis
        n_button
        n_hat
        kind
        names
        kind_names
        names_hat = {}; 
        enabled
        state
        
        emul_PsyKey = true; % Emulate PsyKey behavior
        keyNames_h = {}; % Corresponding key names
        keyNames_hat = {}; 
        down % To prevent repetitive keyDown event
        
        last_querried = 0;
        n_querry = 1;
        querry_count
        
        axis0    = [127, 127];
        axis_tol = [-5, 5, -5, 5]; % x_min, x_max, y_min, y_max, after subtracting axis0.
        max_n_axis = 100; % Maximum number of axis samples per trial
        
        log_axis = false;
    end
    
    methods
        function Pad = PsyGamepad(varargin)
            Pad = Pad@PsyKey(varargin{:});
            Pad.tag = 'Pad';
            
            if nargin > 0
                Pad.Scr = varargin{2};
                
                varargin2fields(Pad, varargin(2:end));
            end
        end
        
        function open(Pad)
            %% Open device
            Gamepad('Unplug'); % Initialize Gamepad
            pause(0.1);
            n_pad = Gamepad('GetNumGamepads');
            
            if n_pad == 0
                warning('No gamepad is detected!');
                return;
            elseif n_pad > 1 % May enable choosing if necessary
                warning('Multiple gamepads are detected!');
                return;
            end
            
            Pad.h_pad = 1;
            Pad.pad_name = Gamepad('GetGamepadNamesFromIndices', Pad.h_pad);
            Pad.pad_name = Pad.pad_name{1};
            
            disp('Detected gamepad:');
            disp(Pad.pad_name);
            
            n_a = Gamepad('GetNumAxes',    Pad.h_pad);
            n_b = Gamepad('GetNumButtons', Pad.h_pad);
            n_h = Gamepad('GetNumHats',    Pad.h_pad);
            Pad.n_all = n_a + n_b + n_h;
            
            %% Allocate axis/button/hat handles and properties
            Pad.kind  = blanks(Pad.n_all)';
            Pad.names = cell(Pad.n_all, 1);
            Pad.enabled = true(Pad.n_all, 1);
            Pad.state = int32(zeros(Pad.n_all, 1));
            Pad.h     = zeros(Pad.n_all, 2);
            Pad.querry_count = ones(Pad.n_all, 1);
            i_h = 0;
            
            for ii = 1:n_a
                i_h = i_h + 1;
                Pad.h(i_h,:) = Gamepad('GetAxisRawMapping', Pad.h_pad, ii);
                Pad.kind(i_h) = 'a';
                Pad.kind_names{i_h} = sprintf('a%d', ii);
                
                if mod(ii,2) == 1
                    % When querrying x, always querry y, too.
                    Pad.querry_count(i_h) = 0;
                end
            end
            for ii = 1:n_b
                i_h = i_h + 1;
                Pad.h(i_h,:) = Gamepad('GetButtonRawMapping', Pad.h_pad, ii);
                Pad.kind(i_h) = 'b';
                Pad.kind_names{i_h} = sprintf('b%d', ii);
            end
            for ii = 1:n_h
                i_h = i_h + 1;
                Pad.h(i_h,:) = Gamepad('GetHatRawMapping', Pad.h_pad, ii);
                Pad.kind(i_h) = 'h';
                Pad.kind_names{i_h} = sprintf('h%d', ii);
            end

            %% Allocate names
            switch Pad.pad_name
                case 'Logitech Dual Action'
                    Pad.names_hat = {
                        'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'O'}; % After dividing state by 45.
                    Pad.keyNames_hat = { ...
                        'u', 'i', 'k', 'CommaLBrack', 'm', 'n', 'h', 'y', ''};
                    Pad.names = {...
                        'LX', 'LY', 'RX', 'RY', ...
                        'X', 'A', 'B', 'Y', ...
                        'LB', 'RB', 'LT', 'RT', ...
                        'Back', 'Start', ...
                        'LA', 'RA', ...
                        'Hat'};
                    Pad.keyNames_h = {
                        'a', 'd', 'l', 'PrimeDPrime', ...
                        'LeftArrow', 'DownArrow', 'RightArrow', 'UpArrow', ... 
                        'z', 'SlashQuestion', 'LeftShift', 'RightShift', ...
                        'LSBrackLCBrack', 'RSBrackRCBrack', ...
                        's', 'SColonColon', ...
                        '' % Name to hat is ignored. Set keyNames_hat instead.
                        };
            end
            
            %% Link to PsyKey
            init(Pad, exclude_empty([Pad.keyNames_hat, Pad.keyNames_h]));
            
            %% Add axis log
            if Pad.log_axis
                initLogEntries(Pad, 'val2', {'axis'}, 'absSec', ...
                    int16(zeros(1,n_a*2)), Pad.max_n_axis);
            end
            
            %% Copy temporary variables
            Pad.n_axis   = n_a;
            Pad.n_button = n_b;
            Pad.n_hat    = n_h;
        end
        
        function get(Pad)
            % Querries only one or several enabled buttons and axis,
            % so that it takes least time per call.
            
            persistent p_down p_state
            
            %% Temporary variables
            cq = Pad.last_querried;
            
            c_n_all  = Pad.n_all;
            c_state  = Pad.state;
            % c_enabled= Pad.enabled; % TODO
            c_h      = Pad.h;
            c_kind   = Pad.kind;
            c_axis0  = Pad.axis0;
            c_tol    = Pad.axis_tol;
            c_down   = zeros(c_n_all,1);
            c_n_querry = Pad.n_querry;
            c_querry_count = Pad.querry_count;
            
            ii = 0;
            cKeyNames = {};
            
            if isempty(p_down)
                p_down = false(c_n_all, 1); 
                p_state = zeros(c_n_all, 1); 
                p_state(c_kind == 'h') = 360; % Default state
            end
            
            %% Timestamp
            c_sampledAbsSec = GetSecs;
            Pad.sampledAbsSec = c_sampledAbsSec;
            
            %% Querry
            while ii < c_n_querry
                cq = mod(cq, c_n_all) + 1;
                ii = ii + c_querry_count(cq); % y-axis doesn't count against n_querry.
                        
                %% Determine cKeyDown
                switch c_kind(cq)
                    case 'a' % Querry both axes at once
                        c_state(cq) = PsychHID('RawState', c_h(cq,1), c_h(cq,2));
                        
                        c_state(cq) = c_state(cq) - c_axis0(1);
                        c_state(cq) = c_state(cq) ...
                                    * int32((c_state(cq) < c_tol(1)) || (c_state(cq) > c_tol(2)));
                        
                        c_down(cq)  = c_state(cq) ~= 0;
                        cKeyDown(cq) = c_down(cq) && ~p_down(cq);
                        
                        if cKeyDown(cq)
                            cKeyNames = [cKeyNames, Pad.keyNames_h(cq)];
                        end
                        
                    case 'b'
                        c_state(cq) = PsychHID('RawState', c_h(cq,1), c_h(cq,2)); % 0 or 1
                        c_down(cq)  = c_state(cq);
                        cKeyDown(cq) = c_down(cq) && ~p_down(cq);
                        
                        if cKeyDown(cq)
                            cKeyNames = [cKeyNames, Pad.keyNames_h(cq)];
                        end
                        
                    case 'h'
                        c_state(cq) = PsychHID('RawState', c_h(cq,1), c_h(cq,2)) / 45;
                        c_down(cq)  = c_state(cq) ~= 360/45;
                        cKeyDown(cq) = c_down(cq) && (c_state(cq) ~= p_state(cq));
                        
                        if cKeyDown(cq)
                            cKeyNames = [cKeyNames, Pad.keyNames_hat(c_state(cq))];
                        end
                end                
            end
            Pad.last_querried = cq;
            p_state = c_state;
            p_down  = c_down;
            Pad.state = c_state;
            
            %% Log if cKeyDown
            Pad.keyDown = cKeyDown;
            
            if any(cKeyDown)
                addLog(Pad, cKeyNames, c_sampledAbsSec);
            end
            
            if Pad.log_axis && any(c_state(c_kind == 'a'))
                addLog(Pad, 'axis', c_sampledAbsSec, c_state(c_kind == 'a'));
            end
        end
        
        function tf = keyName_ix(Pad, nam)
            tf = strcmp(nam, Pad.keyNames);
        end
        
        function tf = name_ix(Pad, nam)
            tf = strcmp(nam, Pad.names);
        end
        
        function close(~)
            Gamepad('Unplug');
        end
    end
    
    methods (Static)
        function [Pad, tt1, tt2, bb] = test(nam)
            if nargin < 1, button_ix = 1; end
            if nargin < 2, axis_ix = 1; end
            if nargin < 3, hat_ix = 1; end
            
            Pad = PsyGamepad;
            % Pad.log_axis = true;
            Pad.open;
            
            %%
            n = 10000;
            
            tt1 = zeros(1,n);
            tt2 = zeros(1,n);
            bb = zeros(n,1);
            
            %%
            if nargin == 0 || isempty(nam)
                nam = input_def('What to monitor', 'choices', Pad.names);
                ix  = strcmp(nam, Pad.names);
                
                input( ...
                    sprintf('Querrying %s. Try pushing a button after pressing ENTER: ', ...
                        nam), ...
                    's');
            else
                ix  = strcmp(nam, Pad.names);
            end
            
            tic;
            for ii = 1:n
                tt1(ii) = GetSecs;
                Pad.get;
                bb(ii) = Pad.state(ix);
                tt2(ii) = GetSecs;
            end
            toc;
            fprintf('%d samples have been taken.\n', n);

            fig_tag(nam);
            subplot(4,1,1);
            plot(bb(:,1)); ylabel('state');
            subplot(4,1,2);
            hist(bb(:,1)); xlabel('state'); ylabel('#querry');
            subplot(4,1,3);
            plot(tt2 - tt1); ylabel('\Delta t'); ylim([0 0.002]); 
            subplot(4,1,4);
            x_bins = 0:0.0001:0.002;
            hist(tt2 - tt1, x_bins); xlim(x_bins([1 end])); xlabel('\Delta t');
        end
    end
end
        