% testME

clear classes

% % 0.512
% load('/Users/yulkang/Dropbox/0_work/Shadlen/MDD/MDDReach/MDDShort_YK/MDDShort_YK_20121202T204044.mat')

% % 0.256
% load /Users/yulkang/Dropbox/0_work/Shadlen/MDD/MDDReach/MDDShort_YK/MDDShort_YK_20121202T204053.mat

% % 0.128
% load /Users/yulkang/Dropbox/0_work/Shadlen/MDD/MDDReach/MDDShort_YK/MDDShort_YK_20121202T204336.mat

% % 0.064
% load /Users/yulkang/Dropbox/0_work/Shadlen/MDD/MDDReach/MDDShort_YK/MDDShort_YK_20121202T204357.mat

% 0.000
load /Users/yulkang/Dropbox/0_work/Shadlen/MDD/MDDReach/MDDShort_YK/MDDShort_YK_20121202T204417.mat

% % -0.064 
% load /Users/yulkang/Dropbox/0_work/Shadlen/MDD/MDDReach/MDDShort_YK/MDDShort_YK_20121202T204405.mat

% % -0.128
% load /Users/yulkang/Dropbox/0_work/Shadlen/MDD/MDDReach/MDDShort_YK/MDDShort_YK_20121202T204109.mat

% % -0.512
% load /Users/yulkang/Dropbox/0_work/Shadlen/MDD/MDDReach/MDDShort_YK/MDDShort_YK_20121202T204308.mat

MFilt = PsyMotionFilter(RDKCol);

%%
tic;
addSecRep = [0 0.1 0.22 0.4];
col       = 'rgbm';
iCol      = 0;

for cAddSec = addSecRep
    [MEsum mME cME] = RDKCol.EnMot(MFilt, cAddSec);
    
    iCol = iCol + 1;
    
    hold on;
    plot(((1:length(mME))+iCol/10)/RDKCol.Scr.info.refreshRate, mME, [col(iCol) '.-']);
end
toc;