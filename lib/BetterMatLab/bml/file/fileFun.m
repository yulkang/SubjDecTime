function [res success] = fileFun(op, filt, args, varargin)
% FILEFUN   Apply operation to the specified files and return array.
%           Useful when you extract a summary statistic from an unwieldy
%           size of data in many files. Utilize addArgs and rmField option
%           (below) to conveniently load necessary variables while excluding
%           too large ones.
%
% [res success] = fileFun(op, filt, {'arg1', ...}, 'opt1', val1, ...)
%
%     op            : Any function that receives a scalar struct with
%                     fields of specified variables loaded from the file, 
%                     and returns one output, e.g., a number or a struct.
%                     I.e., the input is such an S from S=load(FILE, 'var1', ..),
%                     where each FILE is specified by FILT (below).
%                     See <a href="matlab:help load">help load</a>
%
%     filt          : Specifies files, e.g., 'test/*.mat',
%                     or cell array of file names.
%                     Fed to dirCell. See <a href="matlab:help dirCell">help dirCell</a>.
%
%     arg           : Variables loaded from the file, packed into a struct,
%                     and feed into op().
%
%     success       : Logical vector. False if error occured for the file.
%
% Options
%
%     uniformOutput : If false, res is a cell array. Defaults to true.
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
%     addArgs       : If true, assuming res is a struct, adds arg's to 
%                     res as fields. Defaults to false.
%
%     rmField       : If cell array of variable names are given,
%                     excludes the variables from fields of the result.
%                     Defaults to {}.
%
%     verbose       : If false, hide messages. Defaults to true.
%
% See also CELLFUN, ARRAYFUN, ARRAYFUNANY, MATFILE, DIRCELL, LOAD.
%
% Written by Hyoung Ryul "Yul" Kang (2012). hk2699 at columbia dot edu.

opt      = struct('uniformOutput',    true, ...
                  'verbose',          true, ...
                  'errorBehav',       'error', ...
                  'default',          [], ...
                  'addArgs',          false, ...
                  'rmFields',         {{}});

stSec = GetSecs;
              
files    = dirCell(filt);
nTrial   = length(files);
opt      = varargin2fields(opt, varargin);
success  = true(1, nTrial);

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

if ~opt.addArgs && ~isempty(opt.rmFields)
    warning('When addArgs = false (default), rmFields will be ignored.');
end    

%% Iterate over files
for iFile = nTrial:-1:1
    try
        %% Load necessary fields.
        if opt.verbose
            fprintf('Loading %s (%d/%d).. ', files{iFile}, iFile, nTrial); 
        end
        
        rec  = load(files{iFile}, args{:});
        
        if opt.verbose, fprintf('Loaded.\n'); end
    
        %% Add Args minus rmFields to the structure if asked.
        if opt.addArgs
            % Overwrite loaded fields with fields from op(), not the other way.
            cRes = copyFields(copyFields(struct, rec, opt.rmFields, true, true), ...
                              op(rec));
        else
            cRes = op(rec);
        end
        
        %% Set to cell or array.
        if opt.uniformOutput
            if exist('res', 'var') && isstruct(res)
                res(iFile) = copyFields(res(iFile), cRes, {}, true);
            else
                res(iFile) = cRes;
            end
        else
            res{iFile} = cRes; 
        end

    %% Respond to errors
    catch lastErr
        switch opt.errorBehav
            case 'error'
                rethrow(lastErr);
            
            case 'skip'
                fprintf('Skipping due to errror: %s\n', lastErr.message);

            case 'default'
                fprintf('Giving default due to errror: %s\n', lastErr.message);
                if opt.uniformOutput
                    res(iFile) = opt.default;
                else
                    res{iFile} = opt.default;
                end
        end

        success(iFile) = false;
    end
end

%% Summarize results
if opt.verbose
    fprintf('Succeeded in %d out of %d files (%2.2f%%).\n', ...
                nnz(success), length(files), nnz(success)/length(files)*100);
end

switch opt.errorBehav
    case 'skip'
        if opt.verbose
            fprintf('Keeping only succeeded files. Res is for files(success).\n');
        end
        if nnz(success) == 0
            res = [];
        else
            res = res(success);
        end

    case 'default'
        if opt.verbose
            fprintf('Failed results are substituted with the default.\n');
        end
end

if opt.verbose
    fprintf('Finished in %1.2f seconds.\n', GetSecs - stSec);
end
