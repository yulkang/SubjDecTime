function [res, bak, S, D] = print(h, file, print_args, archive_opt)
% [res, bak, S, D] = print(h, file, print_args, archive_opt)
%
% archive_opt : Can be {S} with S from another call to logging.archive
%
% See also print, logging.archive

if isempty(h), h = gcf; end
if nargin < 3, print_args = {}; end
if nargin < 4, archive_opt = {}; end

%% For docked mode, PaperPositionMode should be manual.
if ~strcmpi(get(h, 'WindowStyle'), 'Docked')
    set(h, 'PaperPositionMode', 'auto');
end

%% Get file name
[res, bak, S, D] = logging.archive(file, archive_opt{:});

%% Print
[~,~,ext] = fileparts(res);

if strcmp(ext, '.fig')
    savefig(h, res, print_args{:});
else
    if isempty(print_args)
        switch ext
            case '.eps'
                print_args = {'-depsc2'};
            case '.png'
                print_args = {'-dpng'};
            case '.tif'
                print_args = {'-dtiff'};
            otherwise
                warning('Extension %s is unrecognized, and printing format is not provided!', ext);
        end
    end
    print(h, res, print_args{:});
end

%% Backup saved file
copyfile2(res, bak);
