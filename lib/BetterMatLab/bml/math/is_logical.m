function tf = is_logical(v)
% is_logical  true iff v consists nothing but true, false, 1, or 0.

tf = all( (v==0) | (v==1) );