classdef Psy3DFilter < handle
	% (y,x,t) filter, whose fft is computed & stored efficiently.
	%
	% me.reg		: (y,x,t) filter in the time domain.
	% v = me.f(k)	: filter in the frequency domain,
	%				  to use for 2^(k-1) < t <= 2^k.
	%				  Calculated only on the first reference.
	
	
	properties
		reg		% (y,x,t) filter in the time domain.
	end
	
	
	properties (Access = private)
		freq = {}	% Filter in the frequency domain
					% freq{k}: Filter to use for 2^(k-1) < t <= 2^k.
					%		   Calculated only on the first reference.
	end
	
	
	methods
		function me = Psy3DFilter(v)
			me.reg = v;
		end
		
		
		function v = f(me, t)
            % v = f(me, t)
            %
            % Filter with t time bins.
            
%             % More straightforward version
%             v = fftn(me.reg, [sizes(me.reg, [1 2]), t]);
            
            % Caching version.
			nMax = nextpow2(t);
			tMax = pow2(nMax);
			
			if length(me.freq) < nMax || isempty( me.freq{nMax} )
				siz = [size(me.reg, 1) size(me.reg, 2) tMax];
				me.freq{nMax} = fftn(me.reg, siz);
			end
			
			v = me.freq{nMax};
		end
	end
end