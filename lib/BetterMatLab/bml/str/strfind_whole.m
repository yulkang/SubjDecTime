function pos = strfind_whole(text, pattern)
% Similar to strfind but finds whole words only (alphanumeric and underscore)
%
% pos = strfind_whole(text, pattern)
%
% EXAMPLE:
% %% Basic
% assert(isequal(strfind_whole('aa bbcc', 'aa'), 1));
% assert(isequal(strfind_whole('aa bbcc', 'bb'), []));
% 
% %% Ignore one but not the other
% assert(isequal(strfind_whole('aa bbcc bb cc', 'bb'), 9));
% 
% %% Multiple occurrences
% assert(isequal(strfind_whole('aa bb cc bb', 'bb'), [4 10]));
% 
% %% Underscore
% assert(isequal(strfind_whole('aa bb_cc bb', 'bb'), 10));
% 
% %% Number
% assert(isequal(strfind_whole('aa bb2cc bb', 'bb'), 10));
%
% See also: strfind, test_strfind_whole
% 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.
    
pos = strfind(text, pattern);
n = numel(pos);
len_text = length(text);
len_pattern = length(pattern);
tf_whole_word = false(size(pos));

for ii = 1:n
    st = pos(ii);
    en = pos(ii) + len_pattern - 1;
    
    st_spaced = (st == 1) || ~is_alphanumeric(text(st - 1));
    en_spaced = (en == len_text) || ~is_alphanumeric(text(en + 1));
            
    tf_whole_word(ii) = st_spaced && en_spaced;
end

pos = pos(tf_whole_word);

% % regexp: Disparity with strfind
% reg_expr = ['\W+', pattern, '\W+'];
% pos = regexp([' ', text, ' '], reg_expr) - 1;
