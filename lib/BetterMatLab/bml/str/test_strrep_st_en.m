function tests = test_strrep_st_en
    tests = functiontests(localfunctions);
end
function test_begin(testCase)
    [str, pos] = strrep_st_en('aabbcc', 1, 2, 'xx', 1:6);
    verifyEqual(testCase, str, 'xxbbcc');
    verifyEqual(testCase, pos, 1:6);
end
function test_middle(testCase)
    [str, pos] = strrep_st_en('aabbcc', 3, 4, 'xx', 1:6);
    verifyEqual(testCase, str, 'aaxxcc');
    verifyEqual(testCase, pos, 1:6);
end
function test_end(testCase)
    [str, pos] = strrep_st_en('aabbcc', 5, 6, 'xx', 1:6);
    verifyEqual(testCase, str, 'aabbxx');
    verifyEqual(testCase, pos, 1:6);
end
function test_shorten_begin(testCase)
    [str, pos] = strrep_st_en('aabbcc', 1, 2, '', 1:6);
    verifyEqual(testCase, str, 'bbcc');
    verifyEqual(testCase, pos, [1, 0, 1:4]);
end
function test_shorten_middle(testCase)
    [str, pos] = strrep_st_en('aabbcc', 3, 4, '', 1:6);
    verifyEqual(testCase, str, 'aacc');
    verifyEqual(testCase, pos, [1:2, 3, 2, 3:4]);
end
function test_shorten_end(testCase)
    [str, pos] = strrep_st_en('aabbcc', 5, 6, '', 1:6);
    verifyEqual(testCase, str, 'aabb');
    verifyEqual(testCase, pos, [1:4, 5, 4]);
end
function test_lengthen_begin(testCase)
    [str, pos] = strrep_st_en('aabbcc', 1, 2, 'xxxx', 1:6);
    verifyEqual(testCase, str, 'xxxxbbcc');
    verifyEqual(testCase, pos, [1, 4:8]);
end
function test_lengthen_middle(testCase)
    [str, pos] = strrep_st_en('aabbcc', 3, 4, 'xxxx', 1:6);
    verifyEqual(testCase, str, 'aaxxxxcc');
    verifyEqual(testCase, pos, [1:3, 6:8]);
end
function test_lengthen_end(testCase)
    [str, pos] = strrep_st_en('aabbcc', 5, 6, 'xxxx', 1:6);
    verifyEqual(testCase, str, 'aabbxxxx');
    verifyEqual(testCase, pos, [1:5 8]);
end
