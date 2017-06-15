function [result, status, comm] = combine_into_pdf(filt, file_out, varargin)
% COMBINE_INTO_PDF  Combine many .eps or .pdf files into one .pdf file.
%
% [status, result, comm] = combine_into_pdf(filt, file_out, varargout)

S = varargin2S(varargin, { ...
    'out_dir', '' ...
    });

% Goto filter folder, so that file_out is created in the same folder,
% unless out_dir is specified separately.
[filt_dir, filt_nam, filt_ext] = fileparts(filt);

if ~isempty(filt_dir)
    pd = cd(filt_dir);
else
    pd = cd;
end

% Execute command
comm = sprintf('gs -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile=%s -dBATCH %s', ...
    fullfile(S.out_dir, file_out), [filt_nam, filt_ext]);

[status, result] = system(comm);
if status ~= 0,
    [status, result] = system(['/usr/local/bin/' comm]);
end

% Come back to previous folder.
cd(pd);