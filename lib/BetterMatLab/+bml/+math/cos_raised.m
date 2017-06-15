function v = cos_raised(rad)
% v = cos_raised(rad)

v = (cos(min(max(rad, -pi), pi)) + 1) / 2;