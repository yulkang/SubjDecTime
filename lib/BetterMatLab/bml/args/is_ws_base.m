function tf = is_ws_base % (debug)
% True if called from base workspace.
%
% 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.

tf = numel(dbstack) == 1;

% if debug
%     disp(is_ws_base(false));
% end
end