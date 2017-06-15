function d = GET_DIR(kind, computer, subdir)
% GET_DIR  Return computer-specific path to a directory.
%   
% d = GET_DIR(kind, [computer, subdir])
%
% When kind is ommitted or empty, returns a struct containing all 
% names defined.
%
% See also: COMPUTER_SHORT_NAME, DIR_

if nargin < 2 || isempty(computer)
    computer = COMPUTER_SHORT_NAME; 
end
if nargin < 3
    subdir = {};
end

if exist(fullfile(userhome, 'Dropbox/CodeNData'), 'dir')
    code_n_data = fullfile(userhome, 'Dropbox/CodeNData');
else
    code_n_data = fullfile(userhome, 'CodeNData');
end

D.CODE_BASE = fullfile(code_n_data, 'Code');
D.DATA_BASE = fullfile(code_n_data, 'Data');

D.CODE = D.CODE_BASE;
D.DATA = D.DATA_BASE;
D.PHD  = fullfile(D.CODE, 'Shadlen');
D.MDD  = fullfile(D.CODE, 'Shadlen/MDD');

if exist('kind', 'var') && isfield(D, kind)
    if iscell(subdir)
        d = fullfile(D.(kind), subdir{:});
    else
        d = fullfile(D.(kind), subdir);
    end
else
    if ~isempty(D)
        if nargout == 0
            help GET_DIR
            fprintf('Current DIR_:\n');
            disp(D);
        else
            d = D;
        end
    else
        fprintf('DIR_ is empty or undefined!\n');
    end
end
