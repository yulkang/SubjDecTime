function h_out = waitbar_msg(msg, i_file, n_file)
% waitbar_msg(msg, i_file, n_file)
% waitbar_msg(msg, 'close')

persistent h

try
    if isequal(i_file, 'close')
        close(h.(msg));
        h_out = h.(msg);
        
        h = rmfield(h, msg);
    else
        waitbar(i_file/n_file, h.(msg), sprintf('%s %d/%d', msg, i_file, n_file));
        h_out = h.(msg);
    end
catch
    if ~isequal(i_file, 'close')
        h.(msg) = waitbar(i_file/n_file, sprintf('%s %d/%d', msg, i_file, n_file));
        h_out = h.(msg);
    end
end
end