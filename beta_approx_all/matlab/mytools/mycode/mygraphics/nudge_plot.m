function  nudge_plot(h,nx,ny,sx,sy)
%  nudge_plot(h,nx,ny,[sx],[sy])
%nudges plot with handle h by nx and ny which are fractions of the subplot
% width and height and scales by sx and sy

if nargin~=5
    sx=1;
    sy=1;
end

p = get(h,'pos'); % get position of axes
set(h,'pos',[p(1)+nx*p(3) p(2)+ny*p(4) sx*p(3) sy*p(4)]) % move the axes slightly
