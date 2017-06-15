function tf = isfetched(jobs)
% tf = isfetched(jobs)

tf = arrayfun(@(v) v.Read, jobs);