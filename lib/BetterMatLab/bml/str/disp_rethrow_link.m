function s_out = disp_rethrow_link(err_var)
% s_out = disp_rethrow_link(err_var='err')

if nargin == 0, err_var = 'err'; end

s = sprintf('To rethrow the error, click %s\n', ...
    cmd2link(sprintf('rethrow(%s)', err_var)));

if nargout > 0
    s_out = s;
else
    disp(s);
end
end