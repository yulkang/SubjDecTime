function [b2, dev, stats, y] = glmsim(b, x, link, varargin)
% [b2, dev, stats, y] = glmsim(b, x, link, varargin)

if nargin < 3 || isempty(link), link = 'logit'; end

S = varargin2S(varargin, {
    'n_dat', size(x, 1)
    'y',     []
    'x_resamp', 'no'
    'y_resamp', 'yes'
    });

f_scale_ix = @(src, dst) max(round((1:dst) / dst * src), 1);

x0 = x;
switch S.x_resamp
    case 'yes'
    case 'shuffle'
    case 'no'
        % Proportionately 'expand' indices.
        ix  = 1:S.n_dat;
        ix0 = f_scale_ix(size(x,1), S.n_dat);
        
        x(ix,:) = x0(ix0,:);
end

switch link
    case 'logit'
        if strcmp(S.y_resamp, 'sim')
            yhat = glmval(b, x, link);
            y = binornd(1,yhat);
        else
            [x_incl,~,ix] = unique(x, 'rows');
            [~,~,ix0]     = unique(x0, 'rows');

            nx = size(x_incl,1);
            y  = nan(S.n_dat, 1);
            
            for ii = 1:nx
                c_ix  = find(ix  == ii);
                c_ix0 = find(ix0 == ii);
                
                switch S.y_resamp
                    case 'yes'
                        n_ix = randsample(c_ix0, length(c_ix), true);
                    case 'shuffle'
                        n_ix = randsample(c_ix0, length(c_ix), false);
                    case 'no' % For sanity check
                        n_ix = c_ix0( f_scale_ix(length(c_ix0), length(c_ix)) );
                end
                
                y(c_ix) = S.y(n_ix);
            end
        end
        
        [b2, dev, stats] = glmfit(x, y, 'binomial');
        
    otherwise
        error('Not implemented yet!');
end