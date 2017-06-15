function  S=bindata(x,y,plotflag)
%  S=bins(x,y,b)
%   bins(x,y) data into unique values of the rows of x (which can be a
%   matrix). returns the x  and  mean,  stderr and std of  y for each bin
%   in x Optionally   it can plot the data

    x=shiftdim(x);

if nargin==1
    
    S=bindata(x,x);
    return
else
    y=shiftdim(y);

    if ~isvector(y)
        error('Input must be a vector')
    end
    
    [y,n]=shiftdim(y);
    [x]=shiftdim(x,n);
    
    if cols(x)==1
        [S.x,IA,IC]=unique(x);
        
        for k=1:length(S.x)
            s=x==S.x(k);
            w=y(s);
            ws=w(~isnan(w));
            S.m(k)=nanmean(ws);
            S.med(k)=nanmedian(ws);
            S.se(k)= stderr(ws);
            S.sd(k)= nanstd(ws);
            S.n(k)= numel(ws);
            S.sum(k)= nansum(ws);
        end
        
        if nargin ==3 & plotflag
            errorbar(S.x,S.m,S.se,'o-','MarkerFaceColor', 'Auto')
            hold on
        end
    else %multidimensional binning
        r=[];
        for k=1:cols(x)
            [S.x{k},~,ic{k}] = unique(x(:,k),'rows');
            r=[r max(ic{k})];
        end
        
        S.m=nan(r);
        S.med=nan(r);
        
        S.se=nan(r);
        S.sd=nan(r);
        S.n=zeros(r);
        S.min=nan(r);
        S.max=nan(r);
        S.sum=nan(r);

        
        [C,IA,IC] = unique(x,'rows');
        
        for k=1:max(IC)
            s=[];
            for c=1:cols(x);
                s=[s ic{c}(IA(k))];
            end
            s = mat2cell(s,1,ones(1,numel(s)));
            
            w=y(IC==k);
            ws=w(~isnan(w));
            if ~isempty(ws)
                
                S.m(s{:})=mean(ws);
                S.med(s{:})=median(ws);
                
                S.sum(s{:})=nansum(ws);
                S.se(s{:})= stderr(ws);
                S.sd(s{:})= std(ws);
                S.n(s{:})= numel(ws);
                S.min(s{:})= nanmin(ws);
                S.max(s{:})= nanmax(ws);
            end
        end
        
        for k=1:cols(x)
            tmp=bindata(x(:,k),y);
        S.marg{k}=tmp;
        end
        
        
    end
end