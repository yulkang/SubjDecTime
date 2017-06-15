
C = {};
S = struct;

tic;
for ii = 1:1000
    switch class(S)
        case 'cell'
            tf = false;
        case 'struct'
            tf = true;
    end
end
toc;

tic;
for ii = 1:1000
    if iscell(S)
        tf = false;
    elseif isstruct(S)
        tf = true;
    end
end
toc;

