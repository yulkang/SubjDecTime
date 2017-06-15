function D =  analytic_dtb(drift,t,Bup,Blo,y0,ny)
% D =  analytic_dtb(drift,t,Bup,Blo,y0,ny)
% Implementation of Cox & Miller (PDF of non-absorbed) and Ratcliff
% (probability absorbed and first passage time) analytic solutions to bounded
% drift diffusion (drift to bound). The solutions here handle flat but
% asymmetric bounds with delta function initiation anywhere between bounds.
%
% Input arguments
% ~~~~~~~~~~~~~~~
% drift         vector of drift rates
% t             time series or set of times in seconds (t(1) needs to be zero)
% Bup & Blo     are scalar bounds with   Blo < Bup
% y0            value of DV at t=0 (scalar) requires  Blo < y0 < Bup
% ny (optional) specifies the granularity (number of points) of  DV from [Blo,Bup]
%               and asks the function to return the unabsorbed probability distribution 
%               all times (will slow down simulation).
%
% Outputs
% ~~~~~~~~~~~~~~~
% Returns D, a structure (the first four have "lo" vesions too)
% D.up.p(drift)        probability of hitting the upper bound for each drift
% D.up.mean_t(drift)   mean decision time for upper bound for each drift level
% D.up.pdf_t(t,drift)  probability of upper bound hit at each time (sums to D.up)
% D.up.cdf_t(t,drift)  cumulative probability of upper bound hit at each time (ends at D.up)
%
% D.drifts             drifts tested
% D.bounds             bounds
% D.t                  times used for simulation
%
% if ny is passed then th:e function also returns:
% D.notabs.pdf(drifts,y,t) probability of being at y at time t
% D.notabs.pos_t(drifts,t) probability of not being absorbed and being >0
% D.notabs.neg_t(drifts,t) probability of not being absorbed and being <0
% D.notabs.y               the sets of y's considered for the pdf
%
% This is a beta version from Daniel Wolpert.
%
% History 10/2011 Daniel Wolpert wrote it
%         26/10/2011 mns added comments
%         08/02/2014 Yul Kang added normalization of pdf_t for very high drift.
%version 1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for Ratcliff formulation lower bound needs to be at 0, so set upper at B and adjust y0
B=Bup-Blo;
y0=y0-Blo;
t = t(:);

%to calculate lower crossings information [Ratcliff actually calculates lower]
if nargin < 6
    ny = [];
end

[D.lo, D.notabs]=run_analytic(t,+drift,y0,B,ny);

%to calculate upper crossings (flip drift and adjust starting point)
D.up=run_analytic(t,-drift,B-y0,B,ny);

drift = drift(:)'; % Enforce a row vector.
D.drifts=drift;
D.t=t;
D.bounds=[Blo Bup];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [D, E] = run_analytic(t,drift,y0,B,ny)

% this uses A8 and A12 equation for Ratcliff psych review 1978

ndrift=length(drift);
nt=length(t);

% test if the user puts in a time series or an arbitrary set of times
if nt>1 && var(diff(t))<100*eps
    series_flag=1;
else
    series_flag=0;
end

%G is survivor function for zero bound
% G=zeros(ndrift,nt);
G_cell = repmat({zeros(1,nt)}, [ndrift, 1]); % YK

%analytic expression for probability of crossing upper bound from Ratcliff A8
P=(exp(-2*drift*B)-exp(-2*drift*y0))./(exp(-2*drift*B)-1);

P(abs(drift)<100*eps)=y0/B; %fix for zero drift condition.

%this sums over 1->Inf but we go 1:K(end), this seems to sum far enough for standard parameters
K=1:150;

% p_threshold=1e-8; %threshold for proportion un-terminated - used for series only

% this next part uses A12 equation from Ratcliff psych review 1978

K_sin = 2 * K .* sin(K*pi*y0/B);
pi_K  = pi^2*K.^2/B^2;

t = t(:);

for j=1:ndrift
    d=(pi/B^2)*exp(-y0*drift(j));
    den=(drift(j)^2 + pi_K);

    num = bsxfun(@times, K_sin, exp(bsxfun(@times, -0.5 * (drift(j)^2 + pi_K), t)));
    
    ss  = sum( bsxfun(@rdivide, num, den), 2);
    
    G_cell{j} = P(j) - d * ss';    
end
G = cell2mat(G_cell); % YK

%series does not converge properly for t=0 but we know that nothing has crossed
%bound so set to 0 for all drifts if t==0
G(:,1)= G(:,2);


if series_flag
    %transform cumulative into pdf of stopping times and pad beginning with zeros
    dtdist = max([zeros(ndrift,1) diff(G')' ], 0)'; % this assumes t(0)=0;
    
    %average termination times (subtract half sampling interval as we used diff)
    dts=t'*dtdist;
    dts=dts./P-(t(2)-t(1))/2;
else
    dts=[];
    dtdist=[];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%from cox and miller eqn 78 page 222 to get full pdf of DV between bounds

if ~isempty(ny) % YK - this form is more flexible % exist('ny', 'var') %only calculate if we received ny
    a=B-y0;
    b=y0;
    y=linspace(-b,a,ny)';
    [Y,T]=meshgrid(y,t+eps); % speed up by using matrices for evaluations
    a1=1./(sqrt(2*pi*T));

    %the series_flag sums over -Inf->Inf but we go -nk->nk and this seems far enough for standard parameters
    nk=10;
    
    for j=1:ndrift
        pdf=zeros(nt,ny);
        
        for i=-nk:nk
            yn=2*i*(a+b);
            ynn=2*a-yn;
            
            a2=exp(drift(j)* yn - (Y- yn-drift(j)*T).^2./(2*T));
            a3=exp(drift(j)*ynn - (Y-ynn-drift(j)*T).^2./(2*T));
            
            pdf= pdf+a1.*(a2-a3);
        end
        
        pdf=pdf*(y(2)-y(1));
        
        if t(1)==0
            pdf(1,:)=0;
            pdf(1,round(ny/2))=1;
        end
        E.pdf(j,:,:)=pdf;
        E.pos_t(:,j)=sum(pdf(:,y>=0),2);
        E.neg_t(:,j)=sum(pdf(:,y<0),2);
    end
    E.y=y;
else
    E.pdf=[];
    E.y=[];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
D.p=P;
D.cdf_t=G';
D.mean_t=dts;

D.pdf_t = dtdist;

% Normalization of pdf_t - YK
% Normalizes pdf_t only when the drift is too high (probability is underestimated),
% to avoid abnormal behavior in fitting.
% Leaves pdf_t untouched when it is too low (density is not absorbed until max(t)).
% Normalization of cdf_t is not implemented yet.
needs_norm = (sum(dtdist, 1) > P) | ...
    (sum(dtdist(ceil(end/2):end,:), 1) < P / 1e5);

if any(needs_norm)
    dtdist_to_norm = dtdist(:,needs_norm);
    D.pdf_t(:,needs_norm) = bsxfun(@times, bsxfun(@rdivide, ...
        dtdist_to_norm, sum(dtdist_to_norm, 1)), P(needs_norm));
end

% if any(D.pdf_t(:) < 0) || any(D.pdf_t(:) > 0.01) % DEBUG
%     keyboard;
% end
end