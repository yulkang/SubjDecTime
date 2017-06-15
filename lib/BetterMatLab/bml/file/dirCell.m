function res = dirCell(filt, ui, varargin)
% DIRCELL   returns a cell array of filtered file names.
%
% res = dirCell(filt)
%
% filt  : (1) a string filter, like 'dirname/*.ext', or
%         (2) an existing file's name, like 'dirname/filename.ext', or
%         (3) a cell array of existing files' name, like 
%             {'dirname/filename1.ext', 'dirname/filename2.ext'}.
%
% res   : Always a cell array, e.g.,
%         {'dirname/filename1.ext', 'dirname/filename2.ext'}
%         In case a filter is given, the file names are sorted in ascending order.
%
%
% res = dirCell(filt, true, opt)
%
% : equivalent to uigetfileCell(filt, opt).
% 
%
% See also DIR, UIGETFILECELL.

if (nargin >= 2) && (ui == true)
    res = uigetfileCell(filt, varargin{:});
else
    if ischar(filt)
        if exist(filt, 'file')
            res = {filt};

        else
            pth = fileparts(filt);
            rStruct = dir(filt);

            res = cellfun(@(fName) fullfile(pth, fName), sort({rStruct.name}), ...
                         'UniformOutput', false);
        end

    elseif iscell(filt) && ...
           all(cellfun(@(fname) exist(fname, 'file'), filt))

        res = filt;

    else
        error('Give a string filter, or existing file name(s)!');
    end
end