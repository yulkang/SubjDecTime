function [theta,theta_lo,theta_hi, S,theta_unconstr]= opt_pack(O,noise)
% [theta,theta_lo,theta_hi,S,theta_unconstr]= opt_pack(T,noise)
%
% packs up parametees for optimization
% T{1} contains a structure of parameters to be optimized and their initial
% values, parameters can be scalars or arrayas. NaN values in arrays means the value is tied to
% the first element of the array (for arrays either no elemensts after the
% first are tied or all need to be - should change this later)
% T{2} and T{3} contain the lower and upper bounds for the parameters - if
% they are the same then the parameter is fixed to its value in T{1} and not optimized.
% NaN takes precidence over the same bounds
%
% noise (optional) allows perturtbation to the starting point -
%   noise= Inf  leads to uniform sampling in lowee upper range
%  noise = p  multiplies each pamateter by  a factor [1-p,1+p] uniformly
%  sampled and clipped to lower and upper bound
%
% Example:
% clear T
% T{1}.kappa=10.9;      T{2}.kappa=0.1;       T{3}.kappa=Inf;
% T{1}.B=[0.65 1];      T{2}.B=[0 0];         T{3}.B=[Inf Inf];
% T{1}.mu=0.0;          T{2}.mu=0;            T{3}.B=0;   %fixed
% T{1}.tnd=[0.2 NaN];   T{2}.tnd=[0 0];       T{3}.tnd=[1 1];   %ties
%
% [theta,theta_lo,theta_hi,S]=opt_pack(T);
% theta_opt = fminsearchbnd(@(theta) opt_func(theta,S),theta,theta_lo,theta_hi,[]);
% in opt_func extract the parameters with T=opt_unpack(theta,S);
%


for k=1:3
    fp{k}=fieldnames(O{k}); %extract names
    P{k}=struct2cell(O{k}); %extract parameters
    [fp{k} i]=sort(fp{k}); %sort names
    P{k}=P{k}(i); %sort parameters
end

n=length(fp{1}); % number of different parameter names

%%% error checking
if  ~isempty(setdiff(fp{1},fp{2}))|~isempty(setdiff(fp{1},fp{3}))
    error('Names in structures do not match')
end
for k=1:n
    if ~ isequal(size(P{1}{k}),size(P{2}{k})) |~isequal(size(P{1}{k}),size(P{3}{k}))
        error('Parameter sizes do not match')
    end
end


%rename structures for ease
Pc=P{1};
Plo=P{2};
Phi=P{3};

%create theta vector to optimize and bounds
theta=[];
theta_lo=[];
theta_hi=[];
S.gtheta=[];
count=0;
for k=1:n
    w=Pc{k}; % extract parameter
    tn(k)=numel(w); %number of element in parameter
    for j=1:length(w)
        S.fixed(k,j)=0;
        S.tied(k,j)=0;
        
        if isnan(w(j)) %this means it is tied to the first parameter
            if j==1
                error('first element of a vector cannot be tied')
            end
            if Plo{k}(j)==round(Plo{k}(j)) & ~isinf(Plo{k}(j)) & Plo{k}(j)>0
                S.tied(k,j)=Plo{k}(j);
            else
                S.tied(k,j)=1;
            end
            S.gtheta=[S.gtheta count];
            
        elseif Plo{k}(j)==Phi{k}(j)  %bounds the same means fixed
            S.fixed(k,j)=1;
                      
        else   %otherwise a real new parameter
            if nargin==1
                theta=[theta w(j)];
                count=count+1;
                S.gtheta=[S.gtheta count];
            else
                if isinf(noise)
                    theta=[theta  Plo{k}(j)+ rand*(Phi{k}(j)- Plo{k}(j))];
                else
                    r=w(j)* (1-noise+2*noise*rand);
                    r=clip(r,Plo{k}(j),Phi{k}(j));
                    theta=[theta r];
                end
            end
            theta_lo=[theta_lo Plo{k}(j)];
            theta_hi=[theta_hi Phi{k}(j)];
            S.theta_names{length(theta)}=fp{1}{k};
            
        end
    end
end

S.names=fp{1};
S.O=O;
S.n=tn;

%%
for k=1:length(theta)
    if isinf(theta_lo(k)) & isinf(theta_hi(k))
        theta_unconstr(k) = theta(k);
    elseif isinf(theta_hi(k))  % lower bound only
        theta_unconstr(k) =  sqrt(theta(k)-theta_lo(k));
    elseif isinf(theta_lo(k))  % upper bound only
        theta_unconstr(k) = sqrt(theta_hi(k)- theta(k));
    else %two bounds
        theta_unconstr(k) = asin(-1+2*(theta(k)-theta_lo(k))/(theta_hi(k) - theta_lo(k)));

    end
end

S.theta_lo=theta_lo;
S.theta_hi=theta_hi;
S.theta=theta;
%S.theta_u=theta_unconstr;



