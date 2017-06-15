function test_simple

D = logging.commit_if_changed;

comment = input_def('Comment'); % May be different from commit message.

logging.diary('on', 'diary.txt', ...
    {'comment', comment, ...
     'datestr', D.datestr});
logging.save('ws.mat', {}, {'comment', comment, 'datestr', D.datestr});

comment2 = input_def('Post-run comment');
logging.diary('off', 'diary.txt', ...
    {'comment', [comment, '_', comment2], ...
     'datestr', D.datestr});