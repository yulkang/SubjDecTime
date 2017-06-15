function varargout = combine_into_pdf(varargin)
% COMBINE_INTO_PDF  Combine many .eps or .pdf files into one .pdf file.
%
% [status, result, comm] = combine_into_pdf(filt, file_out, varargout)
[varargout{1:nargout}] = combine_into_pdf(varargin{:});