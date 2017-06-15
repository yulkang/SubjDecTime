classdef DataChRtPdfRaw < Fit.Common.DataChRtPdf
methods
    function load_data(Dat)
        pth = Dat.get_path;
        if Dat.is_loaded
            fprintf('FitData.load_data: Loaded already. Skipping loading %s\n', ...
                pth);
            return; 
        end
        
        if isempty(pth), return; end
        
        if ~is_in_parallel
            fprintf('Loading %s\n', pth);
        end
        L = load(pth);
        dsTr = L.obTr; % Raw does not choose successful trials. Uses all.
        G = L.G;
%         [sTr, G] = Data.exclOutliers(L.Expr, 'obTr');
        if isempty(dsTr)
            error('No trial is read!\n');
        end
        
        Dat.set_general_info(G);
        Dat.max_t = Dat.general_info.tClockDur;
        
        Dat.set_ds0(dsTr);
        
        Dat.reset_cache;
        Dat.loaded = true;
        Dat.filt_ds;
    end
end
end