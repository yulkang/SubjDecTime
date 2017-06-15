function test_diary

% Localog.diary('on');
% Localog.diary('off');

Localog.diary('on'); % , 'YK/test/diary.txt', {'comment', 'preRun'});
Localog.diary('off', 'YK/test/diary.txt', {'comment', 'preRun_postRun'});
end