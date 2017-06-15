function [ds, succ, any_op, L_out] = ds_file_fun(ds, files, varargin)
% DS_FILE_FUN - Perform multiple operations for files and rows and save to field.
%
% [ds, succ, any_op, L_out] = file_fun_ds(ds, files, op1, op2, ..., 'opt1', opt1, ...)
%
% op 
% : {cond, {vars}, fun(row, L, ix, [ds]), out_field, [op_opt]}
%
% cond
% : a logical scalar or vector (same length as files), indicating
%   whether to perform the given operation for the corresponding file.
%
% vars 
% : Give ':' to load all. Otherwise, give a cell array of var names.
%
% fun(row, L, ix, [ds]) 
% : row is a row in the dataset that corresponds to the file.
%   L is a struct that contains vars loaded from the file.
%   ix is the index of the row in the dataset.
%   ds is the whole dataset. Set give_ds = true to use.
%
% out_field
% : Field(s) of the ds to save the result from fun().
%   In case out_field is a cell array, fun() should have matching
%   number of outputs.
%
% op_opt
% : name-value pairs of options specific to the operation.
%
% 'give_ds'
% : Gives the whole dataset, ds, to fun. Can slow down the operation.
%   Defaults to false.
%
% opt
% : name-value pairs.
%
% 'parallel'
% : If true, uses parfor. Defaults to false.

ix_char = cellfun(@(c) ischar(c), varargin);
opt_st  = find(ix_char, 1, 'first');

% Operations
if isempty(opt_st)
    ops = varargin;
else
    ops = varargin(1:(opt_st-1));
end
if isempty(ops)
    error('No operations were given!');
end

% Options
S    = varargin2S(varargin(opt_st:end), {...
    'parallel', false ...
    'catch', true, ...
    'rethrow', true ...
    'size_chunk', 30 ...
    });

% Temp variables
n_op   = length(ops);
n_file = length(files);

if n_file ~= length(ds)
    error('Number of files must match the length of the dataset!');
end

% Preprocess conditions
opS(n_op) = struct('cond', [], 'vars', {{}}, 'fun', [], 'out_field', '', 'opt', struct);
load_all  = false;
any_cond  = false(n_file, 1);

% Parse ops = {op1, op2, ...} = {{cond, {vars}, fun, out_field, op_opt}, ...}
for i_op = 1:n_op
    % Give default to op_opt = ops{i_op}{5}, if missing
    if length(ops{i_op}) < 5
        ops{i_op}{5} = {};
    end
    ops{i_op}{5} = varargin2S(ops{i_op}{5}, {'give_ds', false});
    
    % Package into opS, a struct.
    opS(i_op) = cell2struct(ops{i_op}(:)', ...
                {'cond', 'vars', 'fun', 'out_field', 'opt'}, 2);
       
    % Parse cond
    if isscalar(opS(i_op).cond)
        opS(i_op).cond = repmat(opS(i_op).cond, [n_file, 1]);
    end
    any_cond = any_cond(:) | opS(i_op).cond(:);
    
    % Parse vars
    if isequal(opS(i_op).vars, ':')
        load_all = true;
    end
    
    % Parse op_opt
    if opS(i_op).opt.give_ds
        error('ds_file_fun:give_ds_unsupported', ...
            'give_ds = true is unsupported yet!');
    end
end

% Initialize output
if nargout >= 4
    L_out = cell(1,n_file);
end

% Repeat over files
if S.parallel
    warning('ds_file_fun:parallel_unsupported', ...
        'Parallel mode unsupported yet!');
end

n_argout   = nargout;
to_rethrow = S.rethrow;

n_any_cond  = nnz(any_cond);
ix_any_cond = find(any_cond);

any_op     = false(1, n_file);
succ       = false(1, n_file);

for i_chunk = 1:ceil(n_any_cond/S.size_chunk)
    
    % Divide into chunks so that R doesn't get too big.
    file_incl = ix_any_cond(ix_chunk(n_any_cond, i_chunk, S.size_chunk));
    n_incl    = length(file_incl);
    R         = cell(1, n_incl);
    
    % Divide ds, too, since ds is copied to workers.
    ds_incl     = ds(file_incl,:);
    files_incl  = files(file_incl);
    
    % Other temporary variables
    any_op_incl = false(1, n_incl);
    succ_incl   = false(1, n_incl);
    
    if nargout >= 4
        L_out_incl = cell(1,n_incl);
    end

    if S.catch
        parfor i_file = 1:n_incl 
            try

                ii_file = file_incl(i_file);

                [R{i_file}, L, any_op_incl(i_file)] = ...
                    perform_op(files_incl{i_file}, opS, ds_incl(i_file,:), ii_file, load_all);

                % Copy L if requested
                if n_argout >= 4
                    L_out_incl{i_file} = L;
                end
                succ_incl(i_file) = true;
                
            catch err_op
                if to_rethrow
                    rethrow(err_op);
                else
                    fprintf('Error while processing %s\n', files{i_file});
                    disp(err_msg(err_op));
                end
            end
        end
    else
        for i_file = 1:n_incl 

            ii_file = file_incl(i_file);

            [R{i_file}, L, any_op_incl(i_file)] = ...
                perform_op(files_incl{i_file}, opS, ds_incl(i_file,:), ii_file, load_all);

            % Copy L if requested
            if n_argout >= 4
                L_out_incl{i_file} = L;
            end
            succ_incl(i_file) = true;
        end
    end
    
    % Copy results into ds
    for i_file = hVec(find(any_op_incl))
        ds = ds_set(ds, file_incl(i_file), R{i_file}); 
    end
    
    any_op(file_incl)   = any_op_incl;
    succ(file_incl)     = succ_incl;
    
    if n_argout >= 4
        L_out(file_incl) = L_out_incl;
    end
end
end


function [R, L, any_op] = perform_op(file, opS, row, i_file, load_all)
    R = struct; % result
    L = struct; % loaded variables
    loaded_all = false;
    any_op = false;
    n_op = length(opS);

    for i_op = 1:n_op
        if opS(i_op).cond(i_file)     
            any_op = true;

            % Load necessary variables
            if load_all && ~loaded_all
                L = load(file);
                loaded_all = true;
            else
                % Load missing fields only
                to_load = setdiff(opS(i_op).vars, fieldnames(L)');

                if ~isempty(to_load)
                    L = load(file, to_load{:});
                end
            end

            % Perform operation
            out_fields   = arg2cell(opS(i_op).out_field);
            n_out_fields = length(out_fields);
            outputs      = cell(1, n_out_fields);
            
            if opS(i_op).opt.give_ds
                [outputs{:}] = ...
                    opS(i_op).fun(row, L, i_file, ds);
            else
                [outputs{:}] = ...
                    opS(i_op).fun(row, L, i_file);
            end    

            % Assign output(s)
            for i_field = 1:n_out_fields
                R.(out_fields{i_field}) = outputs{i_field};
            end
        end
    end
end
