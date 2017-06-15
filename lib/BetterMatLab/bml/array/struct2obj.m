function obj = struct2obj(obj, varargin)
% obj = struct2obj(obj, struct)
% obj = struct2obj(obj, 'propertyname1', property1, ...)
%
% Copies all the latter's properties or fields to the former.
% Use a blank object, e.g. a constructor, as the former argument.

if length(varargin) == 1
    
    for cField = fieldnames(varargin{1})'
        obj.(cField{1}) = varargin{1}.(cField{1});
    end

else
    for iField = 1:2:length(varargin)
        obj.(varargin{iField}) = varargin{iField+1};
    end
end
end