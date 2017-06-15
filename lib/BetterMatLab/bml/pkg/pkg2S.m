function S = pkg2S(d, varargin)
% Gives a structure with package structure, containing function handles.
opt = varargin2S(varargin, {
    'instantiate_class', false
    });

if nargin < 1
    st = dbstack;
    if isempty(st)
        d = pwd;
    else
        d = fileparts(st(1).file);
        if isempty(d)
            d = pwd;
        end
    end
elseif bml.pkg.ispkg(d)
    d = bml.pkg.pkg2dir(d);
end
try
    assert(exist(d, 'dir') ~= 0);
catch
    d = pkg2dir(d);
    assert(exist(d, 'dir') ~= 0);
end
fs = dir(d);
nf = length(fs);

S = struct;
for ii = 1:nf
    f = fs(ii);
    
    if f.isdir
        if f.name(1) == '+'
            S.(f.name(2:end)) = pkg2S(fullfile(d, f.name), varargin{:});
        end
    elseif f.name(1) ~= '.' % Ignore hidden files
        [~,nam,ext] = fileparts(f.name);
        if strcmp(ext, '.m')
            f_full = fullfile(d, f.name);
            cl = file2pkg(f_full);
            
            S.(nam) = str2func(cl);
            if opt.instantiate_class && exist(cl, 'class')
                try
                    % Try instantiating - may take a long time
                    S.(nam) = S.(nam)();
                catch
                end
            end
        end
    end
end