function dst = flatten_struct(src, varargin)
% strct = flatten_struct(strct, ...)
%
% strct.field1__subfield1 = strct.field1.subfield1
%
% OPTIONS
% -------
% 'connecting_str', '__'
% 'convert_obj', false
% 'recurse_upto', 0
% 'curr_depth', 0
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

assert(isstruct(src));
S = varargin2S(varargin, {
    'connecting_str', '__'
    'convert_obj', false
    'recurse_upto', 0
    'curr_depth', 0
    });

fs = fieldnames(src)';

if S.convert_obj
    to_convert = @(v) isobject(v) || isstruct(v);
else
    to_convert = @isstruct;
end

dst = struct;
cS = S;
cS.curr_depth = S.curr_depth + 1;
cC = S2C(cS);
for f = fs
    cf_name = f{1};
    cf = src.(cf_name);
    if to_convert(cf)
        if ~isstruct(cf)
            cf = struct(cf);
        end
        n_cf = numel(cf);
        for ii = 1:n_cf
            if n_cf > 1
                ccf_name = sprintf('%s_%d', cf_name, ii);
            else
                ccf_name = cf_name;
            end
            ccf = cf(ii);
            
            for f_sub = fieldnames(ccf)'
                f_name = [ccf_name, S.connecting_str, f_sub{1}];
                if S.curr_depth >= S.recurse_upto || ~to_convert(ccf.(f_sub{1}))
                    dst.(f_name) = ccf.(f_sub{1});
                else
                    if ~isstruct(ccf.(f_sub{1}))
                        ccf.(f_sub{1}) = struct(ccf.(f_sub{1}));
                    end
                    c_dst = flatten_struct(ccf.(f_sub{1}), cC{:});
                    dst = copyFields(dst, ...
                            prefix_fields( ...
                                c_dst, ...
                                [f_name, S.connecting_str]));
                end
            end
        end
    else
        dst.(cf_name) = cf;
    end
end
return;

%% Test
src = struct; %#ok<UNRCH>
targ = varargin2S({'test__a', 1, 'test__b', 2, 'test2__a', 3, 'test2__b', 4});
src = set_sub_struct(src, varargin2S({'a', 1, 'b', 2}), 'test__');
src = set_sub_struct(src, varargin2S({'a', 3, 'b', 4}), 'test2__');
dst = flatten_struct(src);
disp(dst);
passed = isequal(dst, targ);
fprintf('Passed: %d\n', passed);
assert(passed);