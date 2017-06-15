function res = name_par(subdir, kind, ext, comment, varargin)
% res = name_par(subdir, kind, ext, [comment, 'opt1', opt1, ...])
%
% 'add_datestr', true ...
% 'bCaller', '' ...
% 'code_base', '/CodeNData/Code/' ...
% 'data_base', '/CodeNData/Data/' ...
% 'verbose', true ...
% 'journal', true ...
% 'create_dir', true ...
%
% See also PsyGit.name, journal, logging

% Defaults
S = varargin2S(varargin, { ...
        'add_datestr', true ...
        'bCaller', '' ...
        'code_base', '/CodeNData/Code/' ...
        'data_base', '/CodeNData/Data/' ...
        'verbose', true ...
        'journal', true ...
        'create_dir', true ...
        });

if ~exist('ext', 'var'), ext = ''; end
if ~exist('comment', 'var'), comment = ''; end
    
% Get baseCaller
if isempty(S.bCaller)
    bCaller = baseCaller({'name_par'});
    
    if strcmp(bCaller, 'base')
        warning('BaseCaller not found. Using current folder instead!');
        
        pth = pwd;
        nam = 'base';
    else
        [pth, nam] = fileparts(bCaller);
    end    
else
    [pth, nam] = fileparts(S.bCaller);
end

% Replace code_base in the pth with data_base
occurence = strfind(pth, S.code_base);
if ~any(occurence)
    warning(['No pattern %s found in the path; using the code folder.\n', ...
             'Try setting ''code_base'' referring to help name_par.\n'], ...
        S.code_base);
elseif nnz(occurence) > 1
    warning(['Multiple occurence of %s found in the path; replacing all to %s\n', ...
             'Try setting ''code_base'' referring to help name_par.\n'], ...
        S.code_base, S.data_base);
end
pth = strrep(pth, S.code_base, S.data_base);
pth_full = fullfile(pth, nam, subdir);

% Make full name
nam_full = str_bridge('_', nam, kind);

if S.add_datestr
    nam_full = str_bridge('_', nam_full, datestr(now, 'yyyymmddTHHMMSS'));
end

nam_full = str_bridge('_', nam_full, comment);
    
% Output
res = fullfile(pth_full, [nam_full, ext]);

% Create folder if absent
if ~exist(pth_full, 'dir') && S.create_dir
    mkdir(pth_full);
end

% Journal
if S.journal,
    journal('Named %s in %s\n', {[nam_full, ext], fullfile(pth, subdir)}, 'verbose', S.verbose);
end