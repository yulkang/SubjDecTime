function [Q Qu]= opt_unpack(theta,S)
% [Q Qu] = opt_unpack(theta,S)
%
% unpacks up parametes for optimization using values from opt_pack
% Q will contains a structure of named paramaters and their values
% W contains whether each parameter was optimized, fixed or tied to the
% value of the first element in the array

%sort both to match pack

[fp i]=sort(fieldnames(S.O{1})); %extract names

%fp =fieldnames(S.O{1}); %extract names
Pc=struct2cell(S.O{1}); %extract parameters (only to get sizes)
Pc=Pc(i);

count=0;

for k=1:length(fp)
    w=Pc{k}; % parameter
    
    for j=1:length(w)
        if S.tied(k,j) %set equal to first parameter of array (do not increment count)
            s=sprintf('Q.%s(%i)=Q.%s(%i);',fp{k},j,fp{k},S.tied(k,j));
            su=sprintf('Qu.%s(%i)=Qu.%s(%i);',fp{k},j,fp{k},S.tied(k,j));

            if S.tied(k,j)==round(S.tied(k,j)) 
                str=sprintf('''tied-%i''',S.tied(k,j));
            else
                str =  '''tied-1''';
            end

            s1=sprintf('W.%s{%i}=%s;',fp{k},j,str);
            
        elseif S.fixed(k,j) %set to the O{1} value
            s=sprintf('Q.%s(%i)=Pc{%i}(%i);',fp{k},j,k,j);
            su=sprintf('Qu.%s(%i)=Pc{%i}(%i);',fp{k},j,k,j);

            str =  '''fixed''';
            
            s1=sprintf('W.%s{%i}=%s;',fp{k},j,str);
            %
        else %extract from theta
            count=count+1;
           
            %% this if for unconstrained
            eval(sprintf('tlo=S.theta_lo(%i);',count));
            eval(sprintf('thi=S.theta_hi(%i);',count));
            eval(sprintf('th_u=theta(%i);',count));
            
            if isinf(tlo) & isinf(thi)
                th = th_u;
                grad_sc=1;
            elseif isinf(thi)  % lower bound only
                th = tlo+ th_u^2;
                grad_sc=2*th_u;
            elseif isinf(tlo)  % upper bound only
                th = thi- th_u.^2;
                grad_sc=-2*th_u;
            else %two bounds
                th= (sin(th_u)+1)/2;
                th = th*(thi - tlo) + tlo;
                grad_sc=0.5*cos(th_u)*(thi - tlo) ;
            end
            
            s=sprintf('Q.%s(%i)=theta(%i);',fp{k},j,count);
            su=sprintf('Qu.%s(%i)=th;',fp{k},j);
          %  sg=sprintf('Qu.grad_sc(%i)=%f;',count,grad_sc);

            str =  '''optimized''';            
            s1=sprintf('W.%s{%i}=%s;',fp{k},j,str);
        end
        
        
        eval(s);
        eval(su);
      %  eval(sg);

        eval(s1);
        
    end
end

%%
%%
   