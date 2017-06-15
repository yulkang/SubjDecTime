disp('-----');
disp('Trying to change for loop range within the loop');
n = 5; 
for ii = 1:n, 
    if mod(ii,2), 
        n = n+1; 
    end; 
    disp([ii, n]); 
end
disp('Once determined in the beginning, the range of for is not re-evaluated.');

%%
disp('-----');
disp('Trying to change the index variable within the loop');
n = 5; 
for ii = 1:n, 
    disp([ii, n]); 
    ii = ii + 1;
    disp([ii, n]); 
end
disp('Change in the index variable is overrided by the for statement.');

%%
disp('-----');
disp('Trying to change the index variable within the loop');
n = 5; 
for ii = 1:n, 
    disp([ii, n]); 
    ii = ii - 1;
    disp([ii, n]); 
end
disp('Change in the index variable is overrided by the for statement.');
