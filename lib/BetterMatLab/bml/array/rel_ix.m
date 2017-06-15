function num_ix = rel_ix(num_ix, n)
    % num_ix = rel_ix(ix, n)
    %
    % if ix >  0, return the same.
    % if ix <= 0, return n+ix. 
    % 
    % When there are n entries, 0 gives the last entry, -1 gives the
    % penultimate, and so on.
    num_ix(num_ix<=0) = n + num_ix;
end