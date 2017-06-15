% testPsyOrder
clear all;

fprintf('------\n');
tt = PsyOrder('aa', 'bbb', 'ccc'), length(tt.str)
tt = tt.off('ccc')          , length(tt.str)
tt = tt.on('_bbb', 'ddd')   , length(tt.str)
tt = tt.on('_aa', 'ccc')    , length(tt.str)
tt = tt.on('^ccc', 'bbb')   , length(tt.str)
tt = tt.off('ddd', 'aa')    , length(tt.str)
tt = tt.off('ccc', 'bbb')   , length(tt.str)
tt = tt.on('aa', 'bbb')     , length(tt.str)
tt = tt.on('_st_', 'bbb')   , length(tt.str)
tt = tt.on('^en_', 'bbb')   , length(tt.str)

tt.cell