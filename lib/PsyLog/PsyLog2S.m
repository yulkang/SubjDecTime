function S = PsyLog2S(o, varargin)
% S = PsyLog2S(o, varargin)
%
% OPTIONS:
%     'obj',      {}
%     'excl_obj', true
%     'field',    {}
%     'excl_field', true
%     'prefix',   ''
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

opt = varargin2S(varargin, {
    'obj',      {}
    'excl_obj', true
    'field',    {}
    'excl_field', true
    'prefix',   ''
    'prefix_v', ''
    });

if isstruct(o)
    if opt.excl_obj
        objs = setdiff(fieldnames(o), opt.obj);
    else
        objs = fieldnames(o);
    end
    
    prefix = opt.prefix;
    S = struct;
    
    for obj = objs(:)'
        if ~isa(o.(obj{1}), 'PsyLogs'), continue; end
        opt.prefix = str_con(prefix, obj{1});
        S = copyFields(S, PsyLog2S(o.(obj{1}), opt));
     end
elseif isa(o, 'PsyLogs')
    if opt.excl_field
        fs = setdiff(o.names_, opt.field);
    else
        fs = opt.field;
    end
    
    S = struct;
    for f = fs(:)'
        try
            switch o.src_.(f{1})
                case {'markFirst', 'markLast'}
                    rs = o.relSec(f{1});
                    if isempty(rs), rs = nan; end
                    S.(str_con('t', opt.prefix, f{1}))  = rs;
                case 'mark'
                    S.(str_con('t', opt.prefix, f{1}))  = {o.relSec(f{1})};
                otherwise                
                    S.(str_con(opt.prefix_v, opt.prefix, f{1}))       = {o.v(f{1})};
                    S.(str_con('t', opt.prefix, f{1}))  = {o.relSec(f{1})};
            end
        catch err
            fprintf('Error copying %s.%s:\n', o.tag, f{1});
            warning(err_msg(err));
        end
    end
else
    warning('input is not a PsyLogs object.');
end