function varargout = ds_count(varargin)
% c = ds_count(tmp, querry, [op='incl'|'excl', f={fieldnames}, w_col=count_column]);
%
% EXAMPLE:
% >> C1 = {'a', 'b'; 1 2; 1 3};
% >> C2 = {'a', 'b', 'c'; 1 2 1; 1 2 2; 1 3 1; 1 3 2; 1 3 3};
% >> ds1 = cell2ds(C1)
% ds1 = 
%     a          b      
%     [1]        [2]    
%     [1]        [3]    
% 
% >> ds2 = cell2ds(C2)
% ds2 = 
%     a          b          c      
%     [1]        [2]        [1]    
%     [1]        [2]        [2]    
%     [1]        [3]        [1]    
%     [1]        [3]        [2]    
%     [1]        [3]        [3]    
% 
% >> ds_count(ds1, ds2)
% ans = 
%      2
%      3
[varargout{1:nargout}] = ds_count(varargin{:});