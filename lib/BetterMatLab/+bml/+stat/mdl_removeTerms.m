function mdl = mdl_removeTerms(mdl, terms_to_remove)
% Applies addTerms and removeTerms to make mdl to use the specified terms.
%
% mdl = mdl_removeTerms(mdl, terms_to_remove)
%
% terms
% : a cell array of strings. A subset of mdl.VariableNames.

% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

if ~isempty(terms_to_remove)
    param_to_remove = double( ...
        bsxStrcmp(terms_to_remove(:), mdl.VariableNames(:)'));
    mdl = mdl.removeTerms(param_to_remove);
end
end