function D =  conv_dtbAA_sigs_ns_drift_var_y0(drift,t,Bup,Blo,y,p0,notabs_flag,diffusion)
% D =  conv_dtbAA_ns_drift_var_y0(drift,t,Bup,Blo,y,p0,notabs_flag,diffusion)
%
% Convolution dtb with nonstationary drift, variance, and p0.
% Strictly preserves the sum even when variance is low (< 0.5).
%
% Antialiased version, which gives
% solutions to bounded drift diffusion (drift to bound).
% This can handle arbitrary changing bounds.
%
% Evidence space is antialiased, removing the 'spiking' phenomenon.
%
% Inputs (all in SI units)
% ~~~~~~~~~~~~~~~
% drift:     (1) vector of drift rates, or
%            (2) ncond x length(t) matrix.
% t:         time series in seconds
% Bup & Blo: vector bounds with  Blo(t) < Bup(t)
%            or can be scalars if bounds are flat,
%            +/-Inf bounds are allowed
% y:         vector of values of y to propagate: length must be a power of 2
%            sensible range to choose is (with dt=sampling interval)
%            [min(Blo)-max(drift)*dt-4*sqrt(dt)  max(Bup)+max(drift)*dt+4*sqrt(dt)]  
% p0:        vector or matrix of initial pdf (need not sum to 1)
%   p0(m):   probability of the evidence level at t = 0.
%   p0(m,drift,k): probability of the evidence level starting diffusion at t = 0.
% notabs_flag: flag as to whether (1) or not (0) to calculate the notabs pdf (can take a
%            lot of memory) - default is 0 if  not specified 
% diffusion: scalar or nd-vector. In the unit of sigma^2/t.
%
% Outputs
% ~~~~~~~~~~~~~~~
% Returns D, a structure - the first four have "lo" vesions too
% D.up.p(drift)       total probability of hitting the upper bound for each drift level
% D.up.mean_t(drift)  mean decision time for upper bound
% D.up.pdf_t(t,drift) probability of upper bound hit at each time (sums to D.up.p)
% D.up.cdf_t(t,drift) cumulative probability of upper bound hit at each time (ends at D.up.p)
%
% D.drifts            returns the drifts used
% D.bounds            returns the bounds used
% D.t                 returns the times used
%
% D.notabs.pdf(drifts,y,t) probability of not being absorbed and being at y at time t
% D.notabs.pos_t(drifts,t) probability of not being absorbed and being at y>0
% D.notabs.neg_t(drifts,t) probability of not being absorbed and being at y<0
% D.notabs.y the sets of y's considered for the pdf
%
% This is a beta version 1.0 from Daniel Wolpert.
% Vectorized by Luke Woloszyn.
% Antialiasing, reindexing, nonstationary drift, variance, p0 by Yul Kang.
% 2016-01 YK - Allowed different sigma per condition. 
% 2016-05 YK - Using regular convolution to preserve the density.

if nargin<7
    notabs_flag=0; % flag to detetrmine whether to store the notabs pdf
end

nt=length(t);
dt=t(2)-t(1); %sampling interval

% nd=length(drift);
% ny=length(y);

% Assign before changing
D.bounds=[Bup(:) Blo(:)];
D.drifts=drift;
D.y=y;

% Nonstationary drift - YK
if isvector(drift) && length(drift) ~= length(t)
    % Enforce column vector if stationary
    drift = drift(:); 
else
    % If nonstationary, size(drift) == [ncond, length(t)]
    assert(size(drift, 2) == length(t), ...
        'In nonstationary drift, the number of columns must match length(t)!');
end 
nd = size(drift, 1); % length(drift);
ny = length(y);

% Allow sigma to vary - YK
if isscalar(diffusion)
    diffusion = zeros(nd, 1) + diffusion;
else
    diffusion = diffusion(:);
    assert(length(diffusion) == nd);
end
assert(all(diffusion) > 0);

% % Unlike spectral, neither dt nor drift is scaled.
% dt = dt .* sigmaSq; % dt(drift,1)
% drift = bsxfun(@rdivide, drift, sigmaSq);

% Others
if round(log2(ny))~=log2(ny)
    error('Length of y must be a power of 2');
end

% if numel(p0)~=numel(y)
%     error('Length of y must be sames as p0');
% end

%expand any flat bounds
if numel(Bup)==1, Bup=Bup+zeros(nt,1);end % YK
if numel(Blo)==1, Blo=Blo+zeros(nt,1);end % YK

%preallocate
D.up.pdf_t=zeros(nt,nd);
D.lo.pdf_t=zeros(nt,nd);
if notabs_flag
    % Will be converted to (drift, t, y) at the end.
    D.notabs.pdf=zeros(nd,ny,nt);
end

%% Initial state
%initial state, repmated for batching over drifts (each column will correspond
%to different drift)
% U = repmat(p0, [1,nd]);

if isvector(p0), p0 = p0(:); end
if size(p0, 1) ~= ny
    error('Length of y must be sames as size(p0,1)');
end
if size(p0, 2) == 1
    repmat(p0(:,1), [1,nd,1]);
end
U = zeros(ny, nd); 

% %repmat this too
% Y = repmat(y,[1,nd]);

% TODO: run excluding conditions that has finished
%       => Use cdf of Td instead of U
% p_threshold=0.00001 * sum(sum(p0,1),3); %threshold for proportion un-terminated to stop simulation

%% Prepare antialiasing
[ixAliasUp, wtAliasUp] = bsxClosest(Bup, y);
[ixAliasDn, wtAliasDn] = bsxClosest(Blo, y);

dy        = y(2)-y(1);      % y should be uniformly spaced.
wtAliasUp = (wtAliasUp / dy) - 0.5; 
wtAliasDn = (wtAliasDn / dy) + 0.5;

%% Prepare kernel parameters
y_cdf = repmat([y(1) - 0.5 * dy; y + 0.5 * dy], [1, nd]);
mu = drift * dt;
sigma = sqrt(diffusion * dt);

if isscalar(sigma) || all(sigma(:) == sigma(1))
    sigmaSq_cdf = sigma(1);
else
    sigmaSq_cdf = repmat(sigma(:)', [(ny + 1), 1]);
end

DEBUG_MODE = {};
% DEBUG_MODE = {'sum'};
% DEBUG_MODE = {'sum', 'plot'};
if ~isempty(DEBUG_MODE)
    debug_cond = 5; % 18;
    debug_sum_bef = zeros(nd, nt);
    debug_sum_aft = zeros(nd, nt);
    debug_sum_aft_antialias = zeros(nd, nt);
end

%% iterate over time
for k=1:nt 
    
    if k == 1 || ...
            (k > 1 && size(drift,2) > 1 && any(drift(:,k) ~= drift(:,k-1)))
        
        kernel = diff(normcdf(y_cdf, ...
            repmat(mu(:,k)', [(ny+1), 1]), ...
            sigmaSq_cdf), 1, 1);
    end
    
    if size(p0, 3) > 1 % When p0 is specified for each time point,
        % Add p0 at each time point
        U = U + p0(:,:,k);
    elseif k == 1 % When p0 is specified only for the beginning,
        % Add p0 only at the beginning
        U = bsxfun(@plus, U, p0);
    end
    
    % DEBUG
    if ismember('sum', DEBUG_MODE)
        debug_sum_bef(:,k) = sum(U) + ...
            sum(D.up.pdf_t) + ...
            sum(D.lo.pdf_t);
    end
    if ismember('plot', DEBUG_MODE)
%         plot(y, p0(:,debug_cond,k), 'g-');
%         hold on;
        plot(y, U(:,debug_cond), 'k--');
        hold on;
    end
    
    %convolve per condition
    for dd = 1:nd
        U(:, dd) = conv(U(:, dd), kernel(:, dd), 'same');
    end
    
    % DEBUG
    if ismember('sum', DEBUG_MODE)
        debug_sum_aft(:,k) = sum(U) + ...
            sum(D.up.pdf_t) + ...
            sum(D.lo.pdf_t);
    end
    
    %select density that has crossed bounds
%     D.up.pdf_t(k,:)=sum(U.*(Y>=Bup(k)),1);
%     D.lo.pdf_t(k,:)=sum(U.*(Y<=Blo(k)),1);
%     D.up.pdf_t(k,:)=sum(U(y>=Bup(k),:),1); % YK
%     D.lo.pdf_t(k,:)=sum(U(y<=Blo(k),:),1); % YK    
try
    D.up.pdf_t(k,:)=sum(U(ixAliasUp(k):end,:),1); % sum(U(y>=Bup(k),:),1); % YK
    D.lo.pdf_t(k,:)=sum(U(1:ixAliasDn(k)  ,:),1); % y<=Blo(k),:),1); % YK
catch err_dtb
    warning(err_msg(err_dtb));
    keyboard; % DEBUG
end

%     % DEBUG
%     if sum(U(:)) > 0
%         keyboard;
%     end

    % On the boundary, antialias.
    upV = U(ixAliasUp(k),:);
    dnV = U(ixAliasDn(k),:);
    
    % Antialiasing continued
    D.up.pdf_t(k,:) = D.up.pdf_t(k,:) + upV * wtAliasUp(k);
    D.lo.pdf_t(k,:) = D.lo.pdf_t(k,:) - dnV * wtAliasDn(k);
    
    % YK - prevented losing density (can be ~2% of total!!)
    U([1:(ixAliasDn(k)-1), (ixAliasUp(k)+1):end], :) = 0; 
    if ixAliasDn(k) == ixAliasUp(k)
%         U(ixAliasUp(k),:) = 0;
        U(ixAliasUp(k),:) = upV ...
            - upV * (1 + wtAliasUp(k)) ...
            - dnV * (1 - wtAliasDn(k));
        if any(U(ixAliasUp(k),:)' < -1e-10)
            warning('U < 0!');
            keyboard;
        else
            U(ixAliasUp(k),:) = max(U(ixAliasUp(k),:), 0);
        end
    else
        U(ixAliasUp(k),:) = upV * -wtAliasUp(k);
        U(ixAliasDn(k),:) = dnV *  wtAliasDn(k);
    end
    
    % DEBUG
    if ismember('plot', DEBUG_MODE)
        plot(y, U(:,debug_cond), 'r--');
        crossLine('v', [Bup(k), Blo(k)]);
        legend({'p0', 'U-bef', 'U-aft'});
        hold off;
    end
    if ismember('sum', DEBUG_MODE)
        debug_sum_aft_antialias(:, k) = ...
            sum(U)' ...
            + sum(D.up.pdf_t)' ...
            + sum(D.lo.pdf_t)';
        
%         disp(k);
%         disp(sum(U(:)));
        sum_p0 = sums(p0(:,:,1:min(k,end)), [1, 3]);

        discrepancy = sum_p0 - debug_sum_aft_antialias(:, k)';
        [~, ix_max] = max(abs(discrepancy));
        disp([k, ix_max]);
        disp(discrepancy(ix_max));
        if any(abs(discrepancy) > 1e-5)
            fig_tag('debug_sum_U_bef_aft');    
            plot(D.up.pdf_t + D.lo.pdf_t);
            
            fig_tag('discrepancy');
            plot(sum_p0, 'ro-');
            hold on;
            plot(debug_sum_aft_antialias(:,k), 'bx--');
            hold off;
            keyboard;
        end
    end
    
%     if k == 10
%         keyboard;
%     end
%     
    % Save if requested
    if notabs_flag
        D.notabs.pdf(:,:,k)=U';
    end
    
%     %exit if our threshold is reached (because of the batching, 
%     %we have to wait until all densities have been absorbed) 
%     if sum(sum(U,1)<p_threshold)==nd 
%         break;
%     end
end

if ismember('sum', DEBUG_MODE)
    %%
    fig_tag('debug_sum_U_bef_aft');    
    plot(D.up.pdf_t + D.lo.pdf_t);
    
%     plot(debug_sum_aft_antialias);
%     plot(debug_sum_aft - debug_sum_bef, 'b-');
%     hold on;
%     plot(debug_sum_aft_antialias - debug_sum_bef, 'r--');
%     hold off;
    keyboard;
end

if notabs_flag
    D.notabs.pos_t=sum(D.notabs.pdf(:,y'>=0,:),2); % YK % ,sum(D.notabs.pdf.*repmat((Y>=0)',[1,1,nt]),2);
    D.notabs.neg_t=sum(D.notabs.pdf(:,y'< 0,:),2); % YK % .*repmat((Y<0)',[1,1,nt]),2);

%     % (drift, t, y) <- (drift, y, t)
%     D.notabs.pdf = permute(D.notabs.pdf, [1 3 2]); % Follow other functions' convention
end

D.up.p=sum(D.up.pdf_t,1);
D.lo.p=sum(D.lo.pdf_t,1);
    
t = t(:);
D.t = t;

D.up.mean_t=t'*D.up.pdf_t./D.up.p;
D.lo.mean_t=t'*D.lo.pdf_t./D.lo.p;

D.up.cdf_t=cumsum(D.up.pdf_t);
D.lo.cdf_t=cumsum(D.lo.pdf_t);

