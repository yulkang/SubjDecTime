%%
figure;
subplot(2,2,2);
plot(Eye.relSec('sampledAbsSec'), [0 diff(Eye.v('sampledAbsSec'))], 'r.-');
hold on;
dSampT = Eye.v('sampledAbsSec')-Eye.t('sampledAbsSec');
plot(Eye.relSec('sampledAbsSec'), dSampT, 'b.-')
ylim([0 0.02]);

subplot(2,2,4);
plot(Eye.relSec('sampledAbsSec'), [0 diff(Eye.v('sampledAbsSec'))], 'r.-');
hold on;
plot(Eye.relSec('sampledAbsSec'), dSampT, 'b.-')
ylim([0 0.02]); xlim([0 0.1]);


subplot(2,2,1);
dSamp = diff(Eye.v('sampledAbsSec'));

hist(dSamp(dSamp>0));

subplot(2,2,3);
hist(diff(Scr.t_.frOn));

hold off;
%%
min(dSampT)
max(dSamp(dSamp>0));
%%
