function [files, ress] = save_fig_tags(tags, base_caller, subdir, ext, comment, data_files, name_opt)
% [files, ress] = save_fig_tags([tags=(all), base_caller, subdir='', ext='.png', comment, data_files, name_opt])
%
% name format: subdir/tag.ext

if nargin < 1 || isempty(tags)
    h = hVec(findobj('Type', 'Figure'));
    tags = get(h, 'Tag');
end
if nargin < 2 || isempty(base_caller), base_caller = baseCaller; end
if nargin < 3, subdir = ''; end
if nargin < 4, ext = '.png'; end
if nargin < 5, comment = ''; end
if nargin < 6, data_files = {}; end
if nargin < 7, name_opt = {}; end

name_opt = varargin2C(name_opt, {
    'bCaller', base_caller
    });

n = length(tags);
files = cell(1,n);
ress  = cell(1,n);

for ii = 1:n
    tag = tags{ii};
    
    switch ext
        case '.eps'
            print_opt = {'-depsc2'};
        case '.png'
            print_opt = {'-dpng'};
        case '.fig'
            print_opt = {};
        otherwise
            error('Unsupported yet!');
    end
    
    [files{ii}, ~, ress{ii}] = logging.print(fig_tag(tag), ...
        [subdir, '/', tag ext], ...
        print_opt, ...
        {'comment', comment, 'header_info', {'data_files', data_files}, name_opt{:}});
%     [files{ii}, ress{ii}] = logging.name(subdir, tag, ext, comment, ...
%         data_files, name_opt{:});
    
%     switch ext
%         case '.eps'
%             print(fig_tag(tag), files{ii}, '-depsc2');
%     end
end