RR = 60;

x = -2.5:0.1:2.5;
t = 0:(1/RR):1;

LBase = 205;
LAdj  = 255;
m     = 0.1;

fS    = 2;
fT    = 10;

vBase = 0.5*LBase*(1+m*sin(2*pi*fT*t(:))*sin(2*pi*fS*x) ...
                  +1+  cos(2*pi*fT*t(:))*cos(2*pi*fS*x));
              
vAdj  = 0.5*LAdj *(1+m*sin(2*pi*fT*t(:))*sin(2*pi*fS*x) ...
                  +1-  cos(2*pi*fT*t(:))*cos(2*pi*fS*x));              
              
subplot(1,3,1); imagesc(vBase); colorbar;
subplot(1,3,2); imagesc(vAdj);  colorbar;
subplot(1,3,3); imagesc(vBase+vAdj); colorbar;