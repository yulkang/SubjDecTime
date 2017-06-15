function [file, name] = list_file(op, filt, varargin)
% LIST_FILE - Similar to uigetfile but shows listdlg.
%
% [file, name] = list_file(op, filt, varargin)
%
% op: 'get' or 'put'
%
% See also: listdlg

% Get file list
files = dirCell(filt);
names = file_names(files);

% Preprocess arguments
S = varargin2S(varargin, {
    'PromptString', 'Choose file(s)' ...
    'SelectionMode', 'single' ...
    });

if isfield(S, 'InitialValue') && ...
        (ischar(S.InitialValue) || iscell(S.InitialValue))
    S.InitialValue = strcmpfinds(S.InitialValue, names);
end
C   = S2C(S);

% Add [new] entery at the end
if strcmp(op, 'put')
    names{end+1} = '[new..]';
end

% Choose file
sel = listdlg('ListString', names, C{:});

% Postprocess
switch op
    case 'get'        
        [file, name] = sel2name(sel, files, names, varargin2S(C));
        
    case 'put'
        if any(strcmp('[new..]', names(sel)))
            names{end+1} = input('Enter new name: ', 's');
            files{end+1} = strrep(filt, '*', names{end});
        end
            
        [file, name] = sel2name(sel, files, names, varargin2S(C));
end
end


function names = file_names(files)
names = cell(size(files));

for ii = 1:length(files)
    [~, names{ii}] = fileparts(files{ii});
end
end


function [file, name] = sel2name(sel, files, names, S)
if isempty(sel)
    file = 0;
    name = 0;
elseif strcmp(S.SelectionMode, 'single')
    file = files{sel};
    name = names{sel};
else
    file = files(sel);
    name = names(sel);
end
end