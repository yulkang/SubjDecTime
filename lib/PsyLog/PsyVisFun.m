classdef PsyVisFun < PsyVis
   properties
       f = [];
       f_out = [];
       max_n = [];
   end
   
   methods
       function VisFun = PsyVisFun(cScr, f)
           VisFun = VisFun@PsyVis;
           
           if nargin >= 1, VisFun.Scr = cScr; end
           if nargin >= 2
               VisFun.f = f;
               
               if n_out > 0
                   initLogEntries(VisFun, 'valCell', 'f_out', 'fr', 1);
               end
           end
       end
       
       function initLogTrial(VisFun)
           try
               VisFun.fouts = cell(1, VisFun.nFun);
               
               % Default maxN is frame number.
               if isempty(VisFun.max_n)
                   VisFun.maxN_.fouts = VisFun.Scr.maxN_.fr;
               end
               
               initLogTrial@PsyVis(VisFun);
               
           catch err
               warning('PsyVisFun:initLogTrial', err_msg(err));
           end
       end
       
       function update(VisFun, from)
           
           if VisFun.visible % Use show & hide to enable/disable functions.
               Scr = VisFun.Scr;
               VisFun.f_out = VisFun.f(Scr, from);
               addLog(VisFun, 'f_out', Scr.cFr, VisFun.f_out);
           end
       end
       
       function draw(~)
           % Don't do anything.
       end
   end
end