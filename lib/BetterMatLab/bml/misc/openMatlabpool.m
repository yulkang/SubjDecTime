function nOpenPool = openMatlabpool(poolName, maxWorker, onlyIfNotOpenYet)
% nOpenPool = openMatlabpool(poolName, maxWorker, onlyIfNotOpenYet)
%
% poolName, maxWorker: if unspecified or empty, uses default.
% onlyIfNotOpenYet   : defaults to true.

if ~exist('poolName', 'var'), poolName = ''; end % use default
if ~exist('maxWorker', 'var'), maxWorker = []; end % use default
if ~exist('onlyIfNotOpenYet', 'var'), onlyIfNotOpenYet = true; end

nOpenPool = matlabpool('size');

if onlyIfNotOpenYet && (nOpenPool>0)
    warning('Matlabpool is already open!');
    return;
else
    if isempty(poolName) && isempty(maxWorker)
        matlabpool open % use default
    elseif isempty(poolName)
        matlabpool('open', sprintf('%d', maxWorker));
    elseif isempty(maxWorker)
        matlabpool('open', poolName);
    else
        matlabpool('open', poolName, sprintf('%d', maxWorker));
    end
end
