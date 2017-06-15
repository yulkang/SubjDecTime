function D = no_drift_no_diffusion(nd, t, Bup, Blo, y, p0, notabs_flag)
% D = no_drift_no_diffusion(nd, t, b_up, b_lo, y, p0, notabs_flag)
%
% INPUT
% -----
% nd : a scalar number of conditions.
% t(k) : time in seconds at k-th time step.
% b_up(k) : upper bound.
% b_lo(k) : lower bound.
% y(m) : evidence level at m-th bin.
% p0 : either vector or array.
%   p0(m) : probability of the evidence level at t = 0.
%   p0(m,drift,k) : probability of the evidence level starting diffusion at t = 0.
% notabs_flag : if true, unabsorbed density is calculated.
%
% OUTPUT (copied from spectral_dtb)
% ------
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
% 2016 YK wrote the initial version.

if ~exist('notabs_flag', 'var'), notabs_flag = false; end

nt = length(t);

% Assign before changing
D.bounds=[Bup(:) Blo(:)];
D.y=y;
ny = length(y);

% Expand any flat bounds
% if numel(Bup)==1
%     Bup = Bup + zeros(nt,1);
% else
%     assert(all(vVec(diff(Bup, 1, 1)) == 0), ...
%         'changing bound is not implemented yet!');
% end
% if numel(Blo)==1
%     Blo = Blo + zeros(nt,1);
% else
%     assert(all(vVec(diff(Bup, 1, 1)) == 0), ...
%         'changing bound is not implemented yet!');
% end

% Preallocate pdf_t
D.up.pdf_t=zeros(nt,nd);
D.lo.pdf_t=zeros(nt,nd);
if notabs_flag
    % Will be converted to (drift, t, y) at the end.
    D.notabs.pdf=zeros(nd,ny,nt);
end

% Expand p0 if necessary
if isvector(p0)
    p0 = p0(:); 
end
if size(p0, 1) ~= ny
    error('Length of y must be sames as size(p0,1)');
end
if size(p0, 2) == 1
    p0 = repmat(p0(:,1), [1, nd, 1]);
end
if (size(p0, 3) == 1) && (nt > 1)
    p0(end, end, nt) = 0; % Fill in the rest with 0.
else
    assert(size(p0, 3) == nt);
end

%% iterate over time
% td_pdf - not implemented until supporting changing bound.
    
% notabs if eneded
if notabs_flag
    D.notabs.pdf = cumsum(permute(p0, [2 1 3]), 3);
end

%% Outputs
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

end