function tf = onnow(t, on, off)
% tf = onnow(t, on, off)
%
% Whether t is between on and off. On should be nonempty and off can be empty.

if isempty(on)
    if ~isempty(off)
        tf = ~t >= off;
    else
        tf = false;
    end
elseif isscalar(on)
    tf = (t >= on) ...
        && (isempty(off) || ~(t >= off));
else
    if length(off) < length(on), off((end+1):length(on)) = inf; end
    tf = find((t >= on) & ~(t >= off));
    if isempty(tf), tf = 0; end
end