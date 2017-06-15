function ws2base(sName, varList, toExcl)
% WS2BASE: Copies variables in the current workspace to the base workspace.
%
% ws2base(sName, varList, toExcl)
%
% sName         : If specified as nonempty string other than '_',
%                 variables are copied into the struct names sName
%                 in the base workspace.
%                 SNAME defaults to ['ws_' caller_name].
%                 Use UNPACKSTRUCT to make its fields variables.
%
% varList       : Cell array of variable names.
% toExcl        : If true (default), include all variables except varList.
%                 If false, include only variables on varList.
%
% See also: unpackStruct, ws2s
%
% 2013 (c) Yul Kang. hk2699 at columbia dot edu.

if ~exist('sName', 'var') || isempty(sName)
    sName = 'ws';
    
%     [dbSt, dbIx] = dbstack;
%     
% %     for ii = 1:length(dbSt)
% %         disp(dbSt(ii));
% %     end
%     
%     if dbIx<length(dbSt)
%         callerName = strrep(dbSt(dbIx+1).name, '/', '_');
%     else
%         callerName = 'base';
%     end
%     
%     sName = ['ws_' callerName];
end
if ~exist('toExcl', 'var')  || isempty(toExcl)
    toExcl = true;
end
if ~exist('varList', 'var') || (isempty(varList) && toExcl)
    if ~exist('varList', 'var')
        varList = {};
    end
    varList = setdiff(evalin('caller', 'who'), varList);
end

fprintf('CallStack:\n');
cs = dbstack;
fprintf('  %s\n', cs.name);
fprintf('\n');
clear cs;

fprintf('Current workspace:\n');
evalin('caller', 'whos')

if strcmp(sName, '_')
    fprintf('Copying %d variables to base:\n', length(varList));
else
    fprintf('Copying %d variables to base, into struct %s:\n', length(varList), sName);
end
for iVar = 1:length(varList)
    try
        if sName == '_'
            assignin('base', varList{iVar}, evalin('caller', varList{iVar}));
        else
            S.(varList{iVar}) = evalin('caller', varList{iVar});
        end
    catch
        disp(lasterr);
        fprintf('Failed copying %20s to base workspace.\n', varList{iVar});
    end
end

if ~strcmp(sName, '_')
    assignin('base', sName, S);
    fprintf('\nStruct %s containing %d fields copied to base workspace.\n', ...
        sName, length(fieldnames(S)));
end