initLog(Scr);
setEpoch(Scr,'begin');

while true

    switch Scr.epoch
        case 'begin'
            show(FP);
            show(Targ);

            [verdict args] = Scr.wait('from', prevTrialEnd + 1, ...
                                      'for',  1, ...
                                      'read', Fix);
            
            switch verdict
                case 'fixAcq'
                    setEpoch(Scr, 'motion');
            end
            
            
        case 'motion'
            
            
            
        case 'feedback'
            setEpoch(Scr, 'feedbackSDT');
            
            
        case 'feedbackSDT'
            
            
        case 'end'
            break;
    end
    
    
    switch verdict
        case 'timeOut'
            setEpoch(Scr, 'feedback');
    end
end

Scr.closeLog;