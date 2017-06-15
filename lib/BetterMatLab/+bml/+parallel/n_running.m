function n = n_running(job)
if isempty(job)
    n = 0;
else
    n = nnz(~strcmp({job.State}, 'finished'));
end