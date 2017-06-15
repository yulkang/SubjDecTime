function v = discrete_step(v, step, op, offset)
% discrete_step  Discretize to nearest value.
%
% v = discrete_step(v, step, op, offset)
%
% op = @round (default) | @ceil | @floor
% offset = 0

if ~exist('op', 'var'), op = @round; end
if ~exist('offset', 'var'), offset = 0; end

v = op((v - offset) / step) * step + offset;
