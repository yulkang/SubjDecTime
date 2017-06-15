function ds = dsfile(op, file, in, varargin)
% ds = dsfile(op, file, in, varargin)
%
% % Append rows.
% ds = dsfile('add', file, STRUCT_OR_NAME_VALUE_PAIR) 
%
% % Modify arbitrary rows. See DS_SETS for details.
% ds = dsfile('set', file, {INPUT_FOR_ds_setS})    
%
% % Read arbitrary rows. Omit index to read all.
% % readS: read into a struct.
% % read : read into a dataset.
% ds = dsfile('readS', file, [index])      
%
% index: index or function handle that gets ds.
%
% 2014-2015 (c) Yul Kang. hk2699 at columbia dot edu.

persistent lastfile

S = varargin2S(varargin, {
    'verbose', true
    'fields',  {}
    'unpackFields', true
    'unpackFieldsArg', {}
    });

if nargin < 2 || isempty(file)
    assert(~isempty(lastfile), 'Specify file at least on the first call!');
    file = lastfile;
else
    lastfile = file;
end

switch op
    case {'add', 'set'}
        if S.unpackFields
            in = unpackFields(in, S.unpackFieldsArg{:});
        end
end

switch op
    case 'add'
        %% Load
        try
            load(file, 'ds');
        catch
            ds = dataset;
        end
        
        %% Add
        ds = ds_setS(ds, length(ds)+(1:length(in)), in);
        
        %% Save
        pth = fileparts(file);
        if ~exist(pth, 'dir')
            mkdir(pth);
        end
        
        save(file, 'ds');
        
    case 'set' % Use ds_set_cell
        %% Load
        try
            load(file, 'ds');
        catch
            warning('No file exists!');
            ds = dataset;
        end
        
        %% Set
        ds = ds_setS(ds, in{:});
        
        %% Save
        pth = fileparts(file);
        if ~exist(pth, 'dir')
            mkdir(pth);
        end
        
        save(file, 'ds');
        
    case {'readS', 'read'} % read into a struct/dataset
        %% Load
        try
            load(file, 'ds');
        catch
            warning('No file exists!');
            ds = dataset;
        end
        
        %% Parse querry into indices
        if nargin < 3 || isempty(in)
            ix = 1:length(ds);
        elseif isnumeric(in) || islogical(in)
            ix = in;
        elseif isa(in, 'function_handle')
            ix = in(ds);
        else
            error('Not implemented yet!'); % Implemented if needed
        end
        
        %% Set output
        ds = ds(ix, :);
        
        % Convert to a struct (array)
        if strcmp(op, 'readS')
            ds = ds2struct(ds);
        end
        
end