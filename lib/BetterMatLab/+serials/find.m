function s = find(typ, ix, among_available)
% Serial ports whose name starts with TYP.
%
% s = find(typ, ix)
%
% typ: Defaults to 'usb'.
% ix : Defaults to 1.
% among_available: Defaults to false.

ser_list = instrhwinfo('serial');

if ~exist('typ', 'var') || isempty(typ), typ = 'usb'; end
if ~exist('ix',  'var') || isempty(ix),  ix  = 1; end
if ~exist('among_available',  'var') || isempty(among_available),  among_available  = false; end

switch typ
    case 'usb'
        if ismac
            str = '/dev/tty.usb';
        end
    otherwise
        str = typ;
end

if among_available
    prop = 'AvailableSerialPorts';
else
    prop = 'SerialPorts';
end

ss = ser_list.(prop)(...
        strncmp(str, ser_list.(prop), length(str)));

if isempty(ss)
    s = {};
elseif isscalar(ix) || (nnz(ix) == 1) 
    s = ss{ix};
else
    s = ss(ix);
end