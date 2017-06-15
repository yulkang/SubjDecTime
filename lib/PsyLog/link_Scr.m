function o = link_Scr(o)
% o = link_Scr(o)
Scr = o.Scr;

fs = fieldnames(o)';
fs = fs(cellfun(@(nam) isa(o.(nam), 'PsyLogs'), fs));

for f = fs
%     try
        if isprop(o.(f{1}), 'Scr')
            o.(f{1}).Scr = Scr;
            Scr.c.(f{1}) = o.(f{1});
            
            for ff = fs
                if isprop(o.(f{1}), ff{1})
                    o.(f{1}).(ff{1}) = o.(ff{1});
                end
            end
        end
%     catch err
%         warning('Error connecting %s.Scr:\n', f{1});
%         warning(err_msg(err));
%     end
end