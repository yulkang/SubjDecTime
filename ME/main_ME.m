%% Generate motion energy analysis Figure 5

%panel a) includion window
% clear all
clear

clf
set(0,'defaultlinelinewidth',1)
set(groot, 'defaultAxesTickDir', 'out');
set(groot,  'defaultAxesTickDirMode', 'manual');

file = '../Data/Expr/sdt_motion_energy';
load(file);

%     X is a structure with data for the 800 ms (60 frame) trials 
%     X.subj=subject number
%     X.choice choice 0 (left) 1(right)
%     X.coh= signed coherence
%     X.tnd= t_nd
%     X.sdt= t_sd
%     X.me_bef summed motion energy after 30  (i.e 31-60) frames
%     X.me_aft eummed motion energy before 30  (i.e 1-30) frames


delta=1:20;   %window size to include

for p=1:length(delta) %loop ober inclusion window
    
    r=round(75*(X.sdt-X.tnd));  %frame of t_theta=t_sd-t_tnd;
    inclusion= r>=30-delta(p)+1 & r<=30+delta(p); %find trials that are inside window
    
    N(p)=sum(inclusion);
    
    %extract trials
    me_bef=X.me_bef(inclusion);
    me_aft=X.me_aft(inclusion);
    coh=X.coh(inclusion);
    choice=X.choice(inclusion);
    
    %glm
    [beta1,~,stats] = glmfit([me_bef me_aft coh],choice, 'binomial', 'link', 'logit');
    
    b_bef(p)=beta1(2);
    b_aft(p)=beta1(3);
    b_bef_se(p)=stats.se(2);
    b_aft_se(p)=stats.se(3);
    b_bef_pval(p)=stats.p(2);
    b_aft_pval(p)=stats.p(3);
    b_bef_df(p)=stats.dfe;
    b_aft_df(p)=stats.dfe;
    
    % difference term
    [~,~,stats_dif] = glmfit([me_bef - me_aft, me_bef + me_aft, coh], choice, 'binomial', 'link', 'logit');
    p_dif(p) = stats_dif.p(2);
end


%plot results

subplot(1,2,1);
hold on
ms=8;

tdelta=1000*delta/75;
errorbar(tdelta,b_bef,b_bef_se,'bo-');
q=b_bef_pval<0.05;
plot(tdelta(q),b_bef(q),'bo','MarkerFaceColor','b','MarkerSize',ms);
h(1)=plot(tdelta(~q),b_bef(~q),'bo','MarkerFaceColor','w','MarkerSize',ms);

dx=2; %oofset for display clarity
errorbar(tdelta+dx,b_aft,b_aft_se,'ro-');
q=b_aft_pval<0.05;
plot(dx+tdelta(q),b_aft(q),'ro','MarkerFaceColor','r','MarkerSize',ms);
h(2)=plot(dx+tdelta(~q),b_aft(~q),'ro','MarkerFaceColor','w','MarkerSize',ms);

aa=axis;
plot(aa(1:2),[0 0],'k--')

set(gca,'XTick',round(0:50:250))
aa=axis;
axis([aa(1:3) 1.2])
grid off

xlabel('Inclusion tolerance (\Delta ms)')
ylabel({'Leverage on choice'})
legend(h,{'early motion energy (\beta_1)','late motion energy (\beta_2)'},'Location','best')
set(gca,'Linewidth',2)

shg

%% p-value of the difference term
p_dif1 = p_dif(2:12);
disp('p_dif between 26ms to 160ms:');
disp(p_dif1);
disp('# p_dif < 0.05:');
disp(sum(p_dif1 < 0.05));
disp('# 0.05 <= p_dif < 0.1:');
disp(sum((p_dif1 >= 0.05) & (p_dif1 < 0.1)));

%% Z-test for difference
z_dif = (b_bef - b_aft) ./ sqrt(b_bef_se .^2 + b_aft_se .^2);
zcum = normcdf(z_dif);
p = min(zcum, 1 - zcum) * 2;
p1 = p(2:12); % 26ms to 160 ms
disp('p-value of the difference (26-160 ms):');
disp(p1);
disp('# p < 0.05:');
disp(sum(p1 < 0.05));
disp('# 0.05 <= p < 0.1:');
disp(sum((p1 >= 0.05) & (p1 < 0.1)));

%% panle b) bootstrap

clear
file = '../Data/Expr/sdt_motion_energy';
load(file);

delta=10; %window size to include
r=round(75*(X.sdt-X.tnd)); %frame of t_theta=t_sd-t_tnd;

%find trials that are inside window
inclusion=false(size(r));
inclusion(r>=30-delta+1 & r<=30+delta)=true; 

ntrial=sum(inclusion); %number of trials
exclusion=find(~inclusion); %trials outside window

%extract data from trials in window
me_bef=X.me_bef(inclusion);
me_aft=X.me_aft(inclusion);
coh=X.coh(inclusion);
choice=X.choice(inclusion);

%fit glm
[beta,dev,stats] = glmfit([me_bef me_aft coh],choice, 'binomial', 'link', 'logit');

results=[beta(2) beta(3) stats.se(2) stats.se(3)];

%now bootstrap on excluded trials
nb=5000; % nuber of bootstaps
boot_results=zeros(nb,4);

for b=1:nb
    if rem(b,100)==0,  b, end
    
    boot_samples=exclusion(randi(length(exclusion),[ntrial 1]));
        
    me_bef=X.me_bef(boot_samples);
    me_aft=X.me_aft(boot_samples);
    choice=X.choice(boot_samples);
    coh=X.coh(boot_samples);
    
    [beta,dev,stats] = glmfit([me_bef me_aft coh],choice, 'binomial', 'link', 'logit');
    
    boot_results(b,:)=[beta(2) beta(3) stats.se(2) stats.se(3)];
end


b_bef=results(2)-results(1); % empirical difference
b_aft=boot_results(:,2)-boot_results(:,1); % bootstrap differences
fprintf('Bootstrap signicance for difference in early vs late motion p=%2.4f\n',mean(b_bef>b_aft))

% plot boostrap

set(gca,'Linewidth',2)

subplot(1,2,2)
hold on
bar(3 ,results(1),'b');
errorbar(3,results(1),0.01,results(3),'b','LineWidth',3);
b2=bar(1,mean(boot_results(:,1)),'b');
errorbar(1,mean(boot_results(:,1)),0.0,mean(boot_results(:,3)),'b','LineWidth',3);

bar(4,results(2),'r');
errorbar(4,results(2),0,results(4),'r','LineWidth',3)

b4=bar(2,mean(boot_results(:,2)),'r');
errorbar(2,mean(boot_results(:,2)),0,mean(boot_results(:,4)),'r','LineWidth',3)
plot([2.5 2.5],[-0.1 .35],'k')
set(gca, 'XTick', 1:4, 'XTickLabel', {'','','',''});

legend([b2 b4],{'early motion energy (\beta_1)','late motion energy (\beta_2)'},'Location','best');

aa=axis;
axis([aa(1:3) 0.5])

xlabel('Inclusion criteria')
ylabel({'Leverage on choice'})
text(0.5, -0.06,'$$ t_\theta \notin 400 \pm 133 ms $$','Interpreter','latex','FontSize',20);
text(2.8, -0.06,'$$ t_\theta \in 400 \pm 133 ms $$','Interpreter','latex','FontSize',20);

shg


