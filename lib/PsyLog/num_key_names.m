function names = num_key_names(ix)
% names = num_key_names(ix)
%
% ix: 0-9. Can be a vector. Omit to give 0:9.
%
% See also: getPsyKbNames, PsyKey

names_all = {'N0RParen', 'N1Exclam', 'N2At', 'N3Sharp', 'N4Dollar', 'N5Percent', 'N6Hat', 'N7And', 'N8Times', 'N9LParen'};

if ~exist('ix', 'var'), ix = 0:(length(names_all) - 1); end

names = names_all(ix+1);