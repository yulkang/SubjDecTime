classdef Print
    properties (Constant)
        width_column1_cm = 8.7; % 8.9;
        width_column1_5_cm = 11.4; % 1.5 column
        width_column2_cm = 17.8; % 18.3;
        height_max_cm = 24.7;
        dpi = 300; 
        
        C_print = {
            'PaperPosition', [-0.2068 0.2097 21.4136 29.2806]
            'PaperUnits', 'centimeters'
            'PaperSize', [21.0000 29.7000]
            }
    end
end