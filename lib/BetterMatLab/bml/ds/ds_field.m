function res = ds_field(ds, field, filt)
% Gives ds.(field)(filt)
%
% res = ds_field(ds, field, filt)

if nargin < 3, filt = ':'; end
if isa(filt, 'function_handle')
    filt = filt(ds);
end

res = ds.(field)(filt);