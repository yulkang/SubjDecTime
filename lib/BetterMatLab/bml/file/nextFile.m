function [res, cIx, cIx2] = ...
    nextFile(rootName, pth, ext, numMode, numOnly, tStamp)
% File name with an index following the last existing file's.
%
% [res, cIx]  = nextFile(rootName, pth, ext, numMode, [numOnly=false, tStamp=now])
%
% rootName    : First part of the file name.
% pth         : Path to look for the existing files and to put the new file.
% ext         : Extension.
% numMode     : 'dateTime': Index is datestr(tStamp, 'yyyymmddTHHMMSS')
%               'num'     : Index is a positive integer.
% tStamp      : value acquire from matlab function 'now'.
%               If unset, gets new value of now.
%
% res         : Full path with an index following the last existing file's.
% cIx         : Index part of the new file's name.
%
%
% [n, lastIx] = nextFile(rootName, pth, ext, numMode, numOnly=true, [tStamp])
%
% n           : Number of files in the given format.
% lastIx      : Last index in the given format. Zero if none exists.
%
%
% Example:
%
% [res, cIx]  = nextFile('testSave_', '.', 'mat', 'dateTime'), save(res);
%
% res = ./testSave_20121108T064401.mat
% cIx = 20121108T064401
%
% [res, cIx]  = nextFile('testSave_', '.', 'mat', 'num'), save(res);
% 
% res = ./testSave_1.mat
% cIx = 1
%
% [res, cIx]  = nextFile('testSave_', '.', 'mat', 'num'), save(res);
% 
% res = testSave_2.mat
% cIx = 2
%
% [n, lastIx] = nextFile('testSave_', '.', 'mat', 'dateTime', true)
%
% n = 1
% lastIx = 1
%
% [n, lastIx] = nextFile('testSave_', '.', 'mat', 'num', true)
%
% n = 2
% lastIx = 2
%
% 
% by Hyoung Ryul ("Yul") Kang, 2012. hk2699 at columbia dot edu


if nargin < 2 || isempty(pth), pth = '.'; end
if nargin < 3 || isempty(ext),
    ext = 'mat'; 
elseif ext(1) == '.'
    ext = ext(2:end);
end
if nargin < 4, isempty(numMode), numMode = 'dateTime'; end
if nargin < 5, isempty(numOnly), numOnly = false; end
if nargin < 6, isempty(tStamp),  tStamp  = now; end

if ~any(strcmp(numMode, {'dateTime', 'num'}))
    error('Unsupported numMode: %s\n', numMode);
end

if numOnly
    [res cIx] = numFile(formatStr, pth);
    return;

else
    switch numMode
        case 'num'
            [~, cIx]    = numFile(formatStr, pth);
            cIx         = cIx + 1;
    end

    [res, cIx]  = resFile;

    
    % Just to really make sure..
    while exist(res, 'file')
        warning('Same file name detected: %s\n', res);
                
        switch numMode
            case 'dateTime'
                [resPath resName] = fileparts(res);
                
                [res, cIx2] = nextFile([resName '_'], resPath, ext, ...
                                       'num', false, tStamp);

            case 'num'
                cIx = cIx + 1;
                [res, cIx] = resFile;
        end
    end
end


    function str = formatStr
        switch numMode
            case 'dateTime'
                str = sprintf('^%s[0-9]{8}T[0-9]{6}[.]%s$', rootName, ext);
            case 'num'
                str = sprintf('^%s[0-9]+[.]%s$', rootName, ext);
        end
    end

    function [n maxIx] = numFile(regFormat, pth)
        if nargin < 2, pth = '.'; end

        listing = dir(pth);
        names   = {listing.name};

        tf      = ~cellfun('isempty', regexpi(names, regFormat));
        n       = nnz(tf);

        if nargout >= 2
            if n > 0
                switch numMode
                    case 'dateTime'
                        names   = ...
                            cellfun(@(str) ...
                                str((length(rootName)+1):(end-length(ext)-1)), ...
                                names(tf), ...
                                                 'UniformOutput', false);
                        maxIx   = names{end};
                    case 'num'
                        ix      = ...
                            cellfun(@(str) ...
                                eval(str((length(rootName)+1):(end-length(ext)-1))), ...
                                names(tf));
                            
                        maxIx   = max(ix);
                end
            else
                maxIx = 0;
            end
        end
    end

    function [r rIx] = resFile
        switch numMode
            case 'dateTime'
                rIx = datestr(tStamp, 'yyyymmddTHHMMSS');
                r   = fullfile(pth, sprintf('%s%s.%s', rootName, ...
                                    rIx, ext));
            case 'num'
                rIx = cIx;
                r   = fullfile(pth, sprintf('%s%d.%s', rootName, cIx, ext));
        end
    end
end