function varargout = factorizeC(varargin)
% C: struct or cell array with name-value pairs.
% When C is a struct, identical to factorizeS.
% When C is a N-by-2 cell array with C(:,1) names and C(:,2) values,
% similar to factorizeS except that
% C(k,1) can be a cell array of names (instead of one name),
% in which case the fields will change values together.
%
% fields: fields to include or exclude
% to_fix
% : if true, fix the specified fields (do not factorize them).
% : if false (default), factorize only the specified fields.
%   When fixing a field, the field is fixed to value{1}, ignoring the rest.
%
% EXAMPLES:
% %% Factorize a and the b-c pair.
% [Ss, n] = factorizeC({
%     'a', {1, 2}
%     {'b', 'c'}, {{10, 100}, {20, 200}}
%     });
% for ii = 1:n
%     disp(Ss(ii));
% end
%
% %% RESULTS:
%     a: 1
%     b: 10
%     c: 100
% 
%     a: 1
%     b: 20
%     c: 200
% 
%     a: 2
%     b: 10
%     c: 100
% 
%     a: 2
%     b: 20
%     c: 200
%
% %% Factorize a only
% [Ss, n] = factorizeC({
%     'a', {1, 2}
%     {'b', 'c'}, {{10, 100}, {20, 200}}
%     }, 'a');
% for ii = 1:n
%     disp(Ss(ii));
% end
% 
% %% RESULTS:
%     a: 1
%     b: 10
%     c: 100
% 
%     a: 2
%     b: 10
%     c: 100
%
% %% Factorize all but a
% [Ss, n] = factorizeC({
%     'a', {1, 2}
%     {'b', 'c'}, {{10, 100}, {20, 200}}
%     }, 'a', true);
% for ii = 1:n
%     disp(Ss(ii));
% end
%
% %% RESULTS:
%     b: 10
%     c: 100
%     a: 1
% 
%     b: 20
%     c: 200
%     a: 1
% 
% See also: factorizeS, factorize
[varargout{1:nargout}] = factorizeC(varargin{:});