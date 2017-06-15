function mdl = mdl_addTerms(mdl, terms)
% Applies addTerms using term names
%
% mdl = mdl_useTerms(mdl, terms_to_add)
%
% terms
% : a cell array of strings. A subset of mdl.VariableNames.

% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

terms0 = mdl.PredictorNames;

terms_to_add = setdiff(terms, terms0);
if ~isempty(terms_to_add)
    param_to_add = double( ...
        bsxStrcmp(terms_to_add(:), mdl.VariableNames(:)'));
    mdl = mdl.addTerms(param_to_add);
end
end