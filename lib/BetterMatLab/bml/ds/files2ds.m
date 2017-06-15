function lst = files2ds(files, cols, varargin)
% lst = files2ds(files, cols, varargin)
%
% cols: {columnName, funHandle}
% funHandle
% : @() 
% : @(L)   L: loaded variables and previously calculated columns
% : @(L,f) f: outputs from filepartsCell2.
% 
% OPTIONS
% -------
% 'loadOpt',      {}
% 'cachePth',     'Data/files2ds/cache'
% 'cache',        'cache'
% 'skipOld',      true
% 'removeLoaded', true      % true, false, or cell array
%
% OUTPUT
% lst.file_ : relative path to the file
% lst.date_ : date modified.
%
% See also filepartsCell2.

S = varargin2S(varargin, {
    'loadOpt',      {}
    'cachePth',     'Data/files2ds/cache'
    'cache',        'cache'
    'skipSameDate', true
    'removeLoaded', true    % true, false, or cell array
    });

datefmt = 'yyyymmddTHHMMSS';

if nargin < 1 || isempty(files)
    files = strrep(uipickfiles('filterSpec', 'Data/*.mat'), pwd, '');
elseif ischar(files)
    files = strrep(uipickfiles('filterSpec', files), pwd, '');
end
if nargin < 2
    cols = {};
    exprs = {};
else
    cols  = varargin2C(cols);
    exprs = cols(2:2:end);
    cols  = cols(1:2:end);
end
ncol = length(cols);

%% Load cache if available
cacheFile = fullfile(S.cachePth, [S.cache, '.mat']);
if exist(cacheFile, 'file')
    load(cacheFile, 'lst');
else
    lst = cell2ds({'file_', 'date_'});
end

%% Load files
nfile = length(files);
ncol  = length(cols);
for ii = nfile:-1:1
    file   = files{ii};
    ixFile = strcmp(file, lst.file_);
    
    d = dir(file);
    cdate = datestr(d.date, datefmt);
    
    if ~any(ixFile)
        % Append if absent
        ixFile = [ixFile; true]; %#ok<AGROW>
    elseif nnz(ixFile) == 1
        % Skip if same
        try
            if S.skipSameDate ...
                && datenum(cdate, datefmt) == datenum(lst.date_{ixFile}, datefmt) ...
                && ~any(datasetfun(@isempty, lst(ixFile,cols)))
                continue;
            end
        catch
        end
    else
        error('Duplicate rows!');
    end
    
    %% Load
    L = load(file, S.loadOpt{:});
    loadedCols = fieldnames(L);
    
    %% Calculate columns
    for jj = 1:ncol
        col  = cols{jj};
        expr = exprs{jj};

        switch nargin(expr)
            case 0
                L.(col) = expr();
            case 1
                L.(col) = expr(L);
            case 2
                L.(col) = expr(L, filepartsCell2(file));
        end
    end
    
    %% Remove loaded vars
    if isequal(S.removeLoaded, true)
        L = rmfield(L, setdiff(loadedCols, cols));
    elseif iscell(S.removeLoaded)
        L = rmfield(L, S.removeLoaded);
    end
    
    %% Set
    L.file_ = file;
    L.date_ = cdate;
    
    lst = ds_setS(lst, ixFile, L);
end

%% Save cache
mkdir2(fileparts(cacheFile));
save(cacheFile, 'lst');
fprintf('Saved cache to %s\n', cacheFile);