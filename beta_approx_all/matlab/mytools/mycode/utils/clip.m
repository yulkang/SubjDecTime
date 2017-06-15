 function  x = clip( x, lo, hi )
 %y = clip(x, lo, hi )
 %clip values in x (scalar, vector or matrix) to be between lo and hi
 %(either scalars or same size as x)
 x(x>hi)=hi;
 x(x<lo)=lo;
