function [filt, ds_filt] = filt_n_row(ds, filt1, n_row, filt2)
% Among n_row trials meeting filt1, choose those meeting filt2.
%
% [filt, ds_filt] = filt_n_row(ds, filt1, n_row, filt2)
%
% filt1, filt2:
%   {'field1', val1, ...}
% 
% val: scalar or vector. If vector, rows that have any one of the values is included.

if ~exist('filt2', 'var'), filt2 = {}; end

filt = true(length(ds), 1);

% First filter
filt = dset.refine_filt(ds, filt, filt1{:});

% Filter with nTr from the last
ix_n_row = find(filt, n_row, 'last');
filt = filt & ix2tf(size(filt), ix_n_row);

% Second filter
filt = dset.refine_filt(ds, filt, filt2{:});

% Output
if nargout >= 2
    ds_filt = ds(filt, :);
end
end