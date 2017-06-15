function h_out = plot_tag(tag, x_in, y_in, varargin)
% PLOT_TAG  update X & YData after first plotting.
%
% h_out = plot_tag(tag, x_in, y_in, varargin)

persistent h x y

tag = safe_name(tag);

if ischar(x_in) && strcmp(x_in, 'clear')
    h = rmfield(h, tag);
    x = rmfield(x, tag);
    y = rmfield(y, tag);
    return;
end    

to_plot_anew = ~isfield(h, tag) ...
    || ~isequal(size(x.(tag)), size(x_in)) ...
    || ~isequal(size(y.(tag)), size(y_in));

if to_plot_anew
    x.(tag) = x_in;
    y.(tag) = y_in;
    h.(tag) = plot(x_in, y_in, varargin{:}, 'Tag', tag);
else
    try
        if isscalar(h.(tag))
            set(h.(tag), 'XData', x_in, 'YData', y_in);
        else
            arrayfun(@(ii) set(h.(tag)(ii), ...
                'XData', x_in(:,ii), 'YData', y_in(:,ii)), 1:length(h.(tag)));
        end
        
        x.(tag) = x_in;
        y.(tag) = y_in;
    catch
        plot_tag(tag, 'clear');
        plot_tag(tag, x_in, y_in, varargin{:});
    end
    
%     ix = (x.(tag) ~= x_in) | y.(tag) ~= y_in;
%     ix = ix(1:(end-1)) | ix(2:end);
%     
%     for ii = find(ix)
%         set(h.(tag)(ii), 'XData', x_in(ii+[0 1]), 'YData', y_in(ii+[0 1]));
%     end    
end

h_out = h.(tag);