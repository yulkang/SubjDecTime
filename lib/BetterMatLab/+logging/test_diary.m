function test_diary

% logging.diary('on');
% logging.diary('off');

logging.diary('on'); % , 'YK/test/diary.txt', {'comment', 'preRun'});
logging.diary('off', 'YK/test/diary.txt', {'comment', 'preRun_postRun'});
end