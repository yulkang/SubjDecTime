function ds2 = randsamp_strat(ds, cols, varargin)
% ds2 = resamp_strat(ds, cols, ...)
%
% cols : Cell array of the names of the columns to keep the same.
% ds2  : Dataset of the same size as ds, with columns other than 
%        COLS resampled with replacement.
%
% OPTIONS
% -------
% 'seed',          'Shuffle'
% 'w_replacement', true

S = varargin2S(varargin, {
    'seed',          'Shuffle'
    'w_replacement', true
    });

rng(S.seed);

[c, ~, ic] = unique(ds(:,cols));
nc = length(c);

ds2 = ds;

for ii = 1:nc
    filt  = find(ic == ii);
    nfilt = length(filt);
    
    filt_resamp = randsample(filt, nfilt, S.w_replacement);
    
    ds2(filt,:) = ds(filt_resamp, :);
end