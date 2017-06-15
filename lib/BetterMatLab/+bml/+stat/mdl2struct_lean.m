function S = mdl2struct_lean(mdl)
% S = mdl2struct_lean(mdl)

S = copyFields(struct, mdl, {
    'Coefficients'
    'CoefficientCovariance'
    'ModelCriterion'
    'Deviance'
    });
S.Coefficients = table2array(S.Coefficients);

% S = copyFields(struct, mdl, {
%     'Variables'
%     'Offset'
%     'Residuals'
%     'Fitted'
%     'Diagnostics'
%     'ObservationInfo'
%     }, false, true);