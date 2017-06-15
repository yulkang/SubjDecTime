function rsync_all
pths = choose_batch({
    '/Users/yulkang/Dropbox/CodeNData/Code/Shadlen/MDD/reach/human/expr'
    '/Users/yulkang/Dropbox/CodeNData/Code/Shadlen/SDT/EXPERIMENT'
    '/Users/yulkang/Dropbox/CodeNData/Code/Shadlen/Plexon/dotTrain555' % All plx are too much
    ... '/Users/yulkang/Dropbox/CodeNData/Code/Shadlen/Plexon/Data' % All plx are too much
    });
pths = [pths{:}];
pd = cd;

for ii = 1:length(pths)
    cd(pths{ii});
    
    fprintf('Currently in: %s\n', pths{ii});
    Localog.rsync('pull', 'Data', 'confirm', false);
end

fprintf('Going back to: %s\n', pd);
cd(pd);