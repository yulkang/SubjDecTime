function ds = ds_filt(ds, filt, fields)
% Gives ds(filt, fields) or ds(filt(ds), fields)
%
% ds = ds_filt(ds, filt, fields=':')

if nargin < 2, filt = ':'; end
if nargin < 3, fields = ':'; end

if isa(filt, 'function_handle')
    filt = filt(ds);
end

ds = ds(filt, fields);