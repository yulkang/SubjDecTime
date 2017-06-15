function varargout = setdiff_general(a, b, varargin)
% setdiff that works with all types, including cell arrays (use 'stable' mode).
% Note that only 'stable' mode is allowed for the types that doesn't work with 
% setdiff(). Also, concatenation must be defined between the two inputs.
%
% EXAMPLE:
% >> setdiff_general({4,5}, {2,3,4}, 'stable')
% ans = 
%     [5]
%
% >> setdiff_general({4,5,6;7,8,9},{1,2,3;4,5,6}, 'stable', 'rows')
% Warning: The 'rows' input is not supported for cell array inputs. 
% > In cell/union>cellunionR2012a (line 204)
%   In cell/union (line 134)
%   In union_general (line 11) 
% ans = 
%     [7]    [8]    [9]
%
% See also: setdiff, union_general
%
% 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.

try
    % TODO: remove warning when given cell arrays with 'rows' mode.
    [varargout{1:nargout}] = setdiff(a, b, varargin{:});
catch
    is_stable = any(strcmp('stable', varargin));
    is_rows   = any(strcmp('rows', varargin));
    assert(is_stable, ...
        'Only ''stable'' mode is allowed for non-numeric, non-string inputs!');
    % TODO: giving second and third outputs is possible.
    assert(nargout <= 1, ...
        'Second and third outputs are not implemented yet!');

    common_a = intersect_ix_general(a, b, is_rows);

    % Part that depends on the kind of set operation
    if is_rows
        varargout{1} = a(~common_a, :);
    else
        if ~isrow(a)
            a = a(:); % To match union()'s behavior.
        end
        varargout{1} = a(~common_a);
    end
end
end