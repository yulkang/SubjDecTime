function p = p_tail_convert(p0, sig, op)
% p = p_tail_convert(p0, sig, op)
%
% p0 : p-value before conversion.
% p  : converted p-values.
% sig: sign( statistic - median(statistic) )
%      Examples are sign( t_stat ), sign( z_score ), or sign( prctile - 50 ).
% op : 'BtoL', 'BtoR', 'LtoB', or 'RtoB'. 
%      B, L, R mean bilateral, left, and right, respectively.
%
% EXAMPLE:
% >> bml.stat.p_tail_convert([0.1 0.1 0.1], [-1, 0, 1], 'BtoL')
% ans =
%     0.0500    0.5000    0.9500
%
% 2016 Yul Kang. hk2699 at columbia dot edu.

sigL = sig < 0;
sigR = sig > 0;
sig0 = sig == 0;

p = nan(size(p0));

switch op
    case 'BtoL'                       
        p(sig0) = 0.5;
        p(sigL) = p0(sigL) / 2;
        p(sigR) = 1 - p0(sigR) / 2;
        
    case 'BtoR'               
        p(sig0) = 0.5;
        p(sigL) = 1 - p0(sigL) / 2;
        p(sigR) = p0(sigR) / 2;
        
    otherwise
        error('op=%s not implemented yet!', op);
        
%     case 'BtoR'
%     case 'LtoB'
%     case 'RtoB'
end