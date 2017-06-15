#!/bin/sh

if [ $(hostname) = "nz23161" ]; then
    PROJDIR="/export/spm-devel/matlabbatch/branches/mlb_1"
    ML2009a="/usr/local/matlab2009a/bin/matlab"
    MLR14SP3="/usr/local/matlabR14SP3/bin/matlab"
else
    PROJDIR="/data/projects/spm-devel/matlabbatch/branches/mlb_1"
    ML2009a="matlab2009a"
    MLR14SP3="matlabR14SP3"
fi

D1CLASSES="@cfg_branch @cfg_choice @cfg_const @cfg_entry @cfg_files @cfg_menu @cfg_repeat"
D2CLASSES="@cfg_exbranch"
# @cfg_branch is the master in-tree class
INCLASSES="@cfg_choice @cfg_repeat"

echo "Copying @cfg_item/subsasgn.m to all derived classes"
for DC in $D1CLASSES $D2CLASSES; do
    cp $PROJDIR/@cfg_item/subsasgn.m $PROJDIR/$DC;
done

echo "Copying @cfg_item/subs_fields.m to all derived classes"
for DC in $D1CLASSES $D2CLASSES; do
    cp $PROJDIR/@cfg_item/subs_fields.m $PROJDIR/$DC;
done

echo "Copying @cfg_item/subsref.m to all derived classes"
for DC in $D1CLASSES $D2CLASSES; do
    cp $PROJDIR/@cfg_item/subsref.m $PROJDIR/$DC;
done

echo "Copying @cfg_branch/all_leafs.m to all in-tree classes"
for IC in $INCLASSES; do
    cp $PROJDIR/@cfg_branch/all_leafs.m $PROJDIR/$IC;
done

echo "Copying @cfg_branch/all_set.m to all in-tree classes"
for IC in $INCLASSES; do
    cp $PROJDIR/@cfg_branch/all_set.m $PROJDIR/$IC;
done

echo "Copying @cfg_branch/fillvals.m to all in-tree classes"
for IC in $INCLASSES; do
    cp $PROJDIR/@cfg_branch/fillvals.m $PROJDIR/$IC;
done

echo "Copying @cfg_branch/list.m to all in-tree classes"
for IC in $INCLASSES; do
    cp $PROJDIR/@cfg_branch/list.m $PROJDIR/$IC;
done

echo "Copying @cfg_branch/tagnames.m to all in-tree classes"
for IC in $INCLASSES; do
    cp $PROJDIR/@cfg_branch/tagnames.m $PROJDIR/$IC;
done

echo "Copying @cfg_branch/val2def.m to @cfg_choice classes"
cp $PROJDIR/@cfg_branch/val2def.m $PROJDIR/@cfg_choice/;

echo "Copying @cfg_choice/clearval.m to @cfg_repeat"
cp $PROJDIR/@cfg_choice/clearval.m $PROJDIR/@cfg_repeat/;

echo "Repairing cfg_ui.fig"
$ML2009a -nodisplay -r "addpath('$PROJDIR');hgsave_pre2008a('$PROJDIR/cfg_ui.fig',true);exit"
# handles in .fig files fail at all in 2007b
#$MLR14SP3 -nodisplay -r "addpath('$PROJDIR');cfg_ui_R14SP3;exit"
#rm $PROJDIR/cfg_ui_R14SP3.m
mv $PROJDIR/cfg_ui_R14SP3.fig $PROJDIR/cfg_ui.fig
