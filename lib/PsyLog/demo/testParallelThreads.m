function varargout = testParallelThreads

  obj = createJob();                                   %# Create a job
  task = createTask(obj,@get_input,4);  %# Create a task
  submit(obj);                                         %# Submit the job
  waitForState(task,'running');  %# Wait for the task to start running

  tt = 0;
  
  %# Initialize your stimulus display here
  while ~strcmp(get(task,'State'),'finished')  %# Loop while the task is running
    %# Update your stimulus display here
    
    tt = tt + 1;
  end
  
  disp(tt);

  varargout = get(task,'OutputArguments');  %# Get the outputs from the task
  destroy(obj);                             %# Remove the job from memory

%#---Nested functions below---

  function [keyIsDown,secs,keyCode,deltaSecs] = get_input
    keyIsDown = false;
    while ~keyIsDown  %# Keep looping until a key is pressed
      [keyIsDown,secs,keyCode,deltaSecs] = KbCheck;
    end
  end

end
