function res = link4copy(src, msg)
res = cmd2link(sprintf('clipboard(''copy'', ''%s'')', src), msg);