function h_out = errorbar_tag(tag, x_in, y_in, l_in, u_in, varargin)
% ERRORBAR_TAG  update X, Y, EData after first plotting.

persistent h x y l u

tag = safe_name(tag);

if ~exist('x_in', 'var')
    if isstruct(h) && isfield(h, tag)
        h_out = h.(tag);
        return;
    else
        error('No %s exists!', tag);
    end
    
elseif ischar(x_in) && strcmp(x_in, 'clear')
    h = rmfield(h, tag);
    x = rmfield(x, tag);
    y = rmfield(y, tag);
    l = rmfield(l, tag);
    u = rmfield(u, tag);
    return;
end    

if ~exist('u_in', 'var')
    u_in = l_in; 
    
elseif ~isnumeric(u_in)
    varargin = [{u_in}, varargin];
    u_in = l_in; 
end

if isvector(x_in) && size(x_in, 2) ~= 1, x_in = x_in'; end
if isvector(y_in) && size(y_in, 2) ~= 1, y_in = y_in'; end
if isvector(l_in) && size(l_in, 2) ~= 1, l_in = l_in'; end
if isvector(u_in) && size(u_in, 2) ~= 1, u_in = u_in'; end

to_plot_anew = ~isfield(h, tag) ...
    || ~isequal(size(x.(tag)), size(x_in)) ...
    || ~isequal(size(y.(tag)), size(y_in)) ...
    || ~isequal(size(l.(tag)), size(l_in)) ...
    || ~isequal(size(u.(tag)), size(u_in));

if to_plot_anew
    x.(tag) = x_in;
    y.(tag) = y_in;
    l.(tag) = l_in;
    u.(tag) = u_in;
    h.(tag) = handle(errorbar(x_in, y_in, u_in, varargin{:}, 'Tag', tag));
else
    try
        h.(tag).XData = x_in;
        h.(tag).YData = y_in;
        h.(tag).LData = l_in;
        h.(tag).UData = u_in;

    %     ix = (x.(tag) ~= x_in) | y.(tag) ~= y_in;
    %     ix = ix(1:(end-1)) | ix(2:end);
    %     
    %     for ii = find(ix)
    %         set(h.(tag)(ii), 'XData', x_in(ii+[0 1]), 'YData', y_in(ii+[0 1]));
    %     end

        x.(tag) = x_in;
        y.(tag) = y_in;
        l.(tag) = l_in;
        u.(tag) = u_in;
    catch
        errorbar_tag(tag, 'clear');
        errorbar_tag(tag, x_in, y_in, l_in, u_in, varargin{:});
    end
end

h_out = h.(tag);