function setUpdated(src, evnt)
% setUpdated(src, evnt)
%
% Set (object).updated.(propertyName) true. Use
%
%       addlistener(me, 'propertyName', 'PostSet', @setUpdated);
%
% in the object's constructor.

evnt.AffectedObject.updated.(src.Name) = true;
end