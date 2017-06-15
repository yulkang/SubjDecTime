function v = intersectVec(a, b)
% v = intersectVec(a, b)
%
% a, b: row vector of small itegers.

len    = max(length(a), length(b));

tfA    = false(1, len);
tfB    = tfA;

tfA(a) = true;
tfB(b) = true;

v = find(tfA & tfB);
end