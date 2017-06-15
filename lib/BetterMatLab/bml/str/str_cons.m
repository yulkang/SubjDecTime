function r = str_cons(s1, s2, b)
% r = str_cons(s1, s2, b='_')
%
% EXAMPLE:
% str_cons('a', 'c')
% ans =
% a_c
% 
% str_cons('a', 'c', '')
% ans =
% ac
% 
% str_cons({'a', 'b'}, 'c')
% ans = 
%     'a_c'    'b_c'
% 
% str_cons('a', {'b', 'c'})
% ans = 
%     'a_b'    'a_c'
% 
% str_cons({'a', 'b'}, {'c', 'd'})
% ans = 
%     'a_c'    'b_d'
%
% See also: str_con
%
% 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.

if nargin < 3, b = '_'; end

if iscell(s1)
    if iscell(s2)
        % many-to-many
        assert(numel(s1) == numel(s2));
        
        r = cellfun(@(ss1,ss2) [ss1, b, ss2], s1, s2, 'UniformOutput', false);
    else
        % many-to-one
        r = cellfun(@(ss1) [ss1, b, s2], s1, 'UniformOutput', false);
    end
else
    if iscell(s2)
        % one-to-many
        r = cellfun(@(ss2) [s1, b, ss2], s2, 'UniformOutput', false);
    else
        % one-to-one
        r = [s1, b, s2];
    end
end