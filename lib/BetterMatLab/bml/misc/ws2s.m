function S = ws2s(varList, toExcl, verbose)
% WS2S: Copies variables in the current workspace to a struct.
%
% S = ws2s(varList, toExcl, verbose=false)
%
% varList       : Cell array of variable names to either exclude or include. 
% toExcl        : If true (default), include all variables except varList.
%                 If false, include only variables on varList.
% verbose       : If true, display prompts.
%
% S             : Struct with the variables as fields.
%
% See also: unpackStruct, ws2base
%
% 2013 (c) Yul Kang. hk2699 at columbia dot edu.

if ~exist('verbose', 'var') || isempty(verbose), verbose = false; end
if ~exist('toExcl', 'var')  || isempty(toExcl)
    toExcl = true;
end
if ~exist('varList', 'var')
    varList = {};
end
if toExcl
    varList = setdiff(evalin('caller', 'who;'), varList);
end
if verbose
    fprintf('Current workspace:\n');
    evalin('caller', 'whos');

    fprintf('varList:');
    fprintf(' %s', varList{:});
    fprintf('\n');
    fprintf('Copying %d variables to struct ws\n', length(varList)); 
end
succ = false(1,length(varList));
for iVar = 1:length(varList)
    try
        S.(varList{iVar}) = evalin('caller', varList{iVar});
        succ(iVar) = true;
    catch
        fprintf('Error copying %s', varList{iVar});
        disp(lasterr);
    end
end
