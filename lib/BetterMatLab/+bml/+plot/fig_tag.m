function varargout = fig_tag(varargin)
% FIG_TAG  Same as figure() except fig_tag uses a string tag instead of h.
%
% [h, tag] = fig_tag(tag)
% : Gives the handle of the figure with the tag.
%
% fig_tag(tag, 'Property1', property1, ...)
% : Focus and sets the figure's properties
%
% tag can be either a string or a cell array of strings.
%
% See also obj_tag, axes_tag
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = fig_tag(varargin{:});