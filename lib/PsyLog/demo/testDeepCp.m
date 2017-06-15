clear all;
tt1 = testDeepCopy
tt2 = testDeepCopy

tt1.child = tt2;
tt2.parent = tt1;

tt3 = copyTree(tt1, [])