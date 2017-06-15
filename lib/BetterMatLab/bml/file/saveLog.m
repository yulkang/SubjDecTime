function file = saveLog(varargin)
% saveLog  Save with the basecaller name, date, and time attached to file name.
%
% file = saveLog(fileArg, ...);
%
%   fileArg: See parseFileArg.
% 
% Also produces prompt for logging.
%
% Example: If you make analysis.m as:
%
%   saveLog testPrintLog/randPlot
%   
% and run it:
%
% >> analysis
% Saved "randPlot" with options:     '-depsc2'
% to testPrintLog/analysis_randPlot_20130224T094601 ...
%
% See also: PRINT, BASECALLER, DATESTR

% Parse path and name.
iFile           = 1;
fileArg         = varargin{iFile};
[file, fShort]  = parseFileArg(fileArg);
varargin{iFile} = file;
                    
% Save.
if length(varargin)>1
    expr = [sprintf('save(''%s''', file), ...
            sprintf(',''%s''', varargin{2:end}), ...
            sprintf(')')];
    evalin('caller', expr);
else
    evalin('caller', sprintf('save(''%s'')', file));
end

% Prompt.
fprintf('Saved "%s" with options: ', fShort); disp(varargin((iFile+1):end));
fprintf('to: %s\n\n', file);
end