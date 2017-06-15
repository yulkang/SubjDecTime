function varargout = angleOp(op, varargin)
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


switch op
    case 'diff'
        % res = angleOp('diff', traj)
        % : Analog of diff(). 
        %   Assumes increment within the range of -pi to pi.
        %
        % EX> angleOp('diff', 0:(pi/2):(3*pi))) / pi
        %     ans = 0.5 0.5 0.5 0.5 0.5 0.5
        
        varargout{1} = mod(diff(varargin{1}) + pi, 2*pi) - pi;
    
    case 'trajDir'
        % res = angleOp('trajDir', traj)
        % : Direction of trajectory.
        %   The trajectory should be unidirectional everywhere, and
        %   every step within the range of -pi to pi.
        %
        % EX> angleOp('trajDir', [1.5 0 0.5]*pi) 
        %     ans = 1
        % EX> angleOp('trajDir',-[1.5 0 0.5]*pi) 
        %     ans = -1
        
        varargout{1} = sign(angleOp('diff', varargin{1}([1 2])));
        
    case 'minus2'
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
        
        if nargin < 4, signRes = 1; else signRes = varargin{3}; end
            
        if signRes == 1
            varargout{1} = mod(varargin{1} - varargin{2}, pi*2);
        else
            varargout{1} = -mod(varargin{2} - varargin{1}, pi*2);
        end
        
    case 'sgnMinus2'
        % res = angleOp('sgnMinus2', angle1, angle2, signRes)
        %
        % : Similar to minus2 but res is between -pi to pi.
        
        varargout{1} = angleOp('minus2', varargin{:});
        
        tf = varargout{1} > pi;
        
        varargout{1}(tf) = varargout{1}(tf) - pi*2;
        
    case 'rel'
        % res = angleOp('rel', traj)
        % : Shift trajectory's coordinate so that it starts from zero.
        %   Assumes increment within the range of -pi to pi.
        %
        % EX> angleOp('rel', [1.5 0 0.5]*pi) / pi
        %     ans = 0 0.5 1
        
        varargout{1} = [0 cumsum(angleOp('diff', varargin{1}))];
        
    case 'within'
        % res = angleOp('within', probe, traj)
        % : Whether the probe resides within the given trajectory.
        %   The trajectory should be unidirectional everywhere,
        %   every step within the range of -pi to pi, and
        %   the whole span within a cycle.
        %
        % EX> angleOp('within', 1.9*pi, [-0.5 0 0.5]*pi)
        %     ans = true
        
        probe   = varargin{1};
        traj    = varargin{2};
        
        dTraj   = traj(2) - traj(1);
        
        dProbe  = angleOp('diff', [traj(1) probe traj(end)]);
        
        varargout{1} = (sign(dProbe(1)) == sign(dTraj)) && ...
                       (sign(dProbe(2)) == sign(dTraj));
           
    case 'interpolate'
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
        
        traj    = angleOp('rel', varargin{2});
        sTraj   = angleOp('trajDir', traj);
        
        probe   = angleOp('minus2', varargin{1}, varargin{2}(1), sTraj);
        t       = varargin{3};
        
        iInf    = find(sTraj * (traj - probe) <= 0, 1, 'last');
        iSup    = find(sTraj * (traj - probe) >= 0, 1, 'first');
        
        infimum = t( iInf );
        supremum= t( iSup );
            
        if infimum == supremum
            varargout{1} = infimum;
        else            
            ratio    = (probe - traj(iInf)) / (traj(iSup) - traj(iInf));
        
            varargout{1} = infimum + (supremum - infimum) * ratio;            
        end
        
        varargout{2} = infimum;
        varargout{3} = supremum;
        
    case 'extrapolate'
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
        
        probe   = varargin{1};
        traj    = varargin{2};
        t       = varargin{3};
        
        sTraj   = angleOp('trajDir', traj);
        
        diff0   = angleOp('minus2', traj(end), traj(1),   sTraj);        
        tDiff   = t(end) - t(1);
        
        vDiff   = diff0 / tDiff;
        
        diff1   = angleOp('minus2', traj(1),   probe  ,   sTraj);
        diff2   = angleOp('minus2', probe,     traj(end), sTraj);
        
        if abs(diff1) < abs(diff2) % If start point is closer
            varargout{1} = t(1) - diff1 / vDiff;
            
        else % If end point is closer            
            varargout{1} = t(end) + diff2 / vDiff;            
        end        
end
end