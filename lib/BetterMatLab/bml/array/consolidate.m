function varargout = consolidate(varargin)
% Same as consolidator except xcon can be given.
%
% [xcon, ycon, ind, arr] = consolidate(x, y, fun, tol, xcon, def=nan)
%
% After running consolidator for the whole set, 
% run consolidate for the subset with xcon,
% so that when the subset lacks some elements of xcon in the whole set,
% the resulting ycon is still in the same order.
%
% See also: consolidator
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

if nargin < 5 || isempty(varargin{5})
    % If xcon is not given, the same as consolidator
    [varargout{1:nargout}] = consolidator(varargin{1:min(4, nargin)});
else
    xcon = varargin{5};
    if nargin >= 6 && ~isempty(varargin{6}), defVal = varargin{6}; else defVal = nan; end
    
    % Just do consolidator
    [xconAct, yconAct, indAct] = consolidator(varargin{1:min(4, nargin)});
    
    % Workaround a bug in consolidator where xconAct deviates from the actual value
    if nargin < 4 || isempty(varargin{4}) || varargin{4} == 0
        xconAct = unique(varargin{1}, 'rows'); 
    end
    
    % Find intersection of xcon given and actual
    [~, ia, ib] = intersect(xcon, xconAct, 'rows');
    ycon = zeros(size(xcon,1),1) + defVal;
    ycon(ia) = yconAct(ib);
    
    % Revise ind
    ind = zeros(size(indAct));
    
    for ii = 1:max(indAct)
        flt = indAct == ii;
        ixb = ii == ib;
        
        if any(ixb)
            ind(flt) = ia(ixb);
        end
    end
    
    % Output
    varargout = {xcon, ycon, ind};
end