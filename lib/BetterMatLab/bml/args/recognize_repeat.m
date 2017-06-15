function f_handle = recognize_repeat(fun, verbose)
% RECOGNIZE_REPEAT  Converts a function to one that returns remembered outputs 
%                   for successive calls with the same arguments.
%
% f_handle = recognize_repeat(fun, [verbose = false])
%
% fun
% : Function handle.
%
% verbose
% : If true, will show a message on a repeated call with the same arguments.
%   Defaults to false.  
%
% EXAMPLE:
% >> f = recognize_repeat(@min, true);
%
% % If you first demand small number of output(s),
% >> m = f([3 4 2 6]) 
% m = 2
%
% % and subsequently ask for more outputs, the function will be re-evaluated.
% >> [m, ix] = f([3 4 2 6]) 
% m = 2
% ix = 3
%
% % But then if you ask for less, it will return remembered results.
% >> m = f([3 4 2 6]) 
% Called min() with the same arguments -- returning remembered results!
% m = 2
% 
% % In short, the function will remember as many outputs as asked.
% >> [~, ix] = f([3 4 2 6]) 
% Called min() with the same arguments -- returning remembered results!
% ix = 3
% 
% % Inputs and outputs can vary in number. 
% % At least one output will be demanded and remembered.
% >> f([3 4 20 60], [30 40 2 6]) 
% ans =
%      3     4     2     6
%
% % Repeated multiple arguments will be recognized, too.
% >> f([3 4 20 60], [30 40 2 6]) 
% Called min() with the same arguments -- returning remembered results!
% ans =
%      3     4     2     6
%
% 2013 (c) Yul Kang, hk2699 at columbia dot edu. 

if ~exist('verbose', 'var'), verbose = false; end
if verbose
    fun_name = func2str(fun);
else
    fun_name = '';
end

f_handle = @(varargin) rememberer(fun, fun_name, varargin{:});

    function varargout = rememberer(fun, fun_name, varargin)
        persistent argouts argins

        % At least one output.
        n_argout = max(nargout, 1);
        
        if isequal(argins, varargin) && (length(argouts) >= n_argout)
            if ~isempty(fun_name), 
                fprintf('Called %s() with the same arguments -- returning remembered results!\n', ...
                    fun_name); 
            end
            
            if length(argouts) == n_argout
                varargout = argouts;
            else
                varargout = argouts(1:n_argout);
            end
        else
            argins  = varargin;
            argouts = cell(1, n_argout);
            [argouts{1:n_argout}] = fun(varargin{:});
            varargout = argouts;
        end
    end
end