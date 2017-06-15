function axis_lim = axis_margin(h_ax, varargin)
% axis_lim = axis_margin(h_ax, varargin)
%
% OPTIONS
% -------
% 'axis', 'x'
% 'type', 'symmetric' % symmetric | pos | neg | free
% 'margin', 0.05
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'axis', 'x'
    'type', 'symmetric' % symmetric | pos | neg | free
    'margin', 0.05
    });
if nargin < 1
    h_ax = gca;
end
assert(strcmpi(get(h_ax, 'Type'), 'axes'));
assert(isequal(S.axis, 'x'));
assert(ismember(S.type, {'symmetric'}));

axis_dat = [upper(S.axis), 'Data'];
all_val = [];
children = get(h_ax, 'Children');
for ii = 1:numel(children)
    try
        all_val = [all_val;
            vVec(get(children(ii), axis_dat))]; %#ok<AGROW>
    catch
    end
end

switch S.type
    case 'symmetric'
        assert(isscalar(S.margin));
        
        if isempty(all_val)
            axis_lim = [-eps, eps];
        else
            axis_lim = max(abs(all_val));
            axis_lim = [-axis_lim, axis_lim] .* (1 + S.margin);
        end
        if axis_lim(1) == axis_lim(2)
            axis_lim(1) = axis_lim(1) - eps;
            axis_lim(2) = axis_lim(2) + eps;
        end
        
    otherwise
        error('type=%s not supported yet!\n', S.type);
end

switch S.axis
    case 'x'
        xlim(h_ax, axis_lim);
    case 'y'
        ylim(h_ax, axis_lim);
end