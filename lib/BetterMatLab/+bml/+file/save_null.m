function save_null(file) % , varargin)
% Create a .mat file of zero size.
%
% See also: is_null_file

% % TODO: perhaps implement options
% tf_existing = exist(file, 'file');
% if tf_existing && ~strcmp(S.if_existing, 'overwrite')
%     d = dir(file);
%     assert(isscalar(d));
%     tf_empty = d.bytes == 0;
%     if ~tf_empty
%         error('Non-empty file %s exists!', file);
%     end
% end

[pth,~,ext] = fileparts(file);
if isempty(ext)
    file = [file, '.mat'];
end

mkdir2(pth);
f = fopen(file, 'w');
fclose(f);