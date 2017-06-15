hazUni = fHaz(ones(1,1000));
hazExp = fHaz(exppdf(0:0.01:10,10/3));

find(hazUni./hazUni(1)>1.5, 1, 'first')
find(hazExp./hazExp(1)>1.5, 1, 'first')

plot(hazExp./hazExp(1)); hold on; plot(hazUni./hazUni(1)); hold off; ylim([0 2]);

nam = 'Hazard Uni Exp(Trunc at 3x mean)';
title(nam);
print(gcf, nam, '-depsc2');