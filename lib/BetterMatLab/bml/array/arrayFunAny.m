function [res success] = arrayFunAny(f, v, varargin)
% ARRAYFUNANY   Similar to arrayfun but allows any class of function/in/output.
%
% Note that this will be slower than MATLAB's arrayfun, although more
% flexible in that any class of output is allowed. Use as a convenience function
% only.
%
% [res success] = arrayFunAny(op, v, 'opt1', val1, ...)
%
%     op            : Any function that receives one input and returns one 
%                     output, e.g., a number, (cell) array, or struct (array).
%
%     v             : An array of any class, including cell or user-defined
%                     classes. Giving cell array will feed v{ii} to op().
%
%     success       : Logical vector. False if error occured for the file.
%
% Options
%
%     uniformOutput : If false, res is a cell array. Defaults to true.
%
%     catDim        : If nonzero, res is concatenated along specified dimension.
%                     When uniformOutput = true, output is a concatenated array.
%                     When uniformOutput = false, output is a cell vector
%                     along the specified dimension.
%
%                     If zero, res has the same size as v.
%                     Defaults to zero.
%
%     errorBehav    : Behavior when error occurs.
%                     If 'error', rethrows error.
%                     If 'default', substitutes the result with default.
%                     If 'skip', skips the file. It shortens res, 
%                     so that length(res) == nnz(success). 
%
%     default       : The value to assign to res when errorBehav = 'default'
%                     for the files resulted in an error. Defaults to [].
%
%     verbose       : If 0, hide messages. Defaults to 1. For more, set to 2.
%
% See also ARRAYFUN, CELLFUN, FILEFUN.
%
% Written by Hyoung Ryul "Yul" Kang (2012). hk2699 at columbia dot edu.

opt = struct('errorBehav', 'error', 'default', [], 'uniformOutput', true, ...
             'verbose', 1, 'catDim', 0, 'tolerateFieldErrors', true, ...
             'parallel', false);
opt = varargin2fields(opt, varargin);

if opt.verbose
    fprintf('Running function %s on %d entries..\n', func2str(f), numel(v));
end

stSec = GetSecs;

%% Input args
errorBehavRep = {'skip', 'default', 'error'};
if ~any(strcmp(opt.errorBehav, errorBehavRep))
    error(['errorBehav should be one of:' csprintf(' %s', errorBehavRep), '!']);
end

switch opt.errorBehav
    case 'default'
        if ~any(strcmp('default', varargin(1:2:end))) 
            warning(['Setting errorBehav = ''default'' ' ...
                     'without setting default can cause error!']);
            warning('default will be set to []..');
        end
        
    case 'skip'
        if any(strcmp('default', varargin(1:2:end))) 
            warning('When errorBehav = ''skip'', default will be ignored!');
        end
end

if opt.catDim == 0 && strcmp(opt.errorBehav, 'skip') && opt.uniformOutput ...
    && nnz(size(v)>1)>1

    error(['Cannot match >1D input and output''s size, ' ...
           'skip error entries, and provide uniform outputs at the same time!']);
end

%% Initialize results.
success = true(size(v));

