function [files, ress, baks] = save_figs(tags, base_caller, prefix, ext, comment, data_files, name_opt)
% [files, ress, baks] = save_fig_tags([tags=(all), base_caller, prefix='', ext='.png', comment, data_files, name_opt])
%
% tags: a cell array of tags or an array of figure handles.
%       Give empty to print all.
%
% name format: PRFIXtagEXT
% - Give prefix/ to specify subdirectories.
% - EXT can contain postfixes. Give POSTFIX.ext.

if nargin < 1 || isempty(tags)
    h = hVec(findobj('Type', 'Figure'));
    tags = get(h, 'Tag');
end
n = numel(tags);

% Convert h into tags
if ~iscell(tags)
    h = tags;
    tags = get(h, 'Tag');
end

if nargin < 2 || isempty(base_caller), base_caller = baseCaller; end
if nargin < 3, prefix = ''; end
if nargin < 4, ext = '.png'; end
if nargin < 5, comment = ''; end
if nargin < 6, data_files = {}; end
if nargin < 7, name_opt = {}; end

% Parse ext into postfix and ext
ix_ext = find(ext == '.', 1, 'last');
if ~isempty(ix_ext)
    postfix = ext(1:(ix_ext-1));
    ext     = ext(ix_ext:end);
else
    postfix = '';
    ext     = ['.', ext];
end

name_opt = varargin2C(name_opt, {
    'bCaller', base_caller
    });

files = cell(1,n);
ress  = cell(1,n);
baks  = cell(1,n);

for ii = 1:n
    tag = tags{ii};
    file = [str_con(prefix, tag, postfix), ext];
    
    if strcmp(ext, '.fig')
        [files{ii}, ~, ress{ii}] = Localog.archive(file, 'comment', comment, ...
            'header_info', {'data_files', data_files}, name_opt{:});
        
        savefig(fig_tag(tag), files{ii});

    else
        switch ext
            case '.eps'
                print_opt = {'-depsc2'};
            case '.png'
                print_opt = {'-dpng'};
            otherwise
                error('Unsupported yet!');
        end

        [files{ii}, baks{ii}, ress{ii}] = Localog.print(fig_tag(tag), ...
            file, ...
            print_opt, ...
            {'comment', comment, 'header_info', {'data_files', data_files}, name_opt{:}});
    %     [files{ii}, ress{ii}] = Localog.name(subdir, tag, ext, comment, ...
    %         data_files, name_opt{:});

    %     switch ext
    %         case '.eps'
    %             print(fig_tag(tag), files{ii}, '-depsc2');
    %     end
    end
end