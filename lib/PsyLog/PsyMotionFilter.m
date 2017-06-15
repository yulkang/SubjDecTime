classdef PsyMotionFilter < handle
	% Filter that PsyRDKCol uses to calculate momentary motion energy.
    %
    % .apply    : modify!! consider pow2(nextpow2(length1 + length2 - 1))
	%
	% filt		= psyMotionFilter('degPerPix', ~, 'dt', ~)
    %
    % Adapted from NYS's version. Optimized & wrapped into a class by HRK.
	
	properties
%         % degPerPix: assuming monitor width of 800 pix, 0.35m; 
%         %            and viewing distance of 0.58m.
%         %            as in Shadlen lab (UW) psychophysics rig.
%         %            Given RDKCol, adapts appropriately.
		degPerPix	= 0.0253; % Human 2D expr % 0.1319; % UW
        dt			= 1/75; % sec.
		
		ordX	= 4;
		sigX	= 0.35/4; % degree % NYS: 0.5 -- differ from Kiani 2008..
                        % Controls both envelope (deg) & slant (deg/sec).
                        % 0.35/4 because I mistakenly used 5/4 deg/sec.
		sigY	= 0.08;	% degree
		n1		= 3;	% after Kiani et al., 2008
		n2		= 5;	% after Kiani et al., 2008
		k		= 1/((4/75)/(3/60)*1/60); % 60;	% after Kiani et al., 2008
	
        lenX    = 75;   % 10 deg. Arbitrary value to help testing.
		lenY    = 75;   % 10 deg. Arbitrary value to help testing.
		lenT    = 60;   % 60 fr.  Arbitrary value to help testing.
		
		xVec
		yVec
		tVec
        
        addSec  = 0.2;
        
        RDKCol = [];
    end
    
    properties (Transient)
        % filters in the time domain
		filt = struct('left1', [], 'left2', [], 'right1', [], 'right2', []);
    end
    
    properties (Dependent)
        addFr
    end
	
	methods
		function me = PsyMotionFilter(RDKCol, varargin)
            % me = PsyMotionFilter(RDKCol, varargin)
            
            % If RDKCol is provided, use it to specify relevant properties.
            if nargin>=1 && ~isempty(RDKCol)
                me.RDKCol = RDKCol;
                
                me.degPerPix = 1/RDKCol.Scr.info.pixPerDeg;
                me.dt        = 1/RDKCol.Scr.info.refreshRate;
                
                if isempty(RDKCol.bwPix)
                    RDKCol.getCPix;
                end
                
                me.lenX	= round(size(RDKCol.bwPix, 2)); %  *2 - 1);
                me.lenY	= round(size(RDKCol.bwPix, 1)); %  *2 - 1);
            end
            
            me.lenT	= find(abs(me.tempImpResp(me.n2, me.k, ...
                                            0.15:me.dt:1)) ...
                                       < 1e-5, 1, 'first') ...
                                  + ceil(0.15/me.dt) + 1;
            
            % Otherwise, set each property manually. If not, use defaults.
			varargin2fields(me, varargin);
			
            me.init;
        end
        
        
        function init(me)
            % x/y/tVec
			me.xVec	= linspace(-(me.lenX-1)/2*me.degPerPix, ...
									(me.lenX-1)/2*me.degPerPix, me.lenX);
			me.yVec	= linspace(-(me.lenY-1)/2*me.degPerPix, ...
									(me.lenY-1)/2*me.degPerPix, me.lenY);
			me.tVec	= linspace(0, ...
								  (me.lenT-1)*me.dt, me.lenT);
							
			% temporal filters
			tFast	= me.tempImpResp(me.n1, me.k, me.tVec);
			tSlow	= me.tempImpResp(me.n2, me.k, me.tVec);

			% spatial filters along x
			[xEven,xOdd] = me.cauchy(me.xVec, me.sigX, me.ordX);

			% spatial filter along y
			yFilt	= exp(-me.yVec.^2/(2*me.sigY^2));

			% spatial filter: (y, x)
			yxEven	= yFilt' * xEven;
			yxOdd	= yFilt' * xOdd;

			% spatiotemporal filter: (y, x, t)
			fastOdd	= repmat(yxOdd, [1 1 length(me.tVec)]) ...
				   .* repmat(permute(tFast, [1 3 2]), ...
                            [length(me.xVec), length(me.yVec)]);

			fastEven= repmat(yxEven, [1 1 length(me.tVec)]) ...
				   .* repmat(permute(tFast, [1 3 2]), ...
                            [length(me.xVec), length(me.yVec)]);

			slowOdd = repmat(yxOdd, [1 1 length(me.tVec)]) ...
				   .* repmat(permute(tSlow, [1 3 2]), ...
                            [length(me.xVec), length(me.yVec)]);

			slowEven= repmat(yxEven, [1 1 length(me.tVec)]) ...
				   .* repmat(permute(tSlow, [1 3 2]), ...
                            [length(me.xVec), length(me.yVec)]);

			% final
			me.filt.left1	= Psy3DFilter(slowEven + fastOdd);
			me.filt.left2	= Psy3DFilter(fastEven - slowOdd);

			me.filt.right1	= Psy3DFilter(slowEven - fastOdd);
			me.filt.right2	= Psy3DFilter(fastEven + slowOdd);
        end
        
        
        function clearFilt(me)
            for cField = {'left1', 'left2', 'right1', 'right2'}
                delete(me.filt.(cField{1}));
            end
            me.filt = struct('left1', [], 'left2', [], 'right1', [], 'right2', []);
        end
        
        
        function h = show(me, ax, v)
            % h = show(me, ax, v)
            
			h.fig = gcf;
			if nargin<2, ax = 'tx'; end;
			if nargin<3, v = 0; end
			
			iField = 0;
			for cField = fieldnames(me.filt)'
				iField = iField + 1;
				
				switch ax
					case 'tx'
						[~, iY]	= min(abs(me.yVec - v));
						cSlice = squeeze(me.filt.(cField{1}).reg(iY,:,:));
					case 'ty'
						[~, iX]	= min(abs(me.xVec - v));
						cSlice = squeeze(me.filt.(cField{1}).reg(:,iX,:));
					case 'xy'
						[~, iT]	= min(abs(me.tVec - v));
						cSlice = squeeze(me.filt.(cField{1}).reg(:,:,iT));						
				end
				
				subplot(2,2,iField);
				h.(cField{1}) = pcolor(max(log10(abs(cSlice)), -3));
				set(h.(cField{1}), 'EdgeColor', 'none');
				title(cField{1});
				xlabel(ax(1));
				ylabel(ax(2));
			end
			
			colorbar;
		end
		
		
		function mE = apply(me, RDKCol, addSec) 
            % mE = apply(me, RDKCol, [addSec = 0.2])
            %
            % See also PsyRDKCol.EnMot

            if ~exist('addSec', 'var'), addSec = me.addSec; end
            if isempty(me.filt.left1), me.init; end
            
            % Optimize MATLAB's FFT.
            %   Takes a long time (~several seconds) on the first run, but
            %   improves performance throughout the current matlab session.
			fftw('planner', 'patient');	
            
            if isnumeric(RDKCol) % xyct was fed
                xyct = RDKCol;
                if isempty(me.RDKCol)
                    RDKCol = PsyRDKCol;
                else
                    RDKCol = me.RDKCol;
                end
                RDKCol.xyct = xyct;
                RDKCol.getCPix;
            end
			
            cTLen  = size(RDKCol.bwPix,3) ...
                   + round(addSec / me.dt);
            
            sizOrig = [sizes(RDKCol.bwPix, [1 2]), cTLen];
			
            cTLen  = pow2(nextpow2(cTLen));

            cBWPix = cat(3, RDKCol.bwPix, ...
                            zeros([sizes(RDKCol.bwPix,[1 2]), ...
                                cTLen - size(RDKCol.bwPix,3)]));
               
			fStim	= fftn(cBWPix);
			
%             resp.left1 = real(ifftn( fStim .* me.filt.left1.f(cTLen)));
%             resp.left2 = real(ifftn( fStim .* me.filt.left2.f(cTLen)));
%             resp.right1 = real(ifftn( fStim .* me.filt.right1.f(cTLen)));
%             resp.right2 = real(ifftn( fStim .* me.filt.right2.f(cTLen)));
            
			for cFields = fieldnames(me.filt)'
				cField = cFields{1};
				
				resp.(cField) = real(ifftn( fStim .* me.filt.(cField).f(cTLen)));
			end
			
			resp.right	= sqrt(resp.right1 .^2	+ resp.right2 .^2);
			resp.left	= sqrt(resp.left1 .^2	+ resp.left2 .^2);
			
			mE = squeeze(sum(sum(resp.right - resp.left, 1),2));
            
            mE = mE(1:sizOrig(3));
        end
        function v = get.addFr(me)
            v = me.addSec / me.dt;
        end
    end
    %% Across-trial
    methods
        function mE_trs = get_mE_trs(Filt, xyct_trs)
            % xyct_trs{tr}(dot, [x_pix, y_pix, color, fr])
            % mE_trs{tr}(fr) : motion energy

            assert(iscell(xyct_trs));
            n_tr = numel(xyct_trs);
            mE_trs = cell(n_tr, 1);

            t_st = tic;
            fprintf('Applying filter to %d trials began at %s\n', ...
                n_tr, datestr(now, 30));

            for tr = 1:n_tr % DEBUG
                mE_trs{tr} = Filt.apply(xyct_trs{tr}); %#ok<PFBNS>
            end

            t_el = toc(t_st);
            fprintf('Applying filter to %d trials took %1.2f sec\n', ...
                n_tr, t_el);
        end
    end
    %% Filter construction
	methods (Static)	
		function time_response = tempImpResp(n,k,t)
			% time_response = temp_imp_resp(n,k,t)
			%
			% Produces a temporal impulse response function using the from from
			% figure 1 in Adelson & Bergen (1985)
			%
			% It's pretty much a difference of Poisson functions with different
			% time constants.
            %
			% Geoff Boynton wrote this at CSH '95

			time_response=(k*t).^n .* exp(-k*t).*(1/factorial(n)-(k*t).^2/factorial(n+2));
        end
		function [xEven xOdd] = cauchy(x, sigX, ordX)
            % [xEven xOdd] = cauchy(x, sigX, ordX)
            %
			% Kiani et al., 2008
			
			alpha	= atan2(x, sigX);
			xCommon = cos(alpha).^ordX;
			xEven	= xCommon .* cos(ordX .* alpha);
			xOdd	= xCommon .* sin(ordX .* alpha);
        end
    end
    %% Loading
    methods (Static)
        function me = loadobj(me)
        end
	end
end