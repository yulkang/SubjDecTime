function S = test_mdir

S = test_subfun;

disp('file');
disp([S.file]);
end
function S = test_subfun
S = dbstack(1, '-completenames');

md = mdir;
disp('mdir:');
disp(md);
end