%% Iterate over elements.
switch opt.errorBehav
    case 'error'
        if opt.parallel
            cUniformOutput = opt.uniformOutput;
            cTolerateFieldErrors = opt.tolerateFieldErrors;
            
            parfor ii = 1:numel(v)
                if iscell(v)
                    cRes = f(v{ii}); %#ok<PFBNS>
                else
                    cRes = f(v(ii));
                end

                if cUniformOutput
                    if isstruct(cRes) && cTolerateFieldErrors
                        % Prevents trivial errors from field orders.
                        for cField = fieldnames(cRes)'
                            res(ii).(cField{1}) = cRes.(cField{1});
                        end
                    else
                        res(ii) = cRes;
                    end
                else
                    res{ii} = cRes;
                end
            end
        else
            for ii = numel(v):-1:1
                
                if opt.verbose && mod(ii, 50) == 0, 
                    fprintf('calculating entry %d/%d (%1.3f sec elapsed)\n', ...
                        ii, numel(v), GetSecs - stSec);
                end
                
                if iscell(v)
                    cRes = f(v{ii});
                else
                    cRes = f(v(ii));
                end

                if opt.uniformOutput
                    if isstruct(cRes) && opt.tolerateFieldErrors
                        % Prevents trivial errors from field orders.
                        for cField = fieldnames(cRes)'
                            res(ii).(cField{1}) = cRes.(cField{1});
                        end
                    else
                        res(ii) = cRes;
                    end
                else
                    res{ii} = cRes;
                end
            end
        end
        
    otherwise
        if opt.parallel
            cUniformOutput = opt.uniformOutput;
            cTolerateFieldErrors = opt.tolerateFieldErrors;
            cVerbose = opt.verbose;
            cErrorBehav = opt.errorBehav;
            cDefault = opt.default;
            
            parfor ii = 1:numel(v)
                try
                    if iscell(v)
                        cRes = f(v{ii}); %#ok<PFBNS>
                    else
                        cRes = f(v(ii));
                    end

                    if cUniformOutput
                        if isstruct(cRes) && cTolerateFieldErrors
                            % Prevents trivial errors from field orders.
                            for cField = fieldnames(cRes)'
                                res(ii).(cField{1}) = cRes.(cField{1});
                            end
                        else
                            res(ii) = cRes;
                        end
                    else
                        res{ii} = cRes;
                    end

                catch lastErr
                    if cVerbose
                        fprintf('Error on element number %d: %s\n', ii, ...
                            lastErr.message);
                    end
                    success(ii) = false;

                    switch cErrorBehav
                        case 'error'
                            rethrow(lastErr);

                        case 'skip'
                            if cVerbose
                                fprintf('Skipping..\n');
                            end

                        case 'default'
                            if cVerbose
                                fprintf('Substituting with default..\n');
                            end

                            if cUniformOutput
                                res(ii) = cDefault;
                            else
                                res{ii} = cDefault;
                            end
                    end
                end
            end
        else
            for ii = numel(v):-1:1
                try
                    if iscell(v)
                        cRes = f(v{ii});
                    else
                        cRes = f(v(ii));
                    end

                    if opt.uniformOutput
                        if isstruct(cRes) && opt.tolerateFieldErrors
                            % Prevents trivial errors from field orders.
                            for cField = fieldnames(cRes)'
                                res(ii).(cField{1}) = cRes.(cField{1});
                            end
                        else
                            res(ii) = cRes;
                        end
                    else
                        res{ii} = cRes;
                    end

                catch lastErr
                    if opt.verbose
                        fprintf('Error on element number %d: %s\n', ii, ...
                            lastErr.message);
                    end
                    success(ii) = false;

                    switch opt.errorBehav
                        case 'error'
                            rethrow(lastErr);

                        case 'skip'
                            if opt.verbose
                                fprintf('Skipping..\n');
                            end

                        case 'default'
                            if opt.verbose
                                fprintf('Substituting with default..\n');
                            end

                            if opt.uniformOutput
                                res(ii) = opt.default;
                            else
                                res{ii} = opt.default;
                            end
                    end
                end
            end
        end
end

if opt.catDim == 0
    if nnz(size(v)>1)>1
        if strcmp(opt.errorBehav, 'skip') 
            warning(['Could not skip unsuccessful elements, to match '...
                     'input and output''s size! Refer to success (2nd output).']);
        end
        res = reshape(res, size(v));
    
    elseif nnz(success) == 0
        if opt.verbose
            warning('No successful entry -- skipped all!');
        end
        
        if opt.uniformOutput
            res = [];
        else
            res = {};
        end
        
    elseif strcmp(opt.errorBehav, 'skip')
        res = res(success);
    end
else
    res = reshape2vec(res(success), opt.catDim);
end

if opt.verbose
    fprintf('Elapsed time: %1.2f seconds.\n', GetSecs - stSec);
    fprintf('Succeded %d out of %d entries!\n', sum(success(:)), numel(success));
end