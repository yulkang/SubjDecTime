% dbqt - Ask to save workspace before dbquit.
if inputYN_def('Save workspace to ws in base before dbquit', true)
    ws2base;
end
dbquit;