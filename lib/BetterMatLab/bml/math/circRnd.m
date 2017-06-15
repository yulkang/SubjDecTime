function [xy, rt] = circRnd(nDot, rAp, rt, rApIn)
% CIRCRND  Sample x, y, r, and th, uniformly within a circle 
%
% [xy, rt] = circRnd(nDot, rAp, r, rApIn)
%
% r:  precomputed random numbers in [0,1]. A 2 x nDot matrix.
%
% xy: (x,y)     x nDot matrix
% rt: (r,theta) x nDot matrix
%
% See also: TESTCIRCRND, CIRCWRAP.
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.


    %% Sample in a radius-theta square
    if nargin < 3 || isempty(rt)
        rt  = rand(2,nDot);
    end
    if nargin < 4 || isempty(rApIn)
        rApIn = 0;
    end
    
    %% Fold into a radius-theta triangle.
    % The original sample is a radius-theta square. 
    % Take the top left triangle, and flip its both coordinates.
    out = rt(2,:) > rt(1,:);
    rt(:,out) = 1-rt(:,out);
    
    %% Transform into a radius-theta triangle
    % Avoiding intermediate variable can be slightly faster
    % because it dispenses with allocation. But it reduces readability.
         
    % rt(:,rt(2,:) > rt(1,:)) = 1-rt(:,rt(2,:) > rt(1,:));

    % Elongate the triangle 2*pi fold on the theta side.
    rt(2,:)   = rt(2,:) ./ rt(1,:) * 2*pi;
    
    % Adjust the range of r to [rApIn, rAp].
    rt(1,:)   = rt(1,:) .* (rAp - rApIn) + rApIn;

    %% Transform into a Cartesian system
    xy(1,:)   = rt(1,:) .* cos(rt(2,:));
    xy(2,:)   = rt(1,:) .* sin(rt(2,:));
        
    
	%% Easier-to-understand expression
    
%     dia = 2*pi*rAp;
% 
%     rt  = bsxfun(@times, rand(2,nDot), [rAp; dia]);
%     out = rt(2,:) > rt(1,:) * (2*pi);
% 
%     rt(:,out) = bsxfun(@minus, [rAp; dia], rt(:,out));
%     rt(2,:)   = rt(2,:) ./ rt(1,:);
% 
%     xy(1,:)   = rt(1,:) .* cos(rt(2,:));
%     xy(2,:)   = rt(1,:) .* sin(rt(2,:));
end
