% From Daniel, 2016-08.

syms B kappa mu tnd coh ci tnd_sigma rt zz real

%params to optimize (alphabetic order makes life easy)
params=[B kappa mu tnd];

%data we will need to pass - zz is a vector of zeros
data=[coh ci rt tnd_sigma  zz];

fname='dtb_grad'; % filename of output function created

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%should not need to edit below this line%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drift=kappa*(coh+mu);

for j=1:2
    if j==1  % non-zero drift
        pred_rt = (( -B.*coth(B.*drift) + 2*B.*coth(2*B.*drift) ) ./ drift) +tnd;
        pred_p = (exp(2*drift.*B)-1) ./ (exp(2*drift.*B)  - exp(-2*drift.*B));
    else % special case of small drift from small_drift.m
        pred_rt=(B^2*(48*B*drift + 9))/(27*B*drift + 9) + tnd
        pred_p = B*drift + 1/2;
    end
    
    %negatuve log likelihoods for rt and proportion rightward
    like_rt = 0.5 * ((rt - pred_rt)./tnd_sigma).^2 + log(sqrt(2*pi) .* tnd_sigma);
    like_p =  - ci*log(pred_p) -(1-ci)*log(1-pred_p);
    
    %jacobians and hessians
    Jrt=jacobian(like_rt,params);
    Jp=jacobian(like_p,params);
    Hrt=hessian(like_rt,params);
    Hp=hessian(like_p,params);
    
    dtb_rt_grad{j}=[like_rt pred_p pred_rt Jrt Hrt(:)'];
    dtb_p_grad{j} =[like_p  pred_p pred_rt Jp  Hp(:)'];
    
    %make sures any zeros are vectorized
    for k=1:numel(dtb_rt_grad{j})
        if isequaln(dtb_rt_grad{j}(k),sym(0)), dtb_rt_grad{j}(k)=zz;, end
        if isequaln(dtb_p_grad{j}(k),sym(0)),  dtb_p_grad{j}(k)=zz;, end
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

matlabFunction(dtb_rt_grad{1},dtb_rt_grad{2}...
    ,dtb_p_grad{1},dtb_p_grad{2},...
    'vars',[params data],'file',fname)
