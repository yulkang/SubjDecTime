function pth = adapt_pth(pth)
% pth = adapt_pth(pth)
%
% Make the pth consistent, relative to the CODEBASE and MATLAB version.

if nargin < 1 || isempty(pth);
    pth = pathdef;
end

%% Chop at ':'
C       = pth2C(pth);

%% Find out user, MATLAB, and Applications paths
upth    = cellfun(@(c) ~isempty(c), strfind(C, '/Code/'));
mpth    = cellfun(@(c) ~isempty(c), strfind(C, '/MATLAB'));
apth    = cellfun(@(c) ~isempty(c), strfind(C, '/Applications/'));

%% Update user code paths (those with /Code/)
if any(upth)
    C(upth) = adapt_CODEBASE(C(upth));
end

%% Remove MATLAB or Applications related paths
% C       = C((~mpth) & (~apth));

%% Return path string
pth     = sprintf('%s:', C{:});