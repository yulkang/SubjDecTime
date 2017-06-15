function [res, callStack, ix, res_name_only, readable_full, readable_name] = baseCaller(exclude_names, varargin)
% [res, callStack, ix, res_name_only, readable_full, readable_name] = baseCaller([exclude_names], ['opt1', opt1, ...])
% exclude_names : files/functions not to consider as a baseCaller.
%
% OPTIONS:
% -----------------------
% 'base_fallback', 'base', ... % 'pwd', 'guess', 'base' ('guess': guess from current editor file)
%
% See also: file, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

if ~exist('exclude_names', 'var'), exclude_names = {}; end

S = varargin2S(varargin, { ...
    'base_fallback', 'base', ... % 'pwd', 'guess', 'base' ('guess': guess from current editor file)
    });

S.base_fallback = validatestring(S.base_fallback, {'pwd', 'guess', 'base'});

if ~exist('guess_cell', 'var'),    guess_cell = false; end

[callStack, ix] = dbstack('-completenames');

exclude_full = cellfun(@which, [exclude_names, {'baseCaller'}], 'UniformOutput', false);

if all(strcmps(exclude_full, {callStack.file}))
    switch S.base_fallback
        case 'base'
            res = 'base';    
            res_name_only = 'base';
            
            readable_full = res;
            readable_name = res_name_only;
                        
        case 'guess'
            active_file = matlab.desktop.editor.getActiveFilename;
            
            if ~isempty(active_file)
                res = active_file;
                readable_full = ['base_or_' active_file];

                res_name_only = file2pkg(active_file);
                readable_name = ['base_or_' res_name_only];
            else
                res = pwd;
                res_name_only = '';

                readable_full = res;
                readable_name = res_name_only;
            end
            
        case 'pwd'
            res = pwd;
            res_name_only = '';
            
            readable_full = res;
            readable_name = res_name_only;
    end
else
    res = callStack(end).file;
    res_name_only = file2pkg(res);
    
    readable_full = res;
    readable_name = res_name_only;
end