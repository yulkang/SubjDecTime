classdef FitParamsForcible2 < FitParams
% FitParams that allows force-setting th.
%
% 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.

properties (SetAccess = protected)
    th_forced = struct;
end
%% th_forced : Add/Override parameters
methods
    function add_th_forced(Params, name, v)
%         % Irreversible - overwrites Param unlike using struct th_forced.
%         Params.add_params({
%             {name, v, v, v}
%             });
        Params.th_forced.(name) = v;
    end
    function remove_th_forced(Params, name)
        Params.th_forced = rmfield(Params.th_forced, name);
    end
end
%% Modify FitParams
methods
    function S = get_struct(Params, prop)
        % S = get_struct(Params, prop)
        if nargin < 2, prop = 'th'; end
        S = Params.get_struct@FitParams(prop);

        S = copyFields(S, Params.th_forced);
        if ~strcmp(prop, 'th')
            % set th0, lb, ub for forced th as 0
            for name = fieldnames(Params.th_forced)'
                S.(name{1}) = zeros(size(S.(name{1})));
            end
        end
    end
end
%% Test
methods (Static)
    function Params = test
        Params = copyprops(FitParamsForceTh, FitParams.test);
        
        %% Test th_forced : overriding existing th
        Params.add_th_forced('param1', 123);
        disp(Params.th.param1);
        assert(isequal(Params.th.param1, 123));
        
        %% Test th_forced : adding new th
        Params.add_th_forced('param_forced', 456);
        disp(Params.th.param_forced);
        assert(isequal(Params.th.param_forced, 456));
    end
end
end