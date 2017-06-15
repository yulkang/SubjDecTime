function try_close(Ser, varargin)
% Try closing the port

st = GetSecs;
try
    fclose(Ser);
catch
end

serials.wait_close(Ser);