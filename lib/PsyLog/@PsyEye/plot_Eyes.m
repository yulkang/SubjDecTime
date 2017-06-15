function [ts, xys, pupils] = plot_Eyes(files, varargin)
% PLOT_EYES - Load Eye objects from multiple files and draw data against time.
%
% [ts, xys, pupils] = plot_Eyes(files, varargin)
%
% See also PsyEye.plotTXY, PsyMouse.plotTXY

S = varargin2S(varargin, {...
    't_align_to',   0, ...
    'xy_arg',       {}, ...
    'pupil_arg',    {'r-'}, ...
    'pupil_divide_by', 600, ...
    'legend',       {}, ...
    'Eye_variable', 'Eye'});

if ~iscell(files)
    error('files should be a cell array of file names!');
else
    n = length(files);
end
if isscalar(S.t_align_to)
    S.t_align_to = repmat(S.t_align_to, [n 1]);
else
    S.t_align_to = S.t_align_to(:);
end

% Arguments for individual plots
S_indiv = S;
S_indiv.legend = {};

% Prepare output
if nargout >= 1, ts = cell(1,n); end
if nargout >= 2, xys = cell(1,n); end
if nargout >= 3, pupils = cell(1,n); end

for ii = 1:n
    % All but the last individual traces are drawn without legend.
    if ii == n
        S_indiv.legend = S.legend;
    end
    
    % Individual alignment
    S_indiv.t_align_to = S.t_align_to(ii);
    C_indiv = S2C(S_indiv);
    
    % Load & plot
    L = load(files{ii}, S.Eye_variable);
    plotTXY(L.(S.Eye_variable), C_indiv{:});
    hold on;
    
    % Save output arguments
    if nargout >= 1
        ts{ii}  = tTrim(L.(S.Eye_variable), 'xyDeg') - S_indiv.t_align_to;
    end
    if nargout >= 2
        xys{ii} = vTrim(L.(S.Eye_variable), 'xyDeg');
    end
    if nargout >= 3
        pupils{ii} = vTrim(L.(S.Eye_variable), 'pupil');
    end
end
hold off;