
function xbreaklog(xb,dx)
% xbreak(xb,dx)
% breakx x axis at location xb with wodth dx
hold on

p=pbaspect;
d=daspect;

sc=(p(1)/d(1))/(p(2)/d(2));
dy=0.33*(dx-1)*sc;
aa=axis;

w=[ xb/(dx)  aa(3)+dy; ...
    xb*(dx^2)  aa(3)+dy;...
    xb*dx aa(3)-dy;...
    xb/(dx^2)  aa(3)-dy; ....
    xb/(dx)  aa(3)+dy  ];

h=patch(w(:,1),w(:,2),'w');
set(h,'LineStyle','none')

g1=plot([xb/(dx^2) xb/(dx)],[aa(3)-dy  aa(3)+dy],'k');
g2=plot([xb*dx xb*dx^2],[aa(3)-dy  aa(3)+dy],'k');
axis(aa)
set(h,'clipping','off')
set(g1,'clipping','off')
set(g2,'clipping','off')
end