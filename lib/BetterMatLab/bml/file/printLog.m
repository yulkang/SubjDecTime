function printLog(varargin)
% printLog  Print with the basecaller name, date, and time attached to file name.
%
% printLog(fileArg, ...);
% printLog(figureHandle, fileArg, ...);
%
%   fileArg: See parseFileArg.
%
% Also produces prompt for logging.
%
% Example: If you make analysis.m as:
%
%   plot(rand(1,100)); printLog testPrintLog/randPlot -depsc2
%   
% and run it:
%
% >> analysis
% Printed "randPlot" with options:     '-depsc2'
% to testPrintLog/analysis_randPlot_20130224T094601 ...
%
% See also: PRINT, PARSEFILEARG

% Find out file name.
if ishandle(varargin{1})
    iFile = 2;
else
    iFile = 1;
end

% Parse path and name.
fileArg         = varargin{iFile};
[file, fShort]  = parseFileArg(fileArg);
varargin{iFile} = file;
                    
% Print.
print(varargin{:});

% Prompt.
fprintf('Printed "%s" with options: ', fShort); disp(varargin((iFile+1):end));
fprintf('to: %s\n\n', file);
end