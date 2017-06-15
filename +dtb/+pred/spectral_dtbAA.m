function D =  spectral_dtbAA(drift,t,Bup,Blo,y,y0,notabs_flag)
% D =  spectral_dtbAA(drift,t,Bup,Blo,y,y0)
%
% Antialiased version of spectral_dtb, which gives
% spectral solutions to bounded drift diffusion (drift to bound).
% This can handle arbitrary changing bounds.
%
% Evidence space is antialiased, removing the 'spiking' phenomenon.
%
% Inputs (all in SI units)
% ~~~~~~~~~~~~~~~
% drift:     vector of drift rates
% t:         time series in seconds
% Bup & Blo: vector bounds with  Blo(t) < Bup(t)
%            or can be scalars if bounds are flat,
%            +/-Inf bounds are allowed
% y:         vector of values of y to propagate: length must be a power of 2
%            sensible range to choose is (with dt=sampling interval)
%            [min(Blo)-max(drift)*dt-4*sqrt(dt)  max(Bup)+max(drift)*dt+4*sqrt(dt)]  
% y0:        vector of initial pdf (need not sum to 1)
% notabs_flag: flag as to whether (1) or not (0) to calculate the notabs pdf (can take a
%            lot of memory) - default is 0 if  not specified 
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
%
% Vectorized by Luke Woloszyn.
% Antialiased and reindexed by Yul Kang.

if nargin<7
    notabs_flag=0; % flag to detetrmine whether to store the notabs pdf
end

nt=length(t);
dt=t(2)-t(1); %sampling interval
nd=length(drift);
ny=length(y);

if round(log2(ny))~=log2(ny)
    error('Length of y must be a power of 2');
end

if numel(y0)~=numel(y)
    error('Length of y must be sames as y0');
end

D.bounds=[Bup(:) Blo(:)];

drift = drift(:)'; % YK - enforce a row vector.
D.drifts=drift;
D.y=y;

%expand any flat bounds
if numel(Bup)==1, Bup=Bup+zeros(nt,1);end % YK
if numel(Blo)==1, Blo=Blo+zeros(nt,1);end % YK

%create fft of unit variance zero mean Gaussian, repmat it so we can batch
%over drifts (each column will correspond to different drift)
kk=repmat([0:ny/2 -ny/2+1:-1]',[1,nd]);
omega=2*pi*kk/range(y);
E1=exp(-0.5*dt*omega.^2); %fft of the normal distribution - scaled suitably by dt

%preallocate
D.up.pdf_t=zeros(nt,nd);
D.lo.pdf_t=zeros(nt,nd);
if notabs_flag
    D.notabs.pdf=zeros(nd,ny,nt);
end

%initial state, repmated for batching over drifts (each column will correspond
%to different drift)
U = repmat(y0, [1,nd]);

%this is the set of shifted gaussians in the frequency domain,
%with one gaussian per drift (each column)
E2=E1.*exp(-1i.*omega.*repmat(drift(:)',[ny,1])*dt);

% %repmat this too
% Y = repmat(y,[1,nd]);

p_threshold=0.00001; %threshold for proportion un-terminated to stop simulation

% Prepare antialiasing
[ixAliasUp, wtAliasUp] = bsxClosest(Bup, y);
[ixAliasDn, wtAliasDn] = bsxClosest(Blo, y);

dy        = y(2)-y(1);      % y should be uniformly spaced.
wtAliasUp = (wtAliasUp / dy) - 0.5; 
wtAliasDn = (wtAliasDn / dy) + 0.5;

for k=1:nt %iterate over time
    
    %fft current pdf
    Ufft=fft(U);
    
    %convolve with gaussian via pointwise multiplication in frequency
    %domain
    Ufft=E2.*Ufft;
    
    %back into time domain
    U = max(real(ifft(Ufft)),0);
    
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
%     keyboard; % DEBUG
end

    % On the boundary, antialias.
    upV = U(ixAliasUp(k),:);
    dnV = U(ixAliasDn(k),:);
    
    %keep only density within bounds
%     U = U.*(Y>Blo(k) & Y<Bup(k));
    U(y<=Blo(k) | y>=Bup(k),:) = 0; % YK
    
    % Antialiasing continued
    D.up.pdf_t(k,:) = D.up.pdf_t(k,:) + upV * wtAliasUp(k);
    D.lo.pdf_t(k,:) = D.lo.pdf_t(k,:) - dnV * wtAliasDn(k);
    
    U(ixAliasUp(k),:) = upV * -wtAliasUp(k);
    U(ixAliasDn(k),:) = dnV *  wtAliasDn(k);
    
    % Save if requested
    if notabs_flag
        D.notabs.pdf(:,:,k)=U';
    end
    
    %exit if our threshold is reached (because of the batching, 
    %we have to wait until all densities have been absorbed) 
    if sum(sum(U,1)<p_threshold)==nd 
        break
    end
end

if notabs_flag
    D.notabs.pos_t=sum(D.notabs.pdf(:,y'>=0,:),2); % YK % ,sum(D.notabs.pdf.*repmat((Y>=0)',[1,1,nt]),2);
    D.notabs.neg_t=sum(D.notabs.pdf(:,y'< 0,:),2); % YK % .*repmat((Y<0)',[1,1,nt]),2);
end

D.up.p=sum(D.up.pdf_t,1);
D.lo.p=sum(D.lo.pdf_t,1);
    
t = t(:);
D.t = t;

D.up.mean_t=t'*D.up.pdf_t./D.up.p;
D.lo.mean_t=t'*D.lo.pdf_t./D.lo.p;

D.up.cdf_t=cumsum(D.up.pdf_t);
D.lo.cdf_t=cumsum(D.lo.pdf_t);

