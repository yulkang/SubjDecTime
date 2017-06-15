
function D=DATAFILE_Select(P,samp,trials)
%D= DATAFILE_Select(P,samp,trials)
% Extracts the trial numbers specified in the vector samp from the data structure P
% trials are renumbered sequentially  - specify total  number of trials if there
% is not P.Trials as part of structure
% samp can be a logical inex or set of trial numbers

if nargin==2
    trials=P.Trials; 
end

%get fieldnames
fu=fieldnames(P);
%loop over fieldnames
for k=1:length(fu)
  
    %only perform extraction on non-structures
    if eval(sprintf('~isstruct(%s.%s)','P',fu{k}))
        
        %pull out matrices
        c1= eval(sprintf('%s.%s','P',fu{k}));
        s1=size(c1);
        
        %find the trial dimension
        i=find(s1==trials,1,'first');
        
        %now extract depending on whether the matrix is 2 or 3D
        if length(s1)==2
            if isempty(i)
                eval(sprintf('D.%s=c1;',fu{k}));
            elseif i==1
                eval(sprintf('D.%s=c1(samp,:);',fu{k}));
            elseif i==2
                eval(sprintf('D.%s=c1(:,samp);',fu{k}));
            end
        elseif length(s1)==3
            if i==1
                eval(sprintf('D.%s=c1(samp,:,:);',fu{k}));
            elseif i==2
                eval(sprintf('D.%s=c1(:,samp,:);',fu{k}));
            elseif i==3
                eval(sprintf('D.%s=c1(:,:,samp);',fu{k}));
            end
        end
    else %if a structure, then use this function recursively but give the number of trial
        eval(sprintf('D.%s=DATAFILE_Select(P.%s,samp,%i);',fu{k},fu{k},trials));
        
    end
end


%finally set the number of trials and trial numbers
if nargin==2
    if isequal(unique(samp),[0 1]')
        D.Trials=sum(samp);
        D.TrialNumber=(1: D.Trials)';
    else
        D.Trials=length(samp);
        D.TrialNumber=(1: D.Trials)';
    end
end
