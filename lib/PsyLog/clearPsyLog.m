try    Scr.delTree; catch; end
try    delete(Mouse); catch; end
try    delete(Cursor); catch; end

varNamesToClear = who;

for ii = 1:length(varNamesToClear)
    cVar = varNamesToClear{ii};
    
    if ~strcmp(cVar, 'cVar') && ~strcmp(cVar, 'ii') ...
     && ~strcmp(cVar, 'cSup') && ~strcmp(cVar, 'cClassToClear') ...
     && isempty(strfind(cVar, 'ptb'))
         cClass = class(cVar);
         cSup = superclasses(cClass);
         
         for cClassToClear = [{cClass} cSup]
             if ~strcmp(cClassToClear{1}, 'handle')
                 clear(cClassToClear{1});
             end
         end
         clear(cVar);
    end
end

clear -regexp ^[^(ptb_)]
dbstop if error;
