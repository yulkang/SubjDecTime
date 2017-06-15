function Ser = arduino(port, varargin)
% Get port with settings for arduino.
%
% Ser = arduino(port, varargin)
%
% Terminator, DataBits, StopBits, and Parity are set.

Ser = serial(port, ...
    'Terminator', 'LF', 'DataBits', 8, 'StopBits', 1, 'Parity', 'none', ...
    varargin{:});
