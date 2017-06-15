function pth = path_data(sub_pth, varargin)
% path_data  Gives data base folder given code paths.
%
% pth = path_data(sub_pth, 'opt1', opt1, ...)
%
% Option       Default                        Explanation
% ----------------------------------------------------------------------
% 'code_pth',  mfilename('fullpath')      ... Code's path to extract the path to code_base from.
% 'code_base', [filesep, 'Code', filesep] ... code_base string.
% 'data_base', [filesep, 'Data', filesep] ... data_base string.
%
% See also: name_par

persistent fsep
if isempty(fsep), fsep = filesep; end

% Give defaults
S = varargin2S(varargin, { ...
    'code_pth',  mfilename('fullpath')      ... Code's path to extract the path to code_base from.
    'code_base', [fsep, 'Code' fsep] ... code_base string.
    'data_base', [fsep, 'Data' fsep] ... data_base string.
    });

% Default to pwd
if nargin == 0
    sub_pth = pwd;
end

% Function/script name -> full path without extension
if ~any(sub_pth == fsep)
    sub_pth = which(sub_pth);
    [pth, nam] = fileparts(sub_pth);
    sub_pth = [pth, fsep, nam];
end

% If the current path is the CODE_BASE_,
if strcmp(sub_pth, CODE_BASE_)
    pth = DATA_BASE_;
    return;
end

% Remove the path string up to S.code_base
ix_sub = strfind(sub_pth, S.code_base);
if ~isempty(ix_sub)
    sub_pth = sub_pth((ix_sub(1)+length(S.code_base)):end);
end

% Add filesep at the end
if S.code_pth(end) ~= fsep
    S.code_pth = [S.code_pth, filesep];
end

% Find code_base string
ix       = strfind(S.code_pth, S.code_base);
if isempty(ix)
    error('code_pth doesn''t contain code_base %s\n', S.code_base);
else
    pth = fullfile(S.code_pth(1:ix(1)), S.data_base, sub_pth);
end
