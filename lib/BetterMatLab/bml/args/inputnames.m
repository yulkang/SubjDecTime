function nam = inputnames(ix)
% nam = inputnames
% nam = inputnames(ix)
% nam = inputnames('varargin')

if ~exist('ix', 'var')
    ix = 1:evalin('caller', 'nargin');
elseif ischar(ix)
    assert(strcmp(ix, 'varargin'), 'Unknown command: %s', ix);
    
    ix_end = evalin('caller', 'nargin');
    ix_n   = evalin('caller', 'length(varargin)');
    
    ix = (ix_end - ix_n + 1):ix_end;
end
nam = cell(1, length(ix));

for ii = 1:length(ix)
    nam{ii} = evalin('caller', sprintf('inputname(%d)', ix(ii)));
end
end