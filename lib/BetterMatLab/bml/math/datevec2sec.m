function dst = datevec2sec(src)
% dst = datevec2sec(src)

if any(any(src(:,1:2)))
    error('Cannot convert time longer than a day!');
end

dst = src(:,6) ...
    + src(:,5) * 60 ...
    + src(:,4) * 60^2 ...
    + src(:,3) * 24 * 60^2;