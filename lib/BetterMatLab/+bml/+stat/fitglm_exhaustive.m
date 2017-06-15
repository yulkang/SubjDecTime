function varargout = fitglm_exhaustive(varargin)
% Picks the best model among all 2^n_param possible models.
%
% [mdl, info, mdls] = fitglm_exhaustive(X, y, glm_args, varargin)
% [...] = fitglm_exhaustive(tbl, [], glm_args, varargin)
% [...] = fitglm_exhaustive(tbl, ResposeVar, glm_args, varargin)
%
% OPTIONS:
% 'model_criterion', 'BIC'
% 'must_include', [] % Numerical indices of columns to include.
% 'crossval_args', {}
% 'UseParallel', 'model' % 'model'|'none'
%
% WARNING:
% Returning mdls (all models) can be memory intensive. 
% When size(X) is about 1500 x 17 and 2^17 models are fitted,
% mdls can take up >50GB.
% Use it only when you have enough memory.
%
% NOTE 1:
% Fitting all possible models can be impractical when size(X,2) > 25.
% - Try reducing the dimensionality using PCA.
% - If you have a priori reasons to believe some columns should always be
%   included, use the 'must_include' option.
%
% NOTE 2:
% Estimate the time and memory expenditure first by using a small subset of
% columns, like:
%
%     tic;
%     [mdl, info, mdls] = fitglm_exhaustive(X(:,1:8), ...)
%     toc;
%
%     whos mdls
%
% Then estimate the time and memory needed by multiplying 
% the elapsed time and mdls's size in the memory (Bytes) by 2^(size(X,2)-8).
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = fitglm_exhaustive(varargin{:});