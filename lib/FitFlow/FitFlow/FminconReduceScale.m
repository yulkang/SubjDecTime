classdef FminconReduceScale < FminconReduce
    % Scales inputs to be between 0 and 1 (between lb and ub),
    % so that their gradients are comparable.
    %
    % !!!!!!!!!!!!!!!!! UNDER CONSTRUCTION !!!!!!!!!!!!!!!!!!!!!!
    
    % Perhaps UNNECESSARY since Test.fmincon_scale doesn't show any
    % effect of scale.
%
% 2015 (c) Yul Kang. yul dot kang dot on at gmail dot com.
methods
    function v = get_x_vec_all(F, x_vary)
        x_vary = 
        v = F.get_fill_vec(F.get_x0
    end
    function v = get_fill_mat(F, v, v_diag)
        % 
    end
end
end  