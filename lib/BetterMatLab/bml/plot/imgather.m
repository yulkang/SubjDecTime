function [h_ax, F, h_all] = imgather(f, args, varargin)
% Gather images files and/or axes into a figure.
%
% h = imgather(f, args, varargin)
%
% f     : A formatstring, a cell matrix of image file names, or
%         an array of handles of an axes or a single-axes figure.
% args  : Arguments to feed format. Ignored if f is a cell array of file names.
%         If a row or column vector, will be repeated to match the matrix's size.
%
% OPTIONS
% -------
% 'xsiz',     1       % How to scale x. Either scalar or a vector.
% 'ysiz',     1       % How to scale y. Either scalar or a vector.
% 'xgap',     0.05    % Gap in proportion of the figure.
% 'ygap',     0.05    % Gap in proportion of the figure.
% 'title'     ''      % Global title.
% 'rowtitle'  ''      % Row title.
% 'coltitle'  ''      % Colummn title.
% 'opt_title', {}
% 'opt_rowtitle', {}
% 'opt_coltitle', {}
% 'fig_mode', false
% 'joinaxes', true
% 'opt_joinaxes', {}
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'xsiz',     1       % How to scale x. Either scalar or a vector.
    'ysiz',     1       % How to scale y. Either scalar or a vector.
    'xgap',     0.05    % Gap in proportion of the figure.
    'ygap',     0.05    % Gap in proportion of the figure.
    'title'     ''      % Global title.
    'rowtitle'  ''      % Row title.
    'coltitle'  ''      % Colummn title.
    'opt_title', {}
    'opt_rowtitle', {}
    'opt_coltitle', {}
    'fig_mode', true % When importing bitmap, hide axes.
    'joinaxes', false % true
    'opt_joinaxes', {}
    });

if nargin < 2, args = {}; end
S.opt_joinaxes = varargin2C(S.opt_joinaxes, {
    'sameAxes', 'off'
    'linkAxes', 'off'
    });

h_all = struct;

%% Parse f into F (file names or handles)
if ischar(f) || iscell(f)
    if ischar(f) % format
        [args{:}] = rep2match(args{:});
        RC = size(args{1});
        F = reshape(csprintf(f, args{:}), RC);

    elseif iscell(f) % file names
        F  = f; 
        RC = size(f);
    end
    
    newfig = gcf;
    
    [~,~,ext] = fileparts(F{1});
    switch ext
        case '.fig'
            h = ghandles(RC);
            
            for r = 1:RC(1)
                for c = 1:RC(2)
                    loadedfig  = openfig(F{r,c});
                    loadedaxes = findobj(loadedfig, 'Type', 'Axes');
                    
                    figure(newfig);
                    h(r,c) = subplotRC(RC(1), RC(2), r, c, 'replace_with', loadedaxes);
                    delete(loadedfig);
                end
            end
            
            % All sizes are treated as equal
            xsiz = ones(1, RC(2));
            ysiz = ones(1, RC(1));
            
        otherwise
            S.fig_mode = false;
            
            xsiz = zeros(1, RC(2));
            ysiz = zeros(1, RC(1));

            h = subplotRCs(RC(1), RC(2));

            for r = 1:RC(1)
                for c = 1:RC(2)
                    if r == 1 || c == 1
                        info = imfinfo(F{r,c});
                        if r == 1
                            xsiz(c) = info.Width;
                        end
                        if c == 1
                            ysiz(r) = info.Height;
                        end
                    end

                    im = imread(F{r,c});

                    subplotRC(RC(1), RC(2), r, c);
                    image(im);
                end
            end    
    end
    
else ishandle(f)
    RC = size(f);
    
    xsiz = zeros(1, RC(2));
    ysiz = zeros(1, RC(1));
    
    h = subplotRCs(RC(1), RC(2));
    h0 = h;
    f0 = f;
    
    for r = 1:RC(1)
        for c = 1:RC(2)
            if strcmpi(get(f0(r,c), 'Type'), 'figure')
                try
                    f(r,c) = get(f0(r,c), 'Children');
                catch err
                    warning(err_msg(err));
                    error('Error during copy - give an axes, or a figure with a single child axes!');
                end
            end
                
            if r == 1 || c == 1
                csiz = get(f0(r,c), 'Position');
                if r == 1 && isscalar(S.xsiz)
                    xsiz(c) = csiz(1);
                end
                if c == 1 && isscalar(S.ysiz)
                    ysiz(r) = csiz(2);
                end
            end
 
            cpos   = get(h(r,c), 'Position');
            h(r,c) = copyobj(f(r,c), get(h(r,c), 'Parent'));
            delete(h0(r,c));
            set(h(r,c), 'Position', cpos);
        end
    end    
    
    F = f;
end

%% Impose sizes
xsiz = bsxfun(@times, xsiz, S.xsiz);
ysiz = bsxfun(@times, ysiz, S.ysiz);
xgap = rep2fit(S.xgap(:)', [1, RC(2)-1]);
ygap = rep2fit(S.ygap(:)', [1, RC(1)-1]);

if S.joinaxes
    joinaxes(h, 'xsiz', xsiz, 'ysiz', ysiz, 'xgap', xgap, 'ygap', ygap, S.opt_joinaxes{:});
end

% if ~S.fig_mode % If loaded figure, leave axes untouched. Otherwise, leave images alone.
%     for ii = 1:numel(h)
%         axis(h(ii), 'off');
%     end
% end

if ~isempty(S.title)
    h_all.title = gltitle(h, 'all', S.title, S.opt_title{:});
end
if ~isempty(S.rowtitle)
    h_all.rowtitle = gltitle(h, 'row', S.rowtitle, S.opt_rowtitle{:});
end
if ~isempty(S.coltitle)
    h_all.coltitle = gltitle(h, 'col', S.coltitle, S.opt_coltitle{:});
end
   
%% Output
if nargout > 0
    h_ax = h;
end