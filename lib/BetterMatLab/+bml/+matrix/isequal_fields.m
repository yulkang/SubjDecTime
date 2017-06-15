function tf = isequal_fields(S1, S2, varargin)
% tf = isequal_fields(S1, S2, varargin)
%
% OPTIONS:
% 'treat_nans_same', true
%
% 2016 YK wrote the initial version.

opt = varargin2S(varargin, {
    'treat_nans_same', true
    'verbose', false
    });
fs1 = fieldnames(S1);
fs2 = fieldnames(S2);
fields_match = isempty(setxor(fs1, fs2));
if ~fields_match
    tf = false;
    if opt.verbose
        fprintf('fieldnames(S1) - fieldnames(S2):');
        dif12 = setdiff(fs1, fs2);
        fprintf(' %s', dif12{:});
        fprintf('\n');
        
        fprintf('fieldnames(S2) - fieldnames(S1):');
        dif21 = setdiff(fs2, fs1);
        fprintf(' %s', dif21{:});
        fprintf('\n');
    end
    return;
end

tf = true;
for f = fs1(:)'
    if opt.treat_nans_same
        c_tf = isequaln(S1.(f{1}), S2.(f{1}));
    else
        c_tf = isequal(S1.(f{1}), S2.(f{1}));
    end
    if ~c_tf && opt.verbose
        fprintf('S1.%s = ', f{1});
        disp(S1.(f{1}));
        fprintf('S2.%s = ', f{1});
        disp(S2.(f{1}));
    end
    tf = tf && c_tf;
end
end