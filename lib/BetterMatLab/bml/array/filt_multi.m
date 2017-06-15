function varargout = filt_multi(filt, varargin)
% [A,B,..] = filt_multi(ix_or_fun, A,B,...);
%
% filt
% : ix or function handle.
%   If function handle, filt = filt(varargin{1}).
%
% A = A(ix);
% B = B(ix);
% ...

n = length(varargin);
varargout = cell(1,n);

if isa(filt, 'function_handle')
    filt = filt(varargin{1});
    
    if islogical(filt)
        n_filt = nnz(filt);
    else
        n_filt = length(filt);
    end
end

for ii = 1:n
    if isvector(varargin{ii})
        varargout{ii} = varargin{ii}(filt);
        
    elseif ismatrix(varargin{ii})
        varargout{ii} = varargin{ii}(filt,:);
        
    else
        siz = size(varargin{ii});
        siz(1) = n_filt;
        varargout{ii} = reshape(varargin{ii}(filt,:), siz);
    end
end