function varargout = is_name_followed_by_numbers_and_underscore(varargin)
% [tf, names] = is_name_followed_by_numbers_and_underscore(name, names)
%
% EXAMPLE:
% >> tf = is_name_followed_by_numbers_and_underscore('abc', {
%     'ab', 'abc', 'abc1_', 'abc1_b', 'abc1_23', 'abc1_b1_23'})
% tf =
%      0     0     1     0     1     0
%
% 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.
[varargout{1:nargout}] = is_name_followed_by_numbers_and_underscore(varargin{:});