function S = pack_varargin(varargin_C, nam, S)
% S = pack_varargin(varargin_C, inputnames('varargin'), [S])

if ~exist('S', 'var'), S = struct; end

ii = 0;
while ii < length(varargin_C)
	ii = ii + 1;
    
    if ~isempty(nam{ii})
        S.(nam{ii}) = varargin_C{ii};
    else
        S.(varargin_C{ii}) = varargin_C{ii+1};
        ii = ii + 1;
    end
end