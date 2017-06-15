classdef PsyTSeries < timeseries
    methods
        function me = PsyTSeries(varargin)
            me = me@timeseries(varargin{:});
        end
        
        
        function dst = smoothTSView(src, varargin)
            % SMOOTHTSVIEW
            %
            % See also SMOOTHTS.

            dst = smoothTS(src, varargin{:});

            subplot(2,2,1);
            plot(src); hold on; plot(dst); hold off;

            dif = src;
            dif.Data = dst.Data - src.Data;

            subplot(2,2,3);
            plot(dif);

            dSrc = diffTS(src);
            dDst = diffTS(dst);

            subplot(2,2,2);
            plot(dSrc); hold on; plot(dDst); hold off;

            dDif = dSrc;
            dDif.Data = dDst.Data - dSrc.Data;

            subplot(2,2,4);
            plot(dDif);
        end
        
        
        function me = timeseries(me)
            
        end
    end
end