function varargout = angleOp(varargin)
% varargout = angleOp(op, varargin)
%
% Various operations in angular domain.
%
%
% res = angleOp('diff', traj)
% : Analog of diff(). 
%   Assumes increment within the range of -pi to pi.
%
% EX> angleOp('diff', 0:(pi/2):(3*pi))) / pi
%     ans = 0.5 0.5 0.5 0.5 0.5 0.5
% 
%
% res = angleOp('diff', traj)
% : Direction of trajectory.
%   The trajectory should be unidirectional everywhere, and
%   every step within the range of -pi to pi.
%
% EX> angleOp('trajDir', [1.5 0 0.5]*pi) 
%     ans = 1
% EX> angleOp('trajDir',-[1.5 0 0.5]*pi) 
%     ans = -1
%
%
% res = angleOp('minus2', angle1, angle2, signRes)
% : angle1 - angle2
%   signRes =  1 to assume CCW-increasing angle system (default),
%            and to get res in [0, 2*pi] range.
%   signRes = -1 to assume CW-increasing angle system,
%            and to get res in [-2*pi, 0] range.
%
% EX> angleOp('minus2', -0.5*pi, pi) / pi
%     ans = 0.5
% EX> angleOp('minus2', -0.5*pi, pi, -1) / pi
%     ans = -1.5
%
%
% res = angleOp('sgnMinus2', angle1, angle2, signRes)
%
% : Similar to minus2 but res is between -pi to pi.
%
%
% res = angleOp('rel', traj)
% : Shift trajectory's coordinate so that it starts from zero.
%   Assumes increment within the range of -pi to pi.
%
% EX> angleOp('rel', [1.5 0 0.5]*pi) / pi
%     ans = 0 0.5 1
%
%
% res = angleOp('within', probe, traj)
% : Whether the probe resides within the given trajectory.
%   The trajectory should be unidirectional everywhere,
%   every step within the range of -pi to pi, and
%   the whole span within a cycle.
%
% EX> angleOp('within', 1.9*pi, [-0.5 0 0.5]*pi)
%     ans = true
%
%
% res = angleOp('interpolate', probe, traj, t)
% : From a timeseries of trajectory and timestamps,
%   estimate the time of the probe within the trajectory
%   by linear interpolation.
%   The trajectory should be unidirectional everywhere,
%   every step within the range of -pi to pi, and
%   the whole span within a cycle.
%
% EX> angleOp('interpolate', 1.9*pi, [-0.5 0 0.5]*pi, [0 1 2])
%     ans = 0.8
% EX> angleOp('interpolate', 1.9*pi, [0.5 0 -0.5]*pi, [0 1 2])
%     ans = 1.2
%
%
% res = angleOp('extrapolate', probe, traj, t)
% : From a timeseries of trajectory and timestamps,
%   estimate the time of the probe outside the trajectory
%   by linear extrapolation, from the nearest end of the trajectory.
%   The trajectory should be unidirectional everywhere,
%   every step within the range of -pi to pi, and
%   the whole span within a cycle.
%
% EX> angleOp('extrapolate', 1.1*pi, [-0.5 0 0.5]*pi, [0 1 2])
%     ans = -0.8
% EX> angleOp('extrapolate', 1.1*pi, [0.5 0 -0.5]*pi, [0 1 2])
%     ans = 2.8
%
%
% written by Yul Kang, Jul 2012.
[varargout{1:nargout}] = angleOp(varargin{:});