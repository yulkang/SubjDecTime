% testPsyfiles
clear classes;

delete('testPsyFiles.mat');
Files = PsyFiles('testPsyFiles.mat', 'testSDT/*.mat', false, ...
                 'Writable', true);

%%
disp(Files);
