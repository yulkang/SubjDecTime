function [m se n t] = meanTS(ts, dT)
stT = inf; enT = -inf;

for ii = 1:length(ts)
    if ~isempty(ts(ii).Time)
        if ts(ii).Time(1) < stT
            stT = ts(ii).Time(1);
        end
        if ts(ii).Time(end) > enT
            enT = ts(ii).Time(end);
        end
    end
end
t = vVec(stT:dT:(enT+0.0001));

L = length(t);

s  = zeros(L, size(ts(5).Data, 2));
s2 = zeros(L, size(ts(5).Data, 2));
n  = zeros(L, 1);

for ii = 1:length(ts)
    if ~isempty(ts(ii).Time)
        stIx = find(abs(t-ts(ii).Time(1)) < 0.001);
        enIx = find(abs(t-ts(ii).Time(end)) < 0.001);

        n(stIx:enIx)    = n(stIx:enIx) + 1;
        s(stIx:enIx,:)  = s(stIx:enIx,:)  + ts(ii).Data;
        s2(stIx:enIx,:) = s2(stIx:enIx,:) + ts(ii).Data.^2;
    end
end

n2 = repmat(n, [1 2]);

m  = s./n2;
v  = s2./(n2-1) - (s./n2).^2 .* n2./(n2-1);
se = sqrt(v) ./ sqrt(n2);
end