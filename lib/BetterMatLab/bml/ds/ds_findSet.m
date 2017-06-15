function [ds, filt, row] = ds_findSet(ds, findS, setS)
% [ds, filt, row] = ds_findSet(ds, findS, setS)
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

[~,filt] = ds_findGet(ds, findS);

if ~any(filt)
    filt = [filt; true];
    ds = ds_setS(ds, filt, findS);
end

ds = ds_setS(ds, filt, setS);

if nargout>=3, row = ds(filt,:); end