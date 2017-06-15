function [bCaller, pth_code, nam] = base_caller(bCaller, excl_names)
if ~exist('excl_names', 'var'), excl_names = {}; end

% Get baseCaller and determine pth_code from it.
if isempty(bCaller)
    bCaller = baseCaller([excl_names, {mfilename('fullpath')}], 'base_fallback', 'pwd');
    
    if exist(bCaller, 'dir')
        warning(...
            ['BaseCaller not found. Maybe you''re using cell mode.\n' ...
             'Using current directory as the basecaller location: %s\n', ...
             'Using ''base'' as the basecaller name.\n' ...
             'To easily locate the data and keep log''s integrity,\n' ...
             'generate important data by directly running a script or a function!\n'], ...
             bCaller);
        
        pth_code = bCaller;
        nam = 'base';
    else
        [pth_code, nam] = fileparts(bCaller);
    end    
else
    which_bCaller = which(bCaller);
    
    if ~isempty(which_bCaller)
        [pth_code, nam] = fileparts(which_bCaller);
    elseif exist(bCaller, 'dir')
        pth_code = S.bCaller;
        nam = 'base';
    else
        [pth_code, nam] = fileparts(bCaller);
    end
end
pth_code = add_filesep(pth_code);
