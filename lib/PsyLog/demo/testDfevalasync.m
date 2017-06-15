function testDfevalasync
% testDfevalasync

    KbSpace = KbName('space');
    
    cJob = createJob();
    task = createTask(cJob, @getUntilKb, 1, cell(1,0));
    submit(cJob);
%     while ~strcmp(get(task, 'State'), 'running')
%         WaitSecs(0.001);
%     end
    tic;
    
    ii = 0;
    disp(1);
    while ~strcmp(get(task, 'State'), 'finished')
        ii = ii + 1;
        WaitSecs(0.001);
    end
    
    toc;
    disp(ii);


    function secs = getUntilKb
%         finished = false;
%         
%         while ~finished
%             [~, secs, keyCode] = KbCheck;
% 
%             finished = (keyCode(KbSpace) == 1);
%         end
        secs = 0;        
        stT = GetSecs;
        while GetSecs - stT < 2
            WaitSecs(0.001);
        end
        secs = 2;
    end
end