function file = replace_ext(file, ext)
% file = replace_ext(file, ext)

if iscell(file)
    file = cellfun(@(f) bml.file.replace_ext(f, ext), ...
        file, ...
        'UniformOutput', false);
    return;
end

[pth, nam] = fileparts(file);
file = fullfile(pth, [nam, ext]);