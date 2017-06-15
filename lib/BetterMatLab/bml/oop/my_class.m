function cl = my_class(mfile)
% cl = my_class(mfile=(caller))

if nargin < 1
    db = dbstack('-completenames');
    if length(db) < 2
        mfile = '';
    else
        mfile = db(2).file;
    end
end
cl = file2class(mfile);
end