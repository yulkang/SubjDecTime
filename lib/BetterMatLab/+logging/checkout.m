function D = checkout(br)
% Checkout a branch after committing current changes, if any.
%
% D = checkout(br)

D = logging.commit_if_changed;

out = Ext.git(['checkout ' br]);
disp(out);