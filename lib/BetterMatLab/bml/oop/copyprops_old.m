function dst = copyprops_old(dst, src, varargin)
% dst = copyprops_old(dst, src, ...)
%
% Deprecated. Use bml.oop.copyprops instead.
%
% src, dst : struct or an object
%
% OPTIONS
% -------
% 'props', []
% 'skip_absent', true
% 'skip_dependent', true
% 'skip_transient', true
% 'skip_hidden', false
%
% 2015 (c) Yul Kang. yul dot kang dot on at gmail.
S = varargin2S(varargin, {
    'props', [] % Give names {'prop1', ...}, [] (all except skipped), or {} (none).
    'skip_absent', true
    'skip_dependent', true
    'skip_transient', true
    'skip_hidden', false
    });
isstruct_src = isstruct(src);

props = S.props;
if isequal(props, [])
    if isstruct_src
        props = fieldnames(src);
    else
        mc = metaclass(src);
        props_list = mc.PropertyList;
        incl = true(numel(props_list), 1);

        if S.skip_dependent
            incl = incl & ~vVec([props_list.Dependent]);
        end
        if S.skip_transient
            incl = incl & ~vVec([props_list.Transient]);
        end
        if S.skip_hidden
            incl = incl & ~vVec([props_list.Hidden]);
        end
        props_list = props_list(incl);
        props = {props_list.Name};
    end
end

assert(iscell(props));
assert(all(cellfun(@ischar, props(:))));

n = numel(props);
for ii = 1:n
    prop = props{ii};
    
    if S.skip_absent
        if isstruct_src
            if ~isfield(src, prop)
                continue;
            end
        else
            if ~isprop(src, prop)
                continue;
            end
        end
    end
    
    try
        v = src.(prop);
    catch
        v = src.(['get_' prop]);
    end
    try
        dst.(prop) = v;
    catch
        try
            dst.(['set_' prop])(v);
        catch err
            warning(err_msg(err));
        end
    end
end