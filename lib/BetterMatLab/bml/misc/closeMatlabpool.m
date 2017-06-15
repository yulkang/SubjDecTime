function closeMatlabpool
% CLOSEMATLABPOOL   Closes matlabpool if open, without ensuing error.
%
% See also OPENMATLABPOOL, MATLABPOOL

if matlabpool('size')>0
    matlabpool close; 
else
    warning('No matlabpool is open!');
end