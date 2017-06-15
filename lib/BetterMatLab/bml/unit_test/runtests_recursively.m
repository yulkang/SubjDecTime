function results = runtests_recursively(tests, varargin)
% runtests with 'Recursively' option true.
%
% results = runtests_recursively
% : runtests on pwd and all packages within it.
%
% results = runtests_recursively(tests, varargin)
% : runtests with 'Recursively' option true.
%
% 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.

C = varargin2C(varargin, {
    'Recursively', true
    });

if nargin < 1
    packages = dirpackages;
    tests = [{pwd}, packages(:)'];
end

results = runtests(tests);