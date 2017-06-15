classdef Consts
    properties (Constant)
        subjs = {'S1', 'S2', 'S3', 'S4', 'S5'};
        subjs_w_SDT_modul = {'S1', 'S2', 'S3', 'S4'};
        subjs_wo_SDT_modul = {'S5'};
        
        beep_parads = {
            'BeepOnly_longDelay4'
            'BeepFreeChoiceGo_longDelay4'
            'BeepFreeChoiceNoGo_longDelay4'
            }';
        dtb_wSDT_parads = {
            'RT_M_0_512_6_w_clock_longDelay4'
            'VD_M_0_512_6_w_clock_mix_longDelay4'
            }';
        dtb_wSDT_parads_short = {
            'RT_wSDT'
            'VD_wSDT'
            }';
        
        VD_woSDT_parad = 'VD_M_0_512_6_wo_clock_mix_longDelay4';
        dtb_parads = [
            {Data.Consts.VD_woSDT_parad}, ...
            Data.Consts.dtb_wSDT_parads];
        dtb_parads_short = [
            Data.Consts.dtb_wSDT_parads_short(:)
            {
            'VD_woSDT'
            }]';
        
        rt_label = varargin2S({
            'SDT_ClockOn', 'SDT'
            'RT', 'RT'
            });
        
        parads_short_all = [
            Data.Consts.beep_parads, ...
            Data.Consts.dtb_parads_short
            ];
        
        data_file_types_dtb = {'orig', 'addEn', 'addCols'};
        
        rt_fields = {'SDT_ClockOn', 'RT'}
    end
end