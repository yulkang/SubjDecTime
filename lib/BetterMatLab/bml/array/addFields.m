function obj = addFields(obj, varargin)
% obj = addFields(obj, varargin)
for ii = 1:2:length(varargin)
    obj.(varargin{ii}) = varargin{ii+1};
end
end