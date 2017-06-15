classdef PsyGrating < PsyDeepCopy
    properties
        apRDeg
        imageMat = nan(1,1,3,1);
    end
    
    
    methods 
        function me = PsyGrating % TODO
        end
    end
    
    
    methods (Static)
        function [col mat matX matY] = gratingPix(xVec, yVec, xFun, yFun, rFun, col1, col2)
            % [col mat matX matY] = gratingPix(xVec, yVec, xFun, yFun, rFun, col1, col2)

            [matX matY] = meshgrid(xVec, yVec);
            mat = xFun(matX) .* yFun(matY) .* rFun(sqrt(matX.^2 + matY.^2));

            col = bsxfun(@times, reshape(col2, 1, 1, []), mat) ...
                + bsxfun(@times, reshape(col1, 1, 1, []), 1-mat);
        end
    end
end