function [n_hist, incl, ix] = hist_nd(x, varargin)
% [n_hist, incl, ix] = hist_nd(x, varargin)
%
% X can have 2 to 4 columns: [x,y,C,R]. r and c will determine the
% row and column in hist3D. R and C will determine the position in 
% subplotRC.
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

if isa(x, 'dataset')
    names_def = x.Properties.VarNames;
    x = double(x);
else
    names_def = csprintf('d%d', 1:n_col);
end

x = full(x); % Work on a full x only.

n_col   = size(x, 2);
n_row   = size(x, 1);
siz     = ones(1,4);

assert(n_col <= 4 && n_col >= 2, 'x must have 2 to 4 columns!');

S = varargin2S(varargin, {
    'names',        names_def
    'label_fmt',    {}
    'label',        cell(1,4)
    'hist3D_opt',   {}
    });
if isempty(S.label_fmt)
    S.label_fmt = csprintf('%s=%%g', S.names);
end

% Find unique indices
ix      = zeros(size(x));
incl    = cell(1, n_col);

for i_col = 1:n_col
    [incl{i_col}, ~, ix(:,i_col)] = unique(x(:,i_col));
    
    siz(i_col) = length(incl{i_col});
end

% Determine subplot
nR      = siz(4);
nC      = siz(3);

% Determine labels
for i_col = 1:n_col
    if isempty(S.label(i_col))
        S.label{i_col} = csprintf(S.label_fmt{i_col}, ...
            incl{i_col});
    end
end

% Plot
for iR = 1:nR
    for iC = 1:nC
        subplotRC(nR,nC,iR,iC);
        
        % Filter scope
        filt     = true(n_row, 1);
        if n_col >= 3
            filt = filt & (ix(:,3) == iC);
        end
        if n_col >= 4
            filt = filt & (ix(:,4) == iR);
        end
        
        % Plot hist
        c_hist = accumarray(ix(filt,1:2), ones(nnz(filt),1), siz(1:2), @numel);
        imagesc(c_hist');
        axis xy;
        
        % Label axes
        set(gca, 'XTick', (1:siz(1)), 'YTick', (1:siz(2)), ...
            'XTickLabel', csprintf(S.label_fmt{1}, incl{1}), ...
            'YTickLabel', csprintf(S.label_fmt{2}, incl{2}));
        rotateXLabels(gca, 45);
        
        % Title
        s_title = '';
        
        if nR > 1 && iC == 1 % Give row titles
            s_title = str_bridge(' ; ', s_title, ...
                sprintf(S.label_fmt{4}, incl{4}(iR)));
        end
        if nC > 1 && iR == 1 % Give column titles
            s_title = str_bridge(' ; ', s_title, ...
                sprintf(S.label_fmt{3}, incl{3}(iC)));
        end
        title(s_title);
    end
end

% Output
siz = siz(1:n_col);
if nargout >= 1
    n_hist = accumarray(ix, ones(n_row, 1), siz, @numel);
end