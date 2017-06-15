function tf = regexps(s, c)
% Given a string and multiple regular expressions, return if there's any match for each.
%
% tf = regexps(s, c)
tf = cellfun(@(cc) ~isempty(regexp(s, cc, 'once')), c);