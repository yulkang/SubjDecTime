function res = glm_mdl2res(mdl)
% Convert a GeneralizedLinearModel object to glmwrap struct format.
%
% res.mdl gives the original mdl.

res.b = mdl.Coefficients.Estimate;
res.se = mdl.Coefficients.SE;
res.p = mdl.Coefficients.pValue;
res.dev = mdl.Deviance;

res.mdl = mdl;
res.stats = struct;
