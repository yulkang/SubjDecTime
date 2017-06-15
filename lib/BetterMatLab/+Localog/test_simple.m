function test_simple

D = Localog.commit_if_changed;

comment = input_def('Comment'); % May be different from commit message.

Localog.diary('on', 'diary.txt', ...
    {'comment', comment, ...
     'datestr', D.datestr});
Localog.save('ws.mat', {}, {'comment', comment, 'datestr', D.datestr});

comment2 = input_def('Post-run comment');
Localog.diary('off', 'diary.txt', ...
    {'comment', [comment, '_', comment2], ...
     'datestr', D.datestr});