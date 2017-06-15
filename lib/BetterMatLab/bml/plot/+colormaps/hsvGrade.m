function map = hsvGrade(m, varargin)
% map = hsvGrade(m, varargin)
%
%     'preset', '' % red, blue, purple, green
%     'hsvSt',   [0 1 1]
%     'hsvDelta',[0.2, -1, -0.3]
%     'hsvEn',   []
%     'betaHue', [1 1]
%     'betaSat', [0.8, 0.5]
%     'betaVal', [1 1]
%     'testPlot', false
%
% 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.

S = varargin2S(varargin, {
    'preset', '' % red, blue, purple, green
    'hsvSt',   [0 1 1]
    'hsvDelta',[0.2, -1, -0.3]
    'hsvEn',   []
    'betaHue', [1 1]
    'betaSat', [0.8, 0.5]
    'betaVal', [1 1]
    'testPlot', false
    });

switch S.preset
    case ''
        S = varargin2S({
                'hsvSt', [0 1 1]
                'hsvEn', [0.2 0 0.8]    
                'betaSat', [0.8, 0.6]
            }, S);
    case 'red'
        S = varargin2S({
                'hsvSt', [0 1 1]
                'hsvEn', [0.2 0 0.8]    
                'betaSat', [0.8, 0.6]
            }, S);
    case 'blue'
        S = varargin2S({
                'hsvSt', [0.6 1 0.8]
                'hsvEn', [0.4 0 0.8]
                'betaSat', [1, 0.9]
            }, S);
    case 'purple'
        S = varargin2S({
                'hsvSt', [0.82 1 0.85]
                'hsvEn', [0.55 0 0.8]
                'betaSat', [1.5, 1] % [st, en], The smaller, the steeper
            }, S);
    case 'green'
        S = varargin2S({
                'hsvSt', [0.45 1 0.4]
                'hsvEn', [0.1 0 0.8]
                'betaHue', [0.8, 1.2]
                'betaSat', [1, 1]
                'betaVal', [0.8, 1.3]
            }, S);
end

if isempty(S.hsvEn)
    S.hsvEn = S.hsvSt + S.hsvDelta;
end

if nargin < 1, m = size(get(gcf,'colormap'),1); end
if m == 0, map = []; return; end

hsvMat = linspaceN(S.hsvSt, S.hsvEn, m);

% Apply curvature
hsvMat = betaTransform(hsvMat, [S.betaHue(:), S.betaSat(:), S.betaVal(:)]);
% hsvMat(:,1) = betacdf(hsvMat(:,1), S.betaHue(1), S.betaHue(2));
% hsvMat(:,2) = betacdf(hsvMat(:,2), S.betaSat(1), S.betaSat(2));
% hsvMat(:,3) = betacdf(hsvMat(:,3), S.betaVal(1), S.betaVal(2));

% Restrict range
hsvMat(:,1) = mod(hsvMat(:,1), 1);
hsvMat(:,2:3) = max(min(hsvMat(:,2:3), 1), 0);

map = hsv2rgb(hsvMat);

%% Test
if S.testPlot
    cla; 
    for ii=1:m
        plot([1 2], [ii ii], 'o-', ...
            'MarkerFaceColor', map(ii,:), 'Color', map(ii,:), ...
            'LineWidth', 3, 'MarkerSize', 8); 
        hold on; 
    end; 
    ylim([0 m+1]);
end