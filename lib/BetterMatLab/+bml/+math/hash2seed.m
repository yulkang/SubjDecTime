function [seed, hash] = hash2seed(v, varargin)
S = varargin2S(varargin, {
    'hash_opt', {'Method', 'SHA-256'}
    });
hash_opt = varargin2S(S.hash_opt);
hash = DataHash(v, hash_opt);

hash_32bit = hash(end + (-7:0));
seed = hex2dec(hash_32bit);
end