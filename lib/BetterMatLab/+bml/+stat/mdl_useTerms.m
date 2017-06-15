function mdl = mdl_useTerms(mdl, terms)
% Applies addTerms and removeTerms to make mdl to use the specified terms.
%
% mdl = mdl_useTerms(mdl, terms)
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

terms_to_remove = setdiff(terms0, terms);
if ~isempty(terms_to_remove)
    param_to_remove = double( ...
        bsxStrcmp(terms_to_remove(:), mdl.VariableNames(:)'));
    mdl = mdl.removeTerms(param_to_remove);
end
end