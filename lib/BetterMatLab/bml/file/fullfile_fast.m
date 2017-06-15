function f = fullfile_fast(varargin)
%FULLFILE_FAST  Efficiently build full filename from parts.

persistent fs bIsPC

if isempty(fs), fs = filesep; end
if isempty(bIsPC), bIsPC = ispc; end

f = sprintf('%s/', varargin{:});
f = f(1:(end-1));

% Be robust to / or \ on PC
if bIsPC
   f = strrep(f,'/','\');
   f = strrep(f,'\\','\');
else
   f = strrep(f,'//','/');
end