function v = betaTransform(v, betaParam)
% v = betaTransform(v, betaParam)

% n = size(v,1);
m = size(v,2);

betaParam = rep2fit(betaParam, [2, m]);

for ii = 1:m
    cv = v(:,ii);
    minV = min(cv);
    maxV = max(cv);
    
    if minV ~= maxV
        v(:,ii) = betacdf((cv - minV) / (maxV - minV), ...
            betaParam(1,ii), betaParam(2,ii)) ...
            * (maxV - minV) + minV;
        v(:,ii) = min(max(v(:,ii), minV), maxV);
    end
end