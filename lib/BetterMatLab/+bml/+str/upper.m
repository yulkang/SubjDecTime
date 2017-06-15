function s = upper(s, opt)
% s = upper(s, opt = 'all'|'sentence')
if ~exist('opt', 'var')
    opt = 'all';
end

if iscell(s)
    s = cellfun(@(ss) bml.str.upper(ss, opt), s, 'UniformOutput', false);
    return;
end
switch opt
    case 'all'
        s = upper(s);
    case 'word'
        error('Not implemented yet!');
    case 'sentence'
        s = [upper(s(1)), s(2:end)];
end