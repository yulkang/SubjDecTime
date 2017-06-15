function [filt, ds_filt] = refine_filt(ds, filt, varargin)
% [filt, ds_filt] = refine_filt(ds, filt, 'field1', value1, ...)
% 
% filt:
%   If empty, defaults to all.
%
% value:
%   Scalar or vector. 
%   If vector, rows that have any one of the values is included.

S_filt_add = varargin2S(varargin);

if isempty(filt), filt = true(length(ds, 1)); end

fields = fieldnames(S_filt_add)';
vals   = struct2cell(S_filt_add)';
n      = length(fields);

f_eq_field = @(field, val) arrayfun(@(v) isequal(v, val), ds.(field));

for ii = 1:n
    if isscalar(vals{ii})
        filt = filt & f_eq_field(fields{ii}, vals{ii});
    else
        filt_temp = false(size(filt));
        
        for jj = 1:length(vals{ii})
            filt_temp = filt_temp | f_eq_field(fields{ii}, vals{ii}(jj));
        end
        
        filt = filt & filt_temp;
    end
end

if nargout >= 2
    ds_filt = ds(filt,:);
end
end