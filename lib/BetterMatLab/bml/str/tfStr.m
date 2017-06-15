function res = tfStr(tf)
% TFSTR    converts a scalar logical into a string, 'true' or 'false'.

if tf
    res = 'true';
else
    res = 'false';
end