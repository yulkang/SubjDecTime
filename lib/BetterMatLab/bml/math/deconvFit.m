function c = deconvFit(op,a,b,varargin)
% c = deconvFit(op,a,b,varargin)

S = varargin2S(varargin, {
    'fun', @(t, x) gampdf(t, x(1), x(2))
    't',   []
    'x0',  []
    });

switch op
    case 'fit'
    case 'pred'
    case 'cost'
end