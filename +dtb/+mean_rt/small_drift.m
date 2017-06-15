% From Daniel, 2016-08

clear all

% calculate small drift analytic solutions for decision time and proportion
% of rigwtard choice
syms B drift x y

exp_approx=1 + y + y^2/2 + y^3/6; %exponential approximation
coth_func=(subs(exp_approx,2*x)+1)/(subs(exp_approx,2*x)-1); %coth definition

% decision time from analytic
% dec_t= (( -B.*coth(B.*drift) + 2*B.*coth(2*B.*drift) ) / drift);
dec_t = ( -B*subs(coth_func,B*drift) + 2*B*subs(coth_func,2*B*drift)) / drift;
dec_t=simplify(dec_t);

% probability of rightward choice
% p = (exp(2*drift.*B)-1) / (exp(2*drift.*B)  - exp(-2*drift.*B));
pright = (subs(exp_approx,2*x)-1) / (subs(exp_approx,2*x)-subs(exp_approx,-2*x));
pright = subs(pright,2*B*drift); %replace x
pright = simplify(pright);

for k=2:4 %remove all terms higher than 1st order in drift
    dec_t=simplify(subs(dec_t,drift^k,0));
    pright=simplify(subs(pright,drift^k,0));
end

%subs(dec_t,drift,0)

dec_t
pright
