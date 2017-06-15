function xy = xy4lines(x_st, y_st, x_en, y_en)
% xy = xy4lines(x_st, y_st, x_en, y_en)
%
% Gathers and reshapes coordinates for DrawLines.
xy = reshape([x_st(:)'; y_st(:)'; x_en(:)'; y_en(:)'], 2, []);
end