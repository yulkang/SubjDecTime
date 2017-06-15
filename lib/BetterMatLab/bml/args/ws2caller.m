% ws2caller : pseurofunction that copies current workspace to the caller's.
% 
% Arguments
% ---------
% ws2caller_vars_excl
% ws2caller_vars_incl

if exist('ws2caller_vars_excl_', 'var')
    ws2caller_vars_excl_ = {'ws2caller_vars_incl_', 'ws2caller_vars_excl_', 'ws2caller_vars_'};
end
if ~exist('ws2caller_vars_incl_', 'var')
    ws2caller_vars_incl_ = who';
end

for ws2caller_vars_ = setdiff(ws2caller_vars_incl_, ws2caller_vars_excl_)
    assignin('caller', ws2caller_vars_{1}, eval(ws2caller_vars_{1}));
end

clear ws2caller_vars_ ws2caller_vars_excl_ ws2caller_vars_incl_