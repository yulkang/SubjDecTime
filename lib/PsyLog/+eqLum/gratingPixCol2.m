function [col mat1 mat2 matX matY] = gratingPixCol2(xVec, yVec, xFun1, xFun2, yFun, rFun, col1, col2, colBkg, maxAlpha)
    % [col mat1 mat2 matX matY] = gratingPixCol2(xVec, yVec, xFun1, xFun2, yFun, rFun, col1, col2, colBkg, maxAlpha)
    % 
    % Separate functions for col1 and col2.
    
    if ~exist('maxAlpha', 'var'), maxAlpha = 255; end
    
    [matX matY] = meshgrid(xVec, yVec);
    mat1 = xFun1(matX) .* yFun(matY);
    mat2 = xFun2(matX) .* yFun(matY);

    col = bsxfun(@times, reshape(col1, 1, 1, []), mat1) ...
        + bsxfun(@times, reshape(col2, 1, 1, []), mat2);
    
    col = bsxfun(@plus,  reshape(colBkg, 1, 1, []), col);
    
    rVal= rFun(sqrt(matX.^2 + matY.^2));
    col(:,:,4) = rVal * (maxAlpha/max(rVal(:)));
end