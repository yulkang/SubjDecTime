function [tf, prop_info] = is_prop(metainfo, prop)

if ~isa(metainfo, 'meta.class')
    if ischar(metainfo)
        metainfo = ?metainfo;
    elseif isobject(metainfo)
        metainfo = metaclass(metainfo);
    else
        error('IS_PROP:INPUTTYPE', ...
            'Give a meta.class, class name, or an object!');
    end
end

props = [metainfo.PropertyList];
tf0 = strcmp({props.Name}, prop);
tf = any(tf0);
prop_info = props(tf0);