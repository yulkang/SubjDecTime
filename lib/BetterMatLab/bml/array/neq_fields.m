function S_diff = neq_fields(S, S_orig, fields, varargin)
% Copy fields of S that are absent in S_orig or changed.
%
% S_diff = neq_fields(S, S_orig, fields_to_include_always={})

opt = varargin2S(varargin, {
    'print', false
    });

if nargin < 3, fields = {}; end

S_diff = struct;

for f = fieldnames(S)'
    if ~isfield(S_orig, f{1}) || ...
            ~isequal_nan(S.(f{1}), S_orig.(f{1}))
        
        S_diff.(f{1}) = S.(f{1});
    end
end

% Fields that are always copied
if ~isempty(fields)
    for f = fields(:)'
        S_diff.(f{1}) = S.(f{1});
    end
end

% Print results
if opt.print
    fprintf('%s\n', fieldnames(S_diff));
end