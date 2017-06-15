clf
g=1+linspace(-0.9,0.9,11);
n=200;

x=linspace(0,1,n);

for k=1:length(g)
    y=betacdf(x,g(k),g(length(g)+1-k));
    plot(linspace(-0.512,0.512,2*n),[y fliplr(y)])
    hold on
end
shg

%%
clear all
%set a bunch of graphic defaults

load ../Data/Expr/all_data
QQ=D;
col='k'

nsubj=5;

for subj=1:4%:nsubj
    %conditon 1=RT+SDT 2=VDT+SDT  3= VDT
    
    %pull out all 800 ms dispaly trials
    s=QQ.subj==subj & QQ.cond==2 &  QQ.rdk_dur==0.8  ;%&  QQ.delay==0.8;
    D=DATAFILE_Select(QQ,s); %pull out the data
    D.rt=D.sdt_dur;  %we will look at SDT
    D.strength=D.coh;
    D.choice=D.ci;
    D.var_data=abs(D.strength);
    
    %fit logistic to decide on what we classify as correct and use for RT
    %likelihood
    beta = glmfit(D.strength,D.choice, 'binomial', 'link', 'logit');
    th=-beta(1)/beta(2);
    D.include_for_rt=(D.strength>= th & D.choice==1) | (D.strength<= th & D.choice==0);
    
    s=logical(D.include_for_rt);
    
    S=bindata((D.strength(s)),D.rt(s));
    [~,~,s1]=unique((D.strength));
    
    sss=S.se;
    D.rt_std=S.sd(s1)';
    D.rt=S.m(s1)';
    
    % fit all params by default to both choice and rt for 'correct' and
    % optimize
    % or do a fit fixing y0 and mu to 0
    g=1+linspace(-0.95,0.95,31);
    %   g=logspace(log(0.7),log(1/0.7),10);
    PLOT=1;
    
    
    for j=1:length(g)
        E=D;
        
        coh0=linspace(-0.2,0.2,500);
        for q=1:length(coh0)
            x=betacdf((0.512-abs(E.strength-coh0(q)))/0.512,g(j),g(length(g)+1-j));
            [B,BINT,R,RINT,STATS] = regress(E.rt,[x==x x ]);
            rr2(q)=STATS(1);
        end
        [~,i]=max(rr2)
        
        x=betacdf((0.512-abs(E.strength-coh0(i)))/0.512,g(j),g(length(g)+1-j));
        [B,BINT,R,RINT,STATS] = regress(E.rt,[x==x x ]);
        
        r2(j)=STATS(1);
        s=E.include_for_rt;
        S=bindata(E.strength(s),E.rt(s));
        cc=linspace(-0.55,0.55,100);
        
        x1=betacdf((0.512-abs(cc-coh0(i)))/0.512,g(j),g(length(g)+1-j));
        
        Q{subj}.coh=S.x;
        Q{subj}.sdt_mean=S.m;
        Q{subj}.sdt_se=sss;
        Q{subj}.cc=cc;
        Q{subj}.mm{j}=B(1)+B(2)*x1;
        
       
        %calculate standard deviations for each coherence
        if j==1
            [~,W,T_opt,T_opt_se,grad,hess,nlogl,Wpred]=dtb_fit_means(E,'rt_only',1,'mu_opt',1);
            opt_fit= W.p_nlogl
        end
         Q{subj}.opt_fit=opt_fit;
        
        E.rt=B(1)+B(2)*x;
        
        [~,W,T_opt,T_opt_se,grad,hess,nlogl,Wpred]=dtb_fit_means(E,'rt_only',1,'mu_opt',1);
        grad(j)=norm(grad);
        val(j)=W.p_nlogl;
        Q{subj}.Wpred{j}=Wpred;
        Q{subj}.E=E;

        T_opt
      
        
        
        
    end
    Q{subj}.r2=r2;
    Q{subj}.val=val;


    T_opt  %stderr afe in D and other nice th
    
   
    
    
end

save beta_approx
%%
load beta_approx
clf

    
cx=colormap(jet(length(g)))
set(0,'DefaultFigureWindowStyle','normal')
set(0, 'DefaultFigureColor',[1 1 1])
set(0,'DefaultAxesFontSize',16)
set(0,'DefaultAxeslinewidth',2)
set(groot,'defaultAxesTickDir', 'out');
set(groot,'defaultAxesTickDirMode', 'manual');
set(0,'defaultlinelinewidth',2)
set(0,'defaultLineMarkerSize',8);
aa=get(gcf,'Position');
set(gcf,'Position', [aa(1:2) 1300 1000])
lw=3; %line width


for subj=1:4
    for j=1:5:length(g)
        v2struct(Q{subj})
        s=(val<1000);
        if s(j)==0
            continue
        end
        col=cx(j,:)
        
        
        h=mysubplot(3,4,1,subj)
        
        errbar(coh*100,sdt_mean,sdt_se,'k')
        hold on
        plot(coh*100,sdt_mean,'ko','MarkerFace','k');
        
        plot(cc*100,mm{j},'r-','Color',col);
        xlabel('')
        
        if subj==1
            
            ylabel('t_{SD}')
        end
        box off
        
        aa=axis;
        axis([-60 60  aa(3:4)])
        set(gca,'XTick',[-51.2 0 51.2])
        
        mysubplot(3,4,2,subj)
        
        h=plot_psychometric(Wpred{j},'data',0,'rt',0,'col',col,'folded',0);
        plot_psychometric(E,'pred',0,'rt',0,'col','k','folded',0);
        if subj>1
            ylabel('');
        end
        xlabel('Motion strength (%)')
        
        
        hold on
        aa=axis;
        axis([-0.6 0.6  aa(3:4)])
        
        mysubplot(3,4,3,subj)
        
        plot(r2(s),-val(s),'k-')
        hold on
        plot([min(r2) 1],-[opt_fit opt_fit],'r-')
         
              xlabel('R^2')
        if subj==1
        ylabel('Log-likelihood (P_{right} )')
        end
       if s(j)
           plot(r2(j),-val(j),'o','Color',col,'MarkerFace',col,'MarkerEdgeColor',col)
       end
        box off
       
    end
end
for subj=1:4
 h=mysubplot(3,4,1,subj)
         nudge_plot(h,0,-0.1)
end
shg

text_outside(0.2,0.93,'S1','FontSize',16)
text_outside(0.4,0.93,'S2','FontSize',16)
text_outside(0.62,0.93,'S3','FontSize',16)
text_outside(0.82,0.93,'S4','FontSize',16)


%%
savefig('beta');
export_fig beta.png
export_fig beta.pdf
