function [n, t, d] = PL_GetADEx(s)
% PL_GetADEx - get A/D data
%
% [n, t, d] = PL_GetADEx(s)
%
% Input:
%   s - server reference (see PL_Init)
%
% Output:
%   n - m by 1 matrix, where m is the total number of active A/D channels,
%		number of data points retrieved (for each channel),
%   t - 1 by 1 matrix, timestamp of the first data point (in seconds)
%   d - n by nch matrix, where nch is the number of active A/D channels,
%       A/D data
%       d(:, 1) - a/d values for the first active channel 
%       d(:, 2) - a/d values for the second active channel
%       etc.
%
% NOTE1: Reading data from up to 256 A/D ("slow") channels is supported; however, 
% please make sure that you are using the latest version of Rasputin (which includes
% support for acquisition from multiple NIDAQ cards in parallel).
%
% NOTE2: If you are using multiple A/D cards running at different sampling rates 
% (e.g. 1 kHz and 40 kHz), the values in the n matrix will be different for "fast" 
% and "slow" channels.
%
% Copyright (c) 2007, Plexon Inc
%
[n, t, d] = mexPlexOnline(20, s);
