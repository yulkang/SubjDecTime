function text_outside(x,y,s,varargin)

ax1 = axes('Position',[0 0 1 1],'Visible','off');
%axes(ax1) % sets ax1 to current axes
if nargin>3
text(x,y,s,varargin{:})
else
    text(x,y,s)
end