function [col mat matX matY] = gratingPix(xVec, yVec, xFun, yFun, rFun, col1, col2)
    % [col mat matX matY] = gratingPix(xVec, yVec, xFun, yFun, rFun, col1, col2)
    
    [matX matY] = meshgrid(xVec, yVec);
    mat = xFun(matX) .* yFun(matY);

    col = bsxfun(@times, reshape(col2, 1, 1, []), mat) ...
        + bsxfun(@times, reshape(col1, 1, 1, []), 1-mat);
    
    col(:,:,4) = rFun(sqrt(matX.^2 + matY.^2)) * 255;
end