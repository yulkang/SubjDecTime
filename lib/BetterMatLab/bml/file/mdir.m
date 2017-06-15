function d = mdir(mfile, subpath)
% d = mdir(mfile, subpath)

if nargin < 1 || isempty(mfile)
    S     = dbstack(1, '-completenames');
    
    if isempty(S)
        mfile = [pwd '/base'];
    else        
        mfile = S(1).file;
    end
else
    mfile = which(mfile);
end
if nargin < 2, subpath = ''; end

d = fullfile(fileparts(mfile), subpath);