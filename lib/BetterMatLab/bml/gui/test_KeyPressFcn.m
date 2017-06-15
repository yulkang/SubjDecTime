function h = test_KeyPressFcn
% Test KeyPressFcn, shows key name.
h = figure;
set(h, 'KeyPressFcn', @(h,e) disp_key(h,e));
end

function disp_key(~, evt)
    c_key = evt.Key;
    disp(c_key);
end
