function h = axes_tag(tag, varargin)
% AXES_TAG  Same as axes() except axes_tag uses a string tag instead of h.
%
% h = axes_tag(tag)
% : Gives the handle of the axes with the tag.
%
% axes_tag(tag, 'Property1', property1, ...)
% : Focuses and sets the axes's properties
%
% See also obj_tag
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

tag = safe_name(tag);

h = obj_tag('axes', tag, varargin{:});