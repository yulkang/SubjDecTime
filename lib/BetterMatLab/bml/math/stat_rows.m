function varargout = stat_rows(f, M, f_incl)
% [out1, out2, ...] = stat_rows(f, M, f_incl=@isfinite)
%
% Current behavior: All outputs are from f.
% Past behavior: When nargout >= 2, the last output is n, the number of eligible outputs.

if nargin < 3, f_incl = @isfinite; end

nc = size(M, 2);

incl = f_incl(M);
n    = sum(incl, 1);

nout = nargout; % max(nargout - 1, 1);
varargout(1:nout) = {nan(1, nc)};
% varargout{nout}   = n;

for ii = 1:nc
    [cout{1:nout}] = f(M(incl(:,ii), ii));
    
    for jj = 1:nout
        if isempty(cout{jj}), cout{jj} = nan; end
        varargout{jj}(ii) = cout{jj};
    end
end