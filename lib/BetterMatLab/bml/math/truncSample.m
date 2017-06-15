function v = truncSample(f, minV, maxV)
% TRUNCSAMPLE   Sample until the value is between MINV and MAXV.
%
% v = truncSample(f, minV, maxV)
%
% f     : Function that returns a random number every time.
%         Make sure it has nonzero probability of returning
%         a value between MINV and MAXV. Otherwise it will run forever!

v = nan;

while ~(minV <= v) || ~(v <= maxV)
    v = f();
end