function stop = optim_stop_if_naninf(~,optimValues,~,varargin)
% Stops if the cost is not finite.
%
% stop = optim_stop_if_naninf(x,optimValues,state,varargin)

stop = ~isfinite(optimValues.fval);
end
