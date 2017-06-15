% This version works with the Rasputin 2.5.0 or newer version. If older
% version is used, change the "handles.getTrueVoltage" to zero.

function varargout = TriggeredLFPClient(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TriggeredLFPClient_OpeningFcn, ...
                   'gui_OutputFcn',  @TriggeredLFPClient_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
    
gui_State.gui_Name = 'TriggeredLFPClient'; 

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


% End initialization code - DO NOT EDIT

function TriggeredLFPClient_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    handles.getTrueVoltage = 1;
    handles.S1 = [];
    handles.PARS1 = [];
    handles.CONNECTED1  = [];
    handles.RUNNING1 = [];
    handles.lfp_ave = [];
    handles.Numfigs = 0;
    handles.h = gcf;
    handles.tstep = 1000;
    handles.Fs = 1000;
    handles.STFTstep = 0.01;    
    handles.FourierN = 2048;    
    handles.myPSD = 0;
    handles.flag4avg = 0;
    handles.flag4event = 0;
    handles.Connect = 0;
    handles.stopped = 0;
    handles.dd = 0;
    handles.tt = 0;
    handles.refreshFlag = 0;
    handles.P = 0;
    handles.timeaxis = 0;
    handles.FreqVect = 0;
    handles.PlottedData = 0;
    set(handles.fouri_epon,'Value',1)
    set(handles.text1,'String','# Events Accumulated');
    set(handles.text2,'String','Event Channel');
    set(handles.SpikeUnit,'Value',1);
    set(handles.SpikeUnit,'String','Unsorted');
    set(handles.SpikeUnit,'Enable','off');
    set(handles.eventBox,'Enable','on');
    set(handles.ExpertMode,'Value',0)
    if get(handles.ExpertMode,'Value')
        set(handles.text6,'Enable','on')
        set(handles.pre,'Enable','on')
        set(handles.post,'Enable','on')
        set(handles.text15,'Enable','on')
        set(handles.win_shape,'Enable','on')
        set(handles.text14,'Enable','on')
        set(handles.hannwidth,'Enable','on')
        set(handles.text13,'Enable','on')
        set(handles.step_size,'Enable','on')
        set(handles.text12,'Enable','on')
        set(handles.frequency_end,'Enable','on')
        set(handles.text21,'Enable','on')
        set(handles.frequency_start,'Enable','on')
        set(handles.SpectShading,'Enable','on')
        set(handles.text32,'Enable','on')
        set(handles.SpectShading,'Value',2)
    else
        set(handles.text6,'Enable','off')
        set(handles.pre,'Enable','off')
        set(handles.post,'Enable','off')
        set(handles.text15,'Enable','off')
        set(handles.win_shape,'Enable','off')
        set(handles.text14,'Enable','off')
        set(handles.hannwidth,'Enable','off')
        set(handles.text13,'Enable','off')
        set(handles.step_size,'Enable','off')
        set(handles.text12,'Enable','off')
        set(handles.frequency_end,'Enable','off')
        set(handles.text21,'Enable','off')
        set(handles.frequency_start,'Enable','off')
        set(handles.SpectShading,'Enable','off')
        set(handles.text32,'Enable','off')
        set(handles.SpectShading,'Value',2)
    end
    set(handles.numEvents,'String',0);
    set(handles.eventBox,'String',2);
    set(handles.SpectSelectButton,'Enable','on')
    set(handles.PSDSelectButton,'Enable','on')
    set(handles.SpectSelectButton,'Value',1)
    set(handles.PSDSelectButton,'Value',0)
    set(handles.logPSD,'Visible','off');
    set(handles.logPSD,'Enable','on')
    set(handles.text30,'Visible','off');
    set(handles.logPSD,'Value',1);
    set(handles.uipanel3,'Title','Spectrogram Options')
    set(handles.Time_plot,'XLim',[-0.5 0.5])
    set(handles.Time_plot,'YLim',[0 1])
    set(handles.Spectrogram_plot,'XLim',[-0.475 0.475])
    xlabel(handles.Spectrogram_plot,'Time (Sec)')
    set(handles.Spectrogram_plot,'YLim',[0 500])
    ylabel(handles.Spectrogram_plot,'Frequency (Hz)')
    set(handles.ADchanList,'Enable','on')
    set(handles.mode,'Enable','on')
    set(handles.NumEvents2Plot,'Enable','on')
    set(handles.NotchFilter,'Enable','on')
    set(handles.samplingFreq,'String',0)
    set(handles.redrawButton,'Enable','off')
    set(handles.EEGmode,'Value',0)
    set(handles.EEGmode,'Enable','off')
    set(handles.EEGtext,'Enable','off')

    set(handles.dialogBox,'String','Please connect to server')
    handles.spectPosition = get(handles.Spectrogram_plot,'Position');
    guidata(hObject, handles);

    cla(handles.Time_plot);
    cla(handles.Spectrogram_plot);


function varargout = TriggeredLFPClient_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TriggeredLFPClientFns(handles, hObject)

    global stopped
    
    switch handles.action

        case 'connect'
            
            if ~isempty(handles.RUNNING1) | ~isempty(handles.CONNECTED1)
                dialogString = char('Already Connected to Server');
                set(handles.dialogBox,'String',dialogString);
                set(handles.DisConBtn,'Enable','on')
                set(handles.ConnectBtn,'Enable','off')
                return
            end
            handles.S1 = 0;
            handles.S1 = PL_InitClient(0);
            
            handles.counts = PL_GetNumUnits(handles.S1);
            if handles.S1 ~=  0
                handles.CONNECTED1 = 1;
                dialogString = char('Connected to Server');
                set(handles.dialogBox,'String',dialogString);
                handles.PARS1 = PL_GetPars(handles.S1);
                tmpPARS1 = handles.PARS1(270:525);
                handles.activeChans = tmpPARS1(find(tmpPARS1~=0));
                set(handles.ADchanList,'Value',1);
                set(handles.ADchanList,'String',char(num2str(handles.activeChans)))
                set(handles.ADchanList,'Value',1);
                ADchan = get(handles.ADchanList,'Value');
                ADchanIndex = find(handles.activeChans==ADchan);
                tmpStr4chan = get(handles.ADchanList,'String');
                handles.Fs = handles.PARS1(14:13+length(tmpStr4chan));
                try
                    handles.ADGains = PL_GetADGains(handles.S1);
                catch
                    errordlg('The Rasputin version id older than 2.5.0. You cannot get actual voltage values!','Old Version!')
                    handles.getTrueVoltage = 0;
                end
                SetSamplingFreq(handles,ADchanIndex);
                set(handles.frequency_end,'String',min(fix(handles.Fs(ADchanIndex)/2),str2num(get(handles.frequency_end,'String'))));
                CentralFreq_Callback(hObject, [], handles);
                set(handles.DisConBtn,'Enable','on')
                set(handles.ConnectBtn,'Enable','off')
                if (length(get(handles.StartButton,'Enable')) == 3) 
                    set(handles.StartButton,'Enable','on')
                end
            end
            
            guidata(hObject, handles);

        case 'disconnect'

            if ~isempty(handles.RUNNING1)
                handles.action = 'stop';
                TriggeredLFPClientFns(handles, hObject);
                pause(0.5);
            end
            if ~isempty(handles.CONNECTED1)
                dialogString=char('Disconnected from Server');
                set(handles.dialogBox,'String',dialogString);
                PL_Close(handles.S1);
                handles.S1=[];
                handles.CONNECTED1=[];
                handles.RUNNING1 = [];
            end
            set(handles.StopButton, 'Value', 0);
            set(handles.ConnectBtn,'Enable','on')
            set(handles.DisConBtn,'Enable','off')
            ResetSamplingFreq(handles);

            guidata(hObject, handles);

        case 'stop'

            if ~isempty(handles.RUNNING1)
                dialogString=char('Stopped Plotting');
                set(handles.dialogBox,'String',dialogString);
            else
                set(handles.StopButton, 'Value', 0);
            end
            stopped = 1;
            handles.RUNNING1 = [];
            guidata(hObject, handles);

        case 'plot'
            
            if isempty(handles.CONNECTED1)
                dialogString=char('Error: First Connect to Server');
                set(handles.dialogBox,'String',dialogString);
                return
            end
            if ~isempty(handles.RUNNING1)
                return
            end
            
            dialogString = char('Plotting AD Data');
            set(handles.dialogBox,'String',dialogString);
            handles.RUNNING1 = 1;
            stopped = 0;
            counter=0;
            temp_eventCue = [];
            temp_tt = [];
            temp_dd = [];
            handles.F = [];
            NumADchan = handles.PARS1(7);
            handles.NumChan2Plot = 1;
            Fs = handles.PARS1(8); 
            handles.lfp_pre = GetPreTime(handles); 
            handles.lfp_post = GetPostTime(handles); 
            event = GetEvent(handles); 
            spikeUnit = GetUnit(handles);
            ADchan = GetADchan(handles);
            ADchanIndex = find(handles.activeChans==ADchan);
            handles.eventCue = [];
            totNumEvents = 0 ;
            totNumPlots = 0;
            SetNumEvents(totNumEvents, handles)
            S = GetNum2Plot(handles);
            handles.counts = PL_GetNumUnits(handles.S1);
            handles.userdata = 0;
            handles.FreqVect = 0; 
            T = 0;
            handles.P = 0;
            handles.timeaxis = 0;
            handles.myPSD = 0;
            handles.flag4avg = 0;
            if ~isempty(handles.eventCue)
                temp_eventCue = handles.eventCue(1);
            end
            if ~isempty(handles.tt)
                temp_tt = handles.tt;
            end
            if ~isempty(handles.dd)
                temp_dd = handles.dd;
            end
            handles.dd = 0;
            
            [num,ts] = PL_GetTS(handles.S1);
                    
            [n,t,d] = PL_GetADEx(handles.S1);
            if handles.getTrueVoltage
                for i = 1 : length(n)
                    d(:,i) = d(:,i)/2048*5/handles.ADGains(handles.activeChans(i));
                end
            end
            if Average(handles)<2
                handles.lfp_ave = zeros(round((handles.lfp_pre+handles.lfp_post)*handles.Fs(ADchanIndex)+1),1);
                handles.userdata = handles.lfp_ave;
                handles.lfp_start = 0;
                handles.lfp_stop = 0;
            elseif Average(handles)==2
                handles.lfp_ave = zeros(round((handles.lfp_pre+handles.lfp_post)*max(handles.Fs)+1),NumADchan);
                handles.userdata = handles.lfp_ave;
                handles.lfp_start = zeros(1,NumADchan);
                handles.lfp_stop = zeros(1,NumADchan);
                for i = 1 : NumADchan
                    Len(i) = round((handles.lfp_pre+handles.lfp_post)*handles.Fs(i)+1);
                end
            end
            
            if get(handles.NotchFilter, 'Value') ==2
                notchFreq = 50;
                const1 = 2;
                const2 = 3;
            elseif get(handles.NotchFilter, 'Value') ==3
                notchFreq = 60;
                const1 = 3;
                const2 = 3;
            end
            
            if get(handles.NotchFilter, 'Value') ~=1
                if get(handles.mode,'Value') <3
                    w0 = notchFreq/handles.Fs(ADchanIndex)*2;
                    bw = const1/handles.Fs(ADchanIndex)*2;
                    nbw = bw*pi;
                    nw0 = w0*pi;
                    g = 10^(-const2/20);
                    tmp = tan(nbw/2)*(sqrt(1-g^2)/g);
                    G = 1/(1+tmp);
                    bCoeffs = G*[1 -2*cos(nw0) 1];
                    aCoeffs = [1 -2*G*cos(nw0) (2*G-1)];
                else
                    for i = 1 : NumADchan
                        w0 = notchFreq/handles.Fs(i)*2;
                        bw = const1/handles.Fs(i)*2;
                        nbw = bw*pi;
                        nw0 = w0*pi;
                        g = 10^(-const2/20);
                        tmp = tan(nbw/2)*(sqrt(1-g^2)/g);
                        G = 1/(1+tmp);
                        bCoeffs(:,i) = G*[1 -2*cos(nw0) 1];
                        aCoeffs(:,i) = [1 -2*G*cos(nw0) (2*G-1)];
                    end
                end
            end
            
            SpikeUnitString = get(handles.SpikeUnit,'String');
            
            while ~get(handles.StopButton, 'Value') & ~stopped 
                
                serverEventIn = 0;
                while serverEventIn == 0
                    if get(handles.StopButton, 'Value') | (~handles.Connect) | (stopped)
                        set(handles.StopButton, 'Value',1);
                        return
                    end
                    pause(handles.lfp_pre+handles.lfp_post*2); 
                    try
                        serverEventIn = PL_WaitForServer(handles.S1,5000);
                    catch
                        errordlg('Cannot get data from the server!');
                        return
                    end
                end
                nn = n; 
                handles.tt = t;
                if (get(handles.mode,'Value')==3)
                    handles.dd = d;
                else
                    handles.dd = d(:,ADchanIndex);
                end
                [num,ts] = PL_GetTS(handles.S1);
                [n,t,d] = PL_GetADEx(handles.S1);
                if handles.getTrueVoltage
                    for i = 1 : length(n)
                        d(:,i) = d(:,i)/2048*5/handles.ADGains(handles.activeChans(i));
                    end
                end

                if get(handles.NotchFilter, 'Value')~=1
                    try
                        if get(handles.mode,'Value') <3
                            d(1:n(ADchanIndex),ADchanIndex) = filtfilt(bCoeffs, aCoeffs,  d(1:n(ADchanIndex),ADchanIndex));
                        elseif get(handles.mode,'Value') ==3
                            for i = 1 : NumADchan
                                d(1:n(i),i) = filtfilt(bCoeffs(:,i), aCoeffs(:,i),  d(1:n(i),i));
                            end
                        end
                    catch
                        if(~handles.F) 
                            handles.F = 1;
                            guidata(hObject, handles);
                            errordlg('The difference between pre and post times must be at least 1.3 seconds long');
                        end
                    end
                end
                
                if (get(handles.eventsButton,'Value') ==1) & ~stopped
                    if (get(handles.mode,'Value') == 1)
                        event = GetEvent(handles); 
                    end
                    handles.eventCue = [handles.eventCue; (ts(find((ts(:,1) ==4).*(ts(:,2) ==event)),4))];
                    kk = 0;
                elseif (get(handles.spikesButton,'Value') ==1) & ~stopped   
                    if (get(handles.mode,'Value') == 1)
                        spikeUnit = GetUnit(handles); 
                    end
                    handles.eventCue = [handles.eventCue; ( ts(find( ((ts(:,1) ==1).*(ts(:,2) ==event)) .* (ts(:,3) ==spikeUnit)) , 4))];
                end
                
                mxn = max(n);
                mxnn = max(nn);
                
                if ~stopped
                    if (get(handles.mode,'Value')==3)
                        try
                            handles.dd = [handles.dd;d];
                        catch
                            errordlg('Out of memory!');
                            stopped = 1;
                            break;
                        end
                        for i = 1 : NumADchan
                            if nn(i)+n(i)<mxnn+mxn
                                handles.dd((nn(i)+1):(nn(i)+n(i)),i) = d(1:n(i),i);
                                handles.dd((nn(i)+n(i)+1):(mxnn+mxn),i) = 0;
                            end
                        end
                    else
                        try
                            handles.dd = [handles.dd;d(:,ADchanIndex)];
                        catch
                            errordlg('Out of memory!');
                            stopped = 1;
                            break;
                        end
                        if nn(ADchanIndex)+n(ADchanIndex)<mxnn+mxn
                            handles.dd((nn(ADchanIndex)+1):(nn(ADchanIndex)+n(ADchanIndex)),1) = d(1:n(ADchanIndex),ADchanIndex);
                            handles.dd((nn(ADchanIndex)+n(ADchanIndex)+1):(mxnn+mxn),1) = 0;
                        end
                    end
                end
                
                nn=nn+n;
                temp_start = 0;
                temp_stop = 0;
                counter=0;
                
                while ~get(handles.StopButton, 'Value') & length(handles.eventCue)>0 & (ceil((handles.tt+(nn(ADchanIndex)-1)/handles.Fs(ADchanIndex)-handles.eventCue(1))*handles.Fs(ADchanIndex))/handles.Fs(ADchanIndex) > handles.lfp_post ) & handles.Connect & ~stopped
                    
                    counter = counter +1;
                    ADchan = GetADchan(handles);
                    ADchanIndex = find(handles.activeChans==ADchan);
                    if (get(handles.spikesButton,'Value') ==1)
                        tmpStruct = get(handles.SpikeUnit,'String');
                        tmpStr = ['Spike Channel ' get(handles.eventBox,'String') '-' char(tmpStruct(get(handles.SpikeUnit,'Value')))];
                    elseif (get(handles.eventsButton,'Value') ==1)
                        tmpStr = ['Event Channel ' get(handles.eventBox,'String')];
                    end
                    dialogString = ['Plotting AD # ' num2str(ADchan) ' Data for ' tmpStr ];
                    set(handles.dialogBox,'String',dialogString);
                    %---------------- Time Domain Signal ---------------
                    temp_eventCue = handles.eventCue(1);
                    temp_tt = handles.tt;
                    temp_dd = handles.dd;
                    
                    if Average(handles)<2
                        handles.lfp_start = round((handles.eventCue(1) - handles.lfp_pre - handles.tt) * handles.Fs(ADchanIndex)) + 1;
                        handles.lfp_stop = handles.lfp_start + (handles.lfp_pre+handles.lfp_post)*handles.Fs(ADchanIndex);
                    elseif Average(handles)==2
                        for i = 1 : NumADchan
                            handles.lfp_start(i) = round((handles.eventCue(1) - handles.lfp_pre - handles.tt) * handles.Fs(i)) + 1;
                            handles.lfp_stop(i) = handles.lfp_start(i) + (handles.lfp_pre+handles.lfp_post)*handles.Fs(i);
                        end
                    end
                    
                    if any(handles.lfp_start<=0)
                        errordlg('Low Memory-Mapped File (MMF) Size! Please increase the MMF size.');
                        stopped = 1;
                        break;
                    end
                    
                    if (get(handles.spikesButton,'Value') ==1) | (get(handles.eventsButton,'Value') ==1)
                        if (((handles.lfp_start + handles.lfp_stop)/2) < temp_stop)
                            continueFlag = 0; 
                        else
                            temp_start = handles.lfp_start;
                            temp_stop = handles.lfp_stop;
                            continueFlag = 1;  
                        end
                    end
                    
                    if continueFlag     
                        
                        totNumEvents = totNumEvents + 1;
                        
                        if Average(handles)
                            if ~handles.flag4avg
                                totNumEvents = 1;
                            end
                            if Average(handles)==1
                                handles.lfp_ave = ((totNumEvents-1)*handles.lfp_ave*handles.flag4avg + handles.dd(handles.lfp_start:handles.lfp_stop,:))/totNumEvents;
                            elseif Average(handles)==2
                                for i = 1 : NumADchan
                                    handles.lfp_ave(1:Len(i),i) = ((totNumEvents-1)*handles.lfp_ave(1:Len(i),i)*handles.flag4avg + handles.dd(handles.lfp_start(i):handles.lfp_stop(i),i))/totNumEvents;
                                end
                            end
                        else
                            if handles.flag4avg
                                totNumEvents = 1;
                            end
                            handles.lfp_ave = handles.dd(handles.lfp_start:handles.lfp_stop,:);
                        end
                        
                        x = -handles.lfp_pre : 1/handles.Fs(ADchanIndex) : handles.lfp_post;
                        if get(handles.mode,'Value') <3 
                            y = handles.lfp_ave(:,1);
                        elseif get(handles.mode,'Value') ==3
                            y = handles.lfp_ave(1:Len(ADchanIndex),ADchanIndex);
                        end
                        figure(handles.h); 
                        newplot(handles.Time_plot)
                        axes(handles.Time_plot)
                        if handles.getTrueVoltage
                            if max(abs(y))>0.001
                                plot(handles.Time_plot, x,1000*y,'b')
                                ylabel('Voltage (mV)','VerticalAlignment','middle')
                            elseif max(abs(y))<0.001
                                plot(handles.Time_plot, x,1000000*y,'b')
                                ylabel('Voltage (uV)','VerticalAlignment','middle')
                            end
                        else
                            plot(handles.Time_plot, x,y,'b')
                            ylabel('Amplified Voltage','VerticalAlignment','middle')
                        end
                        hold(handles.Time_plot,'on')
                        set(handles.Spectrogram_plot,'AmbientLightColor','white');
                        set(handles.Spectrogram_plot, 'color', 'white');
                        set(handles.Time_plot,'XLim',[-handles.lfp_pre handles.lfp_post])
                        ylimTime = get(handles.Time_plot,'YLim');
                        figure(handles.h);
                        plot(handles.Time_plot, x*0,[ones(1,length(y)-1)*ylimTime(1),ylimTime(2)],'k:')
                        xlabel('Time (sec)');
                        set(handles.Time_plot,'AmbientLightColor','white');
                        set(handles.Time_plot,'XTick',-handles.lfp_pre : (handles.lfp_pre + handles.lfp_post)/10 : handles.lfp_post)
                        
                        hold(handles.Time_plot,'off')
                        %------------------- Calculate the Spectrogram ----------------
                        
                        if get(handles.mode,'Value') <3
                            handles.userdata = handles.dd(handles.lfp_start:handles.lfp_stop,1); 
                            if get(handles.DCRemoval,'Value')
                                handles.userdata = handles.userdata - mean(handles.userdata);
                            end
                            handles.NumChan2Plot = 1;
                        elseif get(handles.mode,'Value') ==3 
                            for i = 1 : NumADchan
                                handles.userdata(1:Len(i),i) = handles.dd(handles.lfp_start(i):handles.lfp_stop(i),i);
                                if get(handles.DCRemoval,'Value')
                                    handles.userdata(1:Len(i),i) = handles.userdata(1:Len(i),i) - mean(handles.userdata(1:Len(i),i));
                                end
                            end
                            handles.NumChan2Plot = NumADchan;
                        end
                        
                        handles.winWidth = str2num(get(handles.hannwidth, 'String'));
                        
                        if get(handles.SpectSelectButton,'Value') & ~get(handles.PSDSelectButton,'Value')
                            if get(handles.mode,'Value') <3
                                handles.winN = handles.winWidth * handles.Fs(ADchanIndex);  
                                handles.STFTstep = str2num(get(handles.step_size, 'String'));
                                handles.noverlap = handles.winN - handles.STFTstep*handles.Fs(ADchanIndex); 
                            elseif get(handles.mode,'Value') ==3
                                handles.winN = handles.winWidth * handles.Fs;  
                                winLen = max(handles.winN);
                                handles.win = zeros(winLen,NumADchan);
                                handles.STFTstep = str2num(get(handles.step_size, 'String'));
                                handles.noverlap = handles.winN - handles.STFTstep*handles.Fs; 
                            end
                        elseif ~get(handles.SpectSelectButton,'Value') & get(handles.PSDSelectButton,'Value')
                            if get(handles.mode,'Value') <3
                                handles.winN = length(handles.userdata(:,1));
                            elseif get(handles.mode,'Value') ==3
                                handles.winN = Len;
                            end
                        end
                        
                        if get(handles.mode,'Value') <3
                            if get(handles.win_shape, 'Value') == 1
                                handles.win = hann(handles.winN);          
                            elseif get(handles.win_shape, 'Value') == 2
                                handles.win = hamming(handles.winN);       
                            elseif get(handles.win_shape, 'Value') == 3
                                handles.win = blackman(handles.winN);      
                            elseif get(handles.win_shape, 'Value') == 4
                                handles.win = chebwin(handles.winN);       
                            elseif get(handles.win_shape, 'Value') == 5
                                handles.win = flattopwin(handles.winN);    
                            elseif get(handles.win_shape, 'Value') == 6
                                handles.win = gausswin(handles.winN);      
                            end
                        elseif get(handles.mode,'Value') ==3
                            for i = 1 : NumADchan
                                if get(handles.win_shape, 'Value') == 1
                                    handles.win(1:handles.winN(i),i) = hann(handles.winN(i));
                                elseif get(handles.win_shape, 'Value') == 2
                                    handles.win(1:handles.winN(i),i) = hamming(handles.winN(i));
                                elseif get(handles.win_shape, 'Value') == 3
                                    handles.win(1:handles.winN(i),i) = blackman(handles.winN(i));
                                elseif get(handles.win_shape, 'Value') == 4
                                    handles.win(1:handles.winN(i),i) = chebwin(handles.winN(i));
                                elseif get(handles.win_shape, 'Value') == 5
                                    handles.win(1:handles.winN(i),i) = flattopwin(handles.winN(i));
                                elseif get(handles.win_shape, 'Value') == 6
                                    handles.win(1:handles.winN(i),i) = gausswin(handles.winN(i));
                                end
                            end
                        end

                        figure(handles.h);
                        set(handles.Spectrogram_plot,'AmbientLightColor','white');
                        handles.FourierN = 2^(get(handles.fouri_epon,'Value') + 3);
                        if get(handles.SpectSelectButton,'Value') & ~get(handles.PSDSelectButton,'Value')
                            
                            if get(handles.mode,'Value') <3
                                
                                for i = 1 : handles.NumChan2Plot

                                    if i == 1
                                        if get(handles.fouri_epon,'Value')==1
                                            tmpL = length(handles.win);
                                            [Spect,handles.FreqVect,T,handles.P] = spectrogram(handles.userdata(:,i),handles.win,handles.noverlap,tmpL,handles.Fs(ADchanIndex));
                                        else
                                            [Spect,handles.FreqVect,T,handles.P] = spectrogram(handles.userdata(:,i),handles.win,handles.noverlap,handles.FourierN,handles.Fs(ADchanIndex));
                                        end
                                        f1 = str2num(get(handles.frequency_start, 'String'));
                                        f2 = str2num(get(handles.frequency_end, 'String'));
                                        freqIndex = find((handles.FreqVect>=f1) .* (handles.FreqVect<=f2));
                                        NumUniquePts(i) = length(handles.FreqVect);
                                        T = T';
                                        handles.P(:,:,i) = handles.P;
                                        T(:,1) = T;
                                        if (totNumEvents == 1)
                                            handles.myPSD = handles.P(:,:,i);
                                        end
                                    else
                                        if get(handles.fouri_epon,'Value')==1
                                            tmpL = length(handles.win);
                                            [Spect,handles.FreqVect(:,i),T(:,i),handles.P(:,:,i)] = spectrogram(handles.userdata(:,i),handles.win,handles.noverlap,tmpL,handles.Fs(ADchanIndex));
                                        else
                                            [Spect,handles.FreqVect(:,i),T(:,i),handles.P(:,:,i)] = spectrogram(handles.userdata(:,i),handles.win,handles.noverlap,handles.FourierN,handles.Fs(ADchanIndex));
                                        end
                                        f1 = str2num(get(handles.frequency_start, 'String'));
                                        f2 = str2num(get(handles.frequency_end, 'String'));
                                        freqIndex = find((handles.FreqVect>=f1) .* (handles.FreqVect<=f2));
                                        NumUniquePts(i) = length(handles.FreqVect(:,i));
                                    end
                                    handles.timeaxis = linspace(-handles.lfp_pre,handles.lfp_post, length(T(:,i)));
                                    if Average(handles)
                                        if ~handles.flag4avg
                                            totNumEvents = 1;
                                        end
                                        if (totNumEvents == 1)
                                            handles.myPSD(:,:,i) = handles.P(:,:,i);
                                        else
                                            handles.myPSD(:,:,i) = ((totNumEvents-1)*handles.myPSD(:,:,i)*handles.flag4avg + handles.P(:,:,i))/totNumEvents;
                                        end
                                        handles.flag4avg = 1;
                                    else
                                        handles.myPSD = zeros(size(handles.P(:,:,i)));
                                        if handles.flag4avg
                                            totNumEvents = 1;
                                        end
                                        handles.myPSD(:,:,i) = handles.P(:,:,i);
                                        handles.flag4avg = 0;
                                    end

                                end
                                
                            elseif get(handles.mode,'Value') ==3

                                [mx mxInd] = max(Len);
                                if get(handles.fouri_epon,'Value')==1
                                    tmpL = length(handles.win(1:handles.winN(mxInd),mxInd));
                                    [Spect,handles.FreqVect,T,handles.P] = spectrogram(handles.userdata(1:Len(mxInd),mxInd),handles.win(1:handles.winN(mxInd),mxInd),handles.noverlap(mxInd),tmpL,handles.Fs(mxInd));
                                else
                                    [Spect,handles.FreqVect,T,handles.P] = spectrogram(handles.userdata(1:Len(mxInd),mxInd),handles.win(1:handles.winN(mxInd),mxInd),handles.noverlap(mxInd),handles.FourierN,handles.Fs(mxInd));
                                end
                                T = T';
                                f1 = str2num(get(handles.frequency_start, 'String'));
                                f2 = str2num(get(handles.frequency_end, 'String'));
                                freqIndex = find((handles.FreqVect>=f1) .* (handles.FreqVect<=f2));
                                handles.FreqVect = handles.FreqVect(freqIndex);
                                handles.P = zeros(size(handles.P(freqIndex,:)));
                                handles.P(:,:,NumADchan) = 0;
                                handles.FreqVect(:,1) = zeros(size(handles.FreqVect));
                                handles.FreqVect(:,NumADchan) = zeros(size(handles.FreqVect));
                                T(:,1) = zeros(size(T));
                                T(:,NumADchan) = zeros(size(T));
                                if (totNumEvents == 1)
                                    handles.myPSD = zeros(size(handles.P(:,:,1:NumADchan)));
                                end
                                
                                for i = 1 : handles.NumChan2Plot

                                    if get(handles.fouri_epon,'Value')==1
                                        tmpL = length(handles.win(1:handles.winN(i),i));
                                        [Spect,tmpFreqVect,tmpT,tmpP] = spectrogram(handles.userdata(1:Len(i),i),handles.win(1:handles.winN(i),i),handles.noverlap(i),tmpL,handles.Fs(i));
                                    else
                                        [Spect,tmpFreqVect,tmpT,tmpP] = spectrogram(handles.userdata(1:Len(i),i),handles.win(1:handles.winN(i),i),handles.noverlap(i),handles.FourierN,handles.Fs(i));
                                    end
                                    freqIndex = find((tmpFreqVect>=f1) .* (tmpFreqVect<=f2));
                                    handles.FreqVect(1:length(tmpFreqVect),i) = tmpFreqVect;
                                    NumUniquePts(i) = length(tmpFreqVect);
                                    tmpFreqVect = tmpFreqVect(freqIndex);
                                    T(1:length(tmpT),i) = tmpT;
                                    handles.P(1:length(tmpFreqVect),1:length(tmpT),i) = tmpP(freqIndex,:);
                                    handles.timeaxis = linspace(-handles.lfp_pre,handles.lfp_post, length(T(:,i)));
                                    if Average(handles)
                                        if ~handles.flag4avg
                                            totNumEvents = 1;
                                        end
                                        if (totNumEvents == 1)
                                            handles.myPSD(:,:,i) = handles.P(:,:,i);
                                        else
                                            handles.myPSD(:,:,i) = ((totNumEvents-1)*handles.myPSD(:,:,i)*handles.flag4avg + handles.P(:,:,i))/totNumEvents;
                                        end
                                        handles.flag4avg = 1;
                                    else
                                        handles.myPSD = zeros(size(handles.P(:,:,i)));
                                        if handles.flag4avg
                                            totNumEvents = 1;
                                        end
                                        handles.myPSD(:,:,i) = handles.P(:,:,i);
                                        handles.flag4avg = 0;
                                    end

                                end
                                
                            end
                            
                            if handles.NumChan2Plot == 1
                                index = 1;
                            else
                                index = ADchanIndex;
                            end
                            f1 = str2num(get(handles.frequency_start, 'String'));
                            f2 = str2num(get(handles.frequency_end, 'String'));
                            freqIndex = find((handles.FreqVect(1:NumUniquePts(index),index)>=f1) .* (handles.FreqVect(1:NumUniquePts(index),index)<=f2));
                            if Average(handles)==2
                                psd4view = handles.myPSD(1:length(freqIndex),:,index);
                            else
                                psd4view = handles.myPSD(freqIndex,:,index);
                            end
                            if str2num(get(handles.CentralFreq,'String'))~=0
                                siz = size(psd4view);
                                for i = 1 : siz(2)
                                    ff = find(psd4view(:,i)<.01*min(max(psd4view)));
                                    psd4view(ff,i) = min(max(psd4view))/100;
                                end
                            end
                            axes(handles.Spectrogram_plot)
                            tmpStr = get(handles.SpectShading,'String');
                            shadingType = tmpStr(get(handles.SpectShading,'Value'),:);
                            displayspectrogram(handles.timeaxis,handles.FreqVect(freqIndex,index),psd4view,0,[ str2num(get(handles.frequency_start, 'String')) str2num(get(handles.frequency_end, 'String')) min(handles.timeaxis) max(handles.timeaxis)],shadingType);
                            colorbar;
                            set(handles.text30,'Visible','on');
                            axis([handles.FreqVect(freqIndex(1),index) handles.FreqVect(freqIndex(end),index) min(handles.timeaxis) max(handles.timeaxis)]); 
                            view(90,-90);
                            set(handles.Spectrogram_plot,'YTick',-handles.lfp_pre : (handles.lfp_pre + handles.lfp_post)/10 : handles.lfp_post)
                            if get(handles.EEGmode,'Value') & ~isempty(handles.lfp_ave) & (str2num(get(handles.FrequencyRes,'String'))<=1)
                                spectYLim = get(handles.Spectrogram_plot,'YLim');
                                text(2,spectYLim(2),'\delta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                                text(6,spectYLim(2),'\theta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                                text(10,spectYLim(2),'\alpha','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                                text(19,spectYLim(2),'\beta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                                text(63,spectYLim(2),'\gamma','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                                minVal = 10*log10(min(min(min(psd4view)))+eps);
                                hold(handles.Spectrogram_plot,'on')
                                tmpVect = [spectYLim(1):abs(spectYLim(2)-spectYLim(1))/50:spectYLim(2),spectYLim(2)];
                                deltamat = 4*ones(1,length(tmpVect));
                                plot3(deltamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                                thetamat = 8*ones(1,length(tmpVect));
                                plot3(thetamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                                alphamat = 12*ones(1,length(tmpVect));
                                plot3(alphamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                                betamat = 26*ones(1,length(tmpVect));
                                plot3(betamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                                gammamat = 100*ones(1,length(tmpVect));
                                plot3(gammamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                                hold(handles.Spectrogram_plot,'off')
                            end

                            
                        elseif ~get(handles.SpectSelectButton,'Value') & get(handles.PSDSelectButton,'Value')
                            
                            
                            if get(handles.mode,'Value') <3
                                
                                for i = 1 : handles.NumChan2Plot
                                    
                                    if get(handles.fouri_epon,'Value')==1
                                        tmpL = length(handles.userdata(:,i));
                                        FFTofWinData = fft(handles.userdata(:,i).*handles.win,tmpL);
                                        NumUniquePts(i) = ceil((tmpL + 1)/2);
                                    else
                                        FFTofWinData = fft(handles.userdata(:,i).*handles.win,handles.FourierN);
                                        NumUniquePts(i) = ceil((handles.FourierN + 1)/2);
                                    end
                                    FFTofWinData = FFTofWinData(1 : NumUniquePts(i));
                                    if (i == 1) 
                                        handles.P = abs(FFTofWinData).^2;
                                        handles.P(:,i) = handles.P;
                                        if (totNumEvents == 1)
                                            handles.myPSD = handles.P(:,i);
                                        end
                                    else
                                        handles.P(:,i) = abs(FFTofWinData).^2;
                                    end

                                    if Average(handles)
                                        if ~handles.flag4avg
                                            totNumEvents = 1;
                                        end
                                        if (totNumEvents == 1)
                                            handles.myPSD(:,i) = handles.P(:,i);
                                        else
                                            handles.myPSD(:,i) = ((totNumEvents-1)*handles.myPSD(:,i)*handles.flag4avg + handles.P(:,i))/totNumEvents;
                                        end
                                        handles.flag4avg = 1;
                                    else
                                        handles.myPSD = zeros(size(handles.P(:,i)));
                                        if handles.flag4avg
                                            totNumEvents = 1;
                                        end
                                        handles.myPSD(:,i) = handles.P(:,i);
                                        handles.flag4avg = 0;
                                    end

                                end
                            
                            elseif get(handles.mode,'Value') ==3
                                
                                [mx mxInd] = max(Len);
                                if get(handles.fouri_epon,'Value')==1
                                    tmpL = length(handles.userdata(1:Len(mxInd),mxInd));
                                    FFTofWinData = fft(handles.userdata(1:Len(mxInd),mxInd).*handles.win(1:handles.winN(mxInd),mxInd),tmpL);
                                    NumUniquePts(i) = ceil((tmpL + 1)/2);
                                else
                                    FFTofWinData = fft(handles.userdata(1:Len(mxInd),mxInd).*handles.win(1:handles.winN(mxInd),mxInd),handles.FourierN);
                                    NumUniquePts(i) = ceil((handles.FourierN + 1)/2);
                                end
                                FFTofWinData = FFTofWinData(1 : NumUniquePts(i));
                                handles.P = abs(FFTofWinData).^2;
                                handles.P(:,1) = zeros(size(handles.P));
                                handles.P(:,NumADchan) = zeros(size(handles.P));
                                if (totNumEvents == 1)
                                    handles.myPSD = zeros(size(handles.P(:,1:NumADchan)));
                                end
                                
                                for i = 1 : handles.NumChan2Plot
                                    
                                    if get(handles.fouri_epon,'Value')==1
                                        tmpL = length(handles.userdata(1:Len(i),i));
                                        FFTofWinData = fft(handles.userdata(1:Len(i),i).*handles.win(1:handles.winN(i),i),tmpL);
                                        NumUniquePts(i) = ceil((tmpL + 1)/2);
                                    else
                                        FFTofWinData = fft(handles.userdata(1:Len(i),i).*handles.win(1:handles.winN(i),i),handles.FourierN);
                                        NumUniquePts(i) = ceil((handles.FourierN + 1)/2);
                                    end
                                    FFTofWinData = FFTofWinData(1 : NumUniquePts(i));
                                    handles.P(1:NumUniquePts(i),i) = abs(FFTofWinData).^2;

                                    if Average(handles)
                                        if ~handles.flag4avg
                                            totNumEvents = 1;
                                        end
                                        if (totNumEvents == 1)
                                            handles.myPSD(:,i) = handles.P(:,i);
                                        else
                                            handles.myPSD(:,i) = ((totNumEvents-1)*handles.myPSD(:,i)*handles.flag4avg + handles.P(:,i))/totNumEvents;
                                        end
                                        handles.flag4avg = 1;
                                    else
                                        handles.myPSD = zeros(size(handles.P(:,i)));
                                        if handles.flag4avg
                                            totNumEvents = 1;
                                        end
                                        handles.myPSD(:,i) = handles.P(:,i);
                                        handles.flag4avg = 0;
                                    end

                                end
                                
                            end
                            
                            if  handles.NumChan2Plot == 1
                                index = 1;
                            else
                                index = ADchanIndex;
                            end
                            figure(handles.h);
                            axes(handles.Spectrogram_plot)
                            x = linspace(0,handles.Fs(ADchanIndex)/2,length(handles.myPSD(1:NumUniquePts(index),index)));
                            if get(handles.logPSD,'Value')
                                plot(handles.Spectrogram_plot,x,10*log10(handles.myPSD(1:NumUniquePts(index),index)+eps),'r')
                                ylabel(handles.Spectrogram_plot,'PSD (dB)','VerticalAlignment','middle')
                           else
                                plot(handles.Spectrogram_plot,x,handles.myPSD(1:NumUniquePts(index),index),'r')
                                ylabel(handles.Spectrogram_plot,'PSD','VerticalAlignment','middle')
                            end
                            set(handles.Spectrogram_plot,'AmbientLightColor','white');
                            set(handles.Spectrogram_plot, 'color', 'white');
                            set(handles.Spectrogram_plot,'XLim',[str2num(get(handles.frequency_start,'String')) str2num(get(handles.frequency_end,'String'))])
                            xlabel(handles.Spectrogram_plot,'Frequency (Hz)')
                            if get(handles.EEGmode,'Value')
                                psdYLim = get(handles.Spectrogram_plot,'YLim');
                                text(2,psdYLim(1),'\delta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                                text(6,psdYLim(1),'\theta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                                text(10,psdYLim(1),'\alpha','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                                text(19,psdYLim(1),'\beta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                                text(63,psdYLim(1),'\gamma','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                                set(handles.Spectrogram_plot,'XTick',[0 4 8 12 26 100])
                                hold(handles.Spectrogram_plot,'on')
                                tmpVect = [psdYLim(1):abs(psdYLim(2)-psdYLim(1))/50:psdYLim(2),psdYLim(2)];
                                deltamat = 4*ones(1,length(tmpVect));
                                plot(deltamat,tmpVect,':','color',[1 0 1])
                                thetamat = 8*ones(1,length(tmpVect));
                                plot(thetamat,tmpVect,':','color',[1 0 1])
                                alphamat = 12*ones(1,length(tmpVect));
                                plot(alphamat,tmpVect,':','color',[1 0 1])
                                betamat = 26*ones(1,length(tmpVect));
                                plot(betamat,tmpVect,':','color',[1 0 1])
                                gammamat = 100*ones(1,length(tmpVect));
                                plot(gammamat,tmpVect,':','color',[1 0 1])
                                hold(handles.Spectrogram_plot,'off')
                            end
                        end
                        set(handles.Spectrogram_plot,'Position',handles.spectPosition)
                        drawnow;
                        %-------------------- Spectrogram End ---------------

                        set(handles.Time_plot,'XLim',[-handles.lfp_pre handles.lfp_post])
                    end
                    
                    SetNumEvents(totNumEvents, handles)
                    if ~stopped
                        handles.eventCue = handles.eventCue(2:length(handles.eventCue));
                    end
                    
                    if S & (get(handles.eventsButton,'Value'))
                        if S == totNumEvents
                            dialogString = char('Completed Plotting');
                            set(handles.dialogBox,'String',dialogString);
                            handles.RUNNING1 = [];
                            stopped = 1;
                            if ~isempty(temp_eventCue)
                                handles.eventCue(1) = temp_eventCue;
                                handles.tt = temp_tt;
                            end
                            guidata(hObject, handles);
                            return
                        end
                    end
                    
                    guidata(hObject, handles);
                end
                
            end
            
            set(handles.StopButton, 'Value', 0); 
            handles.RUNNING1 = [];
            if ~isempty(temp_eventCue)
                handles.eventCue(1) = temp_eventCue;
                handles.tt = temp_tt;
                handles.dd = temp_dd;
            end
            guidata(hObject, handles);

    end

%-----------------------------------------------------
%Functions for TriggeredLFPClientFns

function y = GetPreTime(handles)
    y = str2num(get(handles.pre,'String'));

function y = GetPostTime(handles)
    y = str2num(get(handles.post,'String'));

function y = GetEvent(handles)
    y = str2num(get(handles.eventBox,'String'));
    
function y = GetUnit(handles);
    if (get(handles.spikesButton,'Value') == 1) & (get(handles.eventsButton,'Value') == 0) 
        y = get(handles.SpikeUnit,'Value') - 1;
    else
        y = -1;
    end

function S = GetNum2Plot(handles)
    y = get(handles.NumEvents2Plot, 'String');
    S = y{get(handles.NumEvents2Plot, 'Value')};
    if strcmp(S,'All')
        S = '0';
    end
    S = str2num(S);

function SetNumEvents(n,handles)
    set(handles.numEvents,'String',n)

function SetSamplingFreq(handles,ADchanIndex)
    set(handles.samplingFreq,'String',num2str(handles.Fs(ADchanIndex)))

function ResetSamplingFreq(handles)
    set(handles.samplingFreq,'String',num2str(0))

function SetADchanList(textstring, handles)
    set(handles.ADchanList,'String',textstring)

function y = GetADchan(handles)
    string = get(handles.ADchanList,'String');
    value = get(handles.ADchanList,'Value');
    string = cellstr(string);
    y = str2num(string{value});

function y = Average(handles)
    value = get(handles.mode,'Value');
    string = get(handles.mode,'String');
    if strcmp(string{value},'Single')
        y = 0;
    elseif strcmp(string{value},'Average')
        y = 1;
    else
        y = 2;
    end

%%%---------------------------------------------------------------%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function eventBox_Callback(hObject, eventdata, handles)
    val = str2num(get(handles.eventBox,'String'));
    if isempty(val)
        set(handles.eventBox,'String',1);
    elseif fix(val)~=val
        set(handles.eventBox,'String',fix(val));
    end
    if handles.Connect & (get(handles.spikesButton,'Value') == 1) & (get(handles.eventsButton,'Value') == 0)
        chanNo = str2num(get(handles.eventBox,'String'));
        if (chanNo <=  length(handles.counts))
            unitsNo = handles.counts(1,chanNo);
        else
            chanNo = length(handles.counts);
            set(handles.eventBox,'String',chanNo);
            unitsNo = handles.counts(1,chanNo);
        end
        if (unitsNo ~=  0)
            set(handles.SpikeUnit,'Value',1);
            set(handles.SpikeUnit,'String',{'Unsorted' ; char((96+[1:unitsNo])')});
        elseif (unitsNo == 0)
            set(handles.SpikeUnit,'Value',1);
            set(handles.SpikeUnit,'String','Unsorted');
        end
    end
    guidata(hObject, handles);
    

function eventBox_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);


function SpikeUnitMenu_Callback(hObject, eventdata, handles)


function SpikeUnitMenu_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(handles.SpikeUnit,'BackgroundColor','white');
    end
    set(handles.SpikeUnit,'Value',1);
    set(handles.SpikeUnit,'String','Unsorted')
    set(handles.SpikeUnit,'Enable','off')
    guidata(hObject, handles);

    
    
function numEvents_Callback(hObject, eventdata, handles)


function numEvents_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);

    
function numPlots_Callback(hObject, eventdata, handles)


function numPlots_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);
    

function dialogBox_Callback(hObject, eventdata, handles)


function dialogBox_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);


function CentralFreq_Callback(hObject, eventdata, handles)
    if handles.Connect
        ADchan = GetADchan(handles);
        ADchanIndex = find(handles.activeChans==ADchan);
        val = str2num(get(handles.CentralFreq,'String'));
        if isempty(val)
            set(handles.CentralFreq,'String',0);
        elseif str2num(get(handles.CentralFreq,'String'))>handles.Fs(ADchanIndex)/2
            set(handles.CentralFreq, 'String' ,num2str(handles.Fs(ADchanIndex)/2));
        else
            CentralFreqofInterest = str2num(get(handles.CentralFreq,'String'));
            numberofPeriods2see = 5; 
            if CentralFreqofInterest~=0
                set(handles.FrequencyRes,'String',0)
                preValue = fix((numberofPeriods2see/CentralFreqofInterest)/10*handles.Fs(ADchanIndex))*10/handles.Fs(ADchanIndex);
                set(handles.pre,'String',preValue);
                set(handles.post,'String',preValue);
                hannwidthVal = fix(handles.Fs(ADchanIndex)*preValue/2.5)/handles.Fs(ADchanIndex);
                set(handles.hannwidth,'String',hannwidthVal); 
                stepSizeVal = fix(handles.Fs(ADchanIndex)*preValue/5)/handles.Fs(ADchanIndex);
                set(handles.step_size,'String',stepSizeVal);
                if ~get(handles.PSDSelectButton,'Value')
                    if hannwidthVal<1
                        FreqRes = fix(1/hannwidthVal);
                    else
                        FreqRes = 1/hannwidthVal;
                    end
                else
                    preVal = str2num(get(handles.pre,'String'));
                    postVal = str2num(get(handles.post,'String'));
                    if (preVal + postVal)<1
                        FreqRes = fix(1/(preVal + postVal));
                    else
                        FreqRes = 1/(preVal + postVal);
                    end
                end
                set(handles.FrequencyRes,'String',num2str(FreqRes));
                preVal = str2num(get(handles.pre,'String'));
                postVal = str2num(get(handles.post,'String'));
                if (preVal + postVal)<1
                    FreqRes = fix(1/(preVal + postVal));
                else
                    FreqRes = 1/(preVal + postVal);
                end
                set(handles.frequency_start,'String',num2str(FreqRes))
                set(handles.frequency_end,'String',3*CentralFreqofInterest);
            end
        end
        
    end
    guidata(hObject, handles);

    
function CentralFreq_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(handles.CentralFreq,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);
    
    
function FrequencyRes_Callback(hObject, eventdata, handles)
    if handles.Connect
        ADchan = GetADchan(handles);
        ADchanIndex = find(handles.activeChans==ADchan);
        val = str2num(get(handles.FrequencyRes,'String'));
        if isempty(val)
            set(handles.FrequencyRes,'String',0);
        elseif str2num(get(handles.FrequencyRes,'String'))>handles.Fs(ADchanIndex)/2
            set(handles.FrequencyRes, 'String' ,num2str(handles.Fs(ADchanIndex)/2));
        else
            CentralFreqofInterest = str2num(get(handles.CentralFreq,'String'));
            numberofPeriods2see = 5; 
            if CentralFreqofInterest~=0 
                preValue = fix((numberofPeriods2see/CentralFreqofInterest)/10*handles.Fs(ADchanIndex))*10/handles.Fs(ADchanIndex);
                set(handles.pre,'String',preValue);
                set(handles.post,'String',preValue);
                set(handles.hannwidth,'String',fix(handles.Fs(ADchanIndex)*preValue/2.5)/handles.Fs(ADchanIndex)); 
                set(handles.step_size,'String',fix(handles.Fs(ADchanIndex)*preValue/5)/handles.Fs(ADchanIndex));
            end
            minFrequencyRes = str2num(get(handles.FrequencyRes,'String'));
            if minFrequencyRes~=0
                numberofSamples2fft = 2*handles.Fs(ADchanIndex)/2/minFrequencyRes;
                WindowLength = fix(handles.Fs(ADchanIndex)/minFrequencyRes)/handles.Fs(ADchanIndex);
                if ~get(handles.PSDSelectButton,'Value')
                    stepSize = fix(handles.Fs(ADchanIndex)*WindowLength/2)/handles.Fs(ADchanIndex);
                    hannwidth = str2num(get(handles.hannwidth,'String'));
                    if hannwidth < WindowLength
                        set(handles.hannwidth,'String',WindowLength);
                        set(handles.step_size,'String',stepSize);
                        set(handles.pre,'String',WindowLength*2.5); 
                        set(handles.post,'String',WindowLength*2.5);
                    else
                        if hannwidth<1
                            FreqRes = fix(1/hannwidth);
                        else
                            FreqRes = 1/hannwidth;
                        end
                        set(handles.FrequencyRes,'String',FreqRes);
                    end
                else
                    preVal = str2num(get(handles.pre,'String'));
                    postVal = str2num(get(handles.post,'String'));
                    prePlusPost = preVal + postVal;
                    if prePlusPost  < WindowLength
                        set(handles.pre,'String',num2str(WindowLength/2));
                        set(handles.post,'String',num2str(WindowLength/2));
                        set(handles.hannwidth,'String',num2str(WindowLength/5));
                        set(handles.step_size,'String',num2str(WindowLength/10));
                    else
                        if prePlusPost<1
                            FreqRes = fix(1/(prePlusPost));
                        else
                            FreqRes = 1/(prePlusPost);
                        end
                        set(handles.FrequencyRes,'String',num2str(FreqRes));
                    end
                end
                preVal = str2num(get(handles.pre,'String'));
                postVal = str2num(get(handles.post,'String'));
                prePlusPost = preVal + postVal;
                if prePlusPost<1
                    FreqRes = fix(1/(prePlusPost));
                else
                    FreqRes = 1/(prePlusPost);
                end
                set(handles.frequency_start,'String',num2str(FreqRes))
            end
        end
        
    end
    guidata(hObject, handles);

    
function FrequencyRes_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(handles.FrequencyRes,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(handles.FrequencyRes,'BackgroundColor','white');
    end
    guidata(hObject, handles);
    
    
function post_Callback(hObject, eventdata, handles)
    val = str2num(get(handles.post,'String'));
    if isempty(val)
        set(handles.post,'String',0.1);
    end
    preVal = str2num(get(handles.pre,'String'));
    postVal = str2num(get(handles.post,'String'));
    if (10/(preVal + postVal)) > str2num(get(handles.CentralFreq,'String')) & str2num(get(handles.CentralFreq,'String'))
        postVal = 10/str2num(get(handles.CentralFreq,'String')) - preVal;
        set(handles.post,'String',num2str(postVal))
    end
    if (preVal + postVal) < 1
        FreqRes = fix(1/(preVal + postVal));
    else
        FreqRes = 1/(preVal + postVal);
    end
    set(handles.frequency_start,'String',num2str(FreqRes))
    if get(handles.PSDSelectButton,'Value')
        set(handles.FrequencyRes,'String',num2str(FreqRes));
    end
    guidata(hObject, handles);
    
    
function post_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(handles.post,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(handles.post,'BackgroundColor','white');
    end
    guidata(hObject, handles);


function pre_Callback(hObject, eventdata, handles)
    val = str2num(get(handles.pre,'String'));
    if isempty(val)
        set(handles.pre,'String',0.1);
    end
    preVal = str2num(get(handles.pre,'String'));
    postVal = str2num(get(handles.post,'String'));
    if (10/(preVal + postVal)) > str2num(get(handles.CentralFreq,'String')) & str2num(get(handles.CentralFreq,'String'))
        preVal = 10/str2num(get(handles.CentralFreq,'String')) - postVal;
        set(handles.pre,'String',num2str(preVal))
    end
    if (preVal + postVal) < 1
        FreqRes = fix(1/(preVal + postVal));
    else
        FreqRes = 1/(preVal + postVal);
    end
    set(handles.frequency_start,'String',num2str(FreqRes))
    if get(handles.PSDSelectButton,'Value')
        set(handles.FrequencyRes,'String',num2str(FreqRes));
    end
    guidata(hObject, handles);
    
    
function pre_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(handles.pre,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(handles.pre,'BackgroundColor','white');
    end
    guidata(hObject, handles);
    
    
function ADchanList_Callback(hObject, eventdata, handles)
    if handles.Connect
        ADchanIndex = get(handles.ADchanList,'Value');
        if strcmp(get(handles.StopButton,'Enable'),'off')
            set(handles.frequency_end,'String',min(fix(handles.Fs(ADchanIndex)/2),str2num(get(handles.frequency_end,'String'))));
            if str2num(get(handles.frequency_start,'String')) > str2num(get(handles.frequency_end,'String'))
                set(handles.frequency_start,'String',0);
                set(handles.dialogBox,'String',['Minimum Frequency Changed!']);
            end
        elseif str2num(get(handles.frequency_end,'String')) > handles.Fs(ADchanIndex)/2
            set(handles.frequency_end,'String',num2str(fix(handles.Fs(ADchanIndex)/2)));
            if str2num(get(handles.frequency_start,'String')) > str2num(get(handles.frequency_end,'String'))
                set(handles.frequency_start,'String',0);
                set(handles.dialogBox,'String',['Minimum Frequency Changed!']);
            end
        end
        SetSamplingFreq(handles,ADchanIndex); 
    end
        
    if get(handles.mode,'Value')==3
        if handles.Connect 
            ADchan = GetADchan(handles);
            ADchanIndex = find(handles.activeChans==ADchan);
            if (get(handles.spikesButton,'Value') ==1)
                tmpStruct = get(handles.SpikeUnit,'String');
                tmpStr = ['Spikes from Channel ' get(handles.eventBox,'String') '-' char(tmpStruct(get(handles.SpikeUnit,'Value')))];
            elseif (get(handles.eventsButton,'Value') ==1)
                tmpStr = ['Events from Channel ' get(handles.eventBox,'String')];
            end
            dialogString = ['AD # ' num2str(ADchan) ' Data for ' tmpStr ];
            set(handles.dialogBox,'String',dialogString);
            if get(handles.SpectSelectButton,'Value') & ~get(handles.PSDSelectButton,'Value') 
                SpectSelect_Callback(hObject, eventdata, handles);
            elseif ~get(handles.SpectSelectButton,'Value') & get(handles.PSDSelectButton,'Value') 
                PSDSelect_Callback(hObject, eventdata, handles);
            end
        end
    end
    guidata(hObject, handles);
    

function ADchanList_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(handles.ADchanList,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(handles.ADchanList,'BackgroundColor','white');
    end
    guidata(hObject, handles);
    

function mode_Callback(hObject, eventdata, handles)

    if get(handles.mode,'Value')==2 

        if ~get(handles.PSDSelectButton,'Value') & get(handles.ExpertMode,'Value')
            set(handles.FrequencyRes,'Enable','on');
            set(handles.text25,'Enable','on');
        end
        set(handles.redrawButton,'Enable','off')
        
    elseif get(handles.mode,'Value')==1
        
        if ~get(handles.PSDSelectButton,'Value') & get(handles.ExpertMode,'Value')
            set(handles.FrequencyRes,'Enable','on');
            set(handles.text25,'Enable','on');
        end
        
    elseif get(handles.mode,'Value')==3
        
        if get(handles.ExpertMode,'Value')
            set(handles.redrawButton,'Enable','off')
            set(handles.text25,'Enable','on');
            set(handles.FrequencyRes,'Enable','on');
        end
    end
    guidata(hObject, handles);


function ExpertMode_Callback(hObject, eventdata, handles)
    if get(handles.ExpertMode,'Value')
        set(handles.text6,'Enable','on')
        set(handles.pre,'Enable','on')
        set(handles.post,'Enable','on')
        set(handles.text15,'Enable','on')
        set(handles.win_shape,'Enable','on')
        if get(handles.SpectSelectButton,'Value')
            set(handles.text14,'Enable','on')
            set(handles.hannwidth,'Enable','on')
            set(handles.text13,'Enable','on')
            set(handles.step_size,'Enable','on')
            set(handles.text25,'Enable','on')
            set(handles.FrequencyRes,'Enable','on')
            set(handles.SpectShading,'Enable','on')
            set(handles.text32,'Enable','on')
        end
        set(handles.EEGmode,'Enable','on')
        set(handles.EEGtext,'Enable','on')
        set(handles.text12,'Enable','on')
        if ~get(handles.EEGmode,'Value')
            set(handles.frequency_end,'Enable','on')
        end
        set(handles.text21,'Enable','on')
        if ~get(handles.EEGmode,'Value')
            set(handles.frequency_start,'Enable','on')
        end
        set(handles.DCRemoval,'Enable','on')
        set(handles.text29,'Enable','on')
        if (length(get(handles.resetButton,'Enable')) == 3) & (strcmp(get(handles.DisConBtn,'Enable'),'off') | strcmp(get(handles.StopButton,'Enable'),'off')) & handles.Connect
            set(handles.resetButton,'Enable','on')
        end
        if (length(get(handles.redrawButton,'Enable')) == 3) & (get(handles.mode,'value') == 1) & strcmp(get(handles.StopButton,'Enable'),'off') & handles.Connect
            set(handles.redrawButton,'Enable','on')
        end
    else
        set(handles.text6,'Enable','off')
        set(handles.pre,'Enable','off')
        set(handles.post,'Enable','off')
        set(handles.text15,'Enable','off')
        set(handles.win_shape,'Enable','off')
        set(handles.text14,'Enable','off')
        set(handles.hannwidth,'Enable','off')
        set(handles.text13,'Enable','off')
        set(handles.step_size,'Enable','off')
        set(handles.text25,'Enable','off')
        set(handles.FrequencyRes,'Enable','off')
        set(handles.text12,'Enable','off')
        set(handles.frequency_end,'Enable','off')
        set(handles.text21,'Enable','off')
        set(handles.frequency_start,'Enable','off')
        set(handles.SpectShading,'Enable','off')
        set(handles.text32,'Enable','off')
        set(handles.resetButton,'Enable','off')
        set(handles.redrawButton,'Enable','off')
        set(handles.DCRemoval,'Enable','off')
        set(handles.text29,'Enable','off')
        set(handles.EEGmode,'Enable','off')
        set(handles.EEGtext,'Enable','off')
    end
    guidata(hObject, handles);
    

function mode_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);


function ConnectBtn_Callback(hObject, eventdata, handles)
    
    if ~(handles.Connect)
        set(handles.resetButton,'Enable','off')
    end
    if (get(handles.spikesButton,'Value') == 1) & (get(handles.eventsButton,'Value') == 0)
        chanNo = str2num(get(handles.eventBox,'String'));
        if (chanNo <=  length(handles.counts))
            unitsNo = handles.counts(1,chanNo);
        else
            chanNo = length(handles.counts);
            set(handles.eventBox,'String',chanNo);
            unitsNo = handles.counts(1,chanNo);
        end
        if (unitsNo ~=  0)
            set(handles.SpikeUnit,'Value',1);
            set(handles.SpikeUnit,'String',{'Unsorted' ; char((96+[1:unitsNo])')});
        elseif (unitsNo == 0)
            set(handles.SpikeUnit,'Value',1);
            set(handles.SpikeUnit,'String','Unsorted');
        end
        set(handles.SpikeUnit,'Enable','on')
    end
    set(handles.EEGmode,'Value',0)
    handles.FourierN = 2^(get(handles.fouri_epon,'Value') + 3);
    handles.Connect = 1;
    handles.action = 'connect';
    guidata(hObject, handles);
    TriggeredLFPClientFns(handles, hObject)

function ConnectBtn_CreateFcn(hObject, eventdata, handles)
    handles.Connect = 0;
    guidata(hObject, handles);


function StartButton_Callback(hObject, eventdata, handles)
    stopped = 0;
    set(handles.StartButton,'Enable','off')
    if (length(get(handles.StopButton,'Enable')) == 3) 
        set(handles.StopButton,'Enable','on')
    end
    if (length(get(handles.redrawButton,'Enable')) == 2) 
        set(handles.redrawButton,'Enable','off')
    end
    if (length(get(handles.resetButton,'Enable')) == 2) 
        set(handles.resetButton,'Enable','off')
    end

    if (length(get(handles.ExportFigures,'Enable')) == 3) 
        set(handles.ExportFigures,'Enable','on')
    end

    if (length(get(handles.ExportCursor,'Enable')) == 3) 
        set(handles.ExportCursor,'Enable','on')
    end
    if ~get(handles.eventsButton,'Value')
        set(handles.eventsButton,'Enable','off')
    else
        set(handles.spikesButton,'Enable','off')
    end
    if ~get(handles.PSDSelectButton,'Value')
        set(handles.PSDSelectButton,'Enable','off')
    else
        set(handles.SpectSelectButton,'Enable','off')
        set(handles.logPSD,'Enable','off')
        set(handles.text30,'Visible','off');
    end
    
    if get(handles.mode,'Value')~=3 
        set(handles.ADchanList,'Enable','off')
    end
    set(handles.mode,'Enable','off')
    set(handles.NotchFilter,'Enable','off')
    set(handles.pre,'Enable','off')
    set(handles.post,'Enable','off')
    set(handles.NumEvents2Plot,'Enable','off')
    set(handles.CentralFreq,'Enable','off')
    set(handles.FrequencyRes,'Enable','off')
    set(handles.ExpertMode,'Enable','off')
    if get(handles.mode,'Value')~=1 
        set(handles.SpikeUnit,'Enable','off')
        set(handles.eventBox,'Enable','off')
        set(handles.redrawButton,'Enable','off')
        set(handles.frequency_end,'Enable','off')
        set(handles.frequency_start,'Enable','off')
        set(handles.fouri_epon,'Enable','off')
        set(handles.win_shape,'Enable','off')
        set(handles.hannwidth,'Enable','off')
        set(handles.step_size,'Enable','off')
        set(handles.SpectShading,'Enable','off')
        set(handles.DCRemoval,'Enable','off')
        set(handles.text29,'Enable','off')
    end

    handles.action = 'plot';
    guidata(hObject, handles);
    TriggeredLFPClientFns(handles, hObject)

    
function StartButton_CreateFcn(hObject, eventdata, handles) 
    if (length(get(handles.StartButton,'Enable')) == 2) 
        set(handles.StartButton,'Enable','off')
    end
    if (length(get(handles.redrawButton,'Enable')) == 2) 
        set(handles.redrawButton,'Enable','off')
    end
    if (length(get(handles.resetButton,'Enable')) == 2) 
        set(handles.resetButton,'Enable','off')
    end
    guidata(hObject, handles);

    
function DisConBtn_Callback(hObject, eventdata, handles)
    handles.Connect = 0;
    set(handles.StartButton,'Enable','on')
    if (length(get(handles.redrawButton,'Enable')) == 2) 
        set(handles.redrawButton,'Enable','off')
    end
    if (length(get(handles.resetButton,'Enable')) == 3) & get(handles.ExpertMode,'Value')
        set(handles.resetButton,'Enable','on')
    end

    if (length(get(handles.StartButton,'Enable')) == 2) 
        set(handles.StartButton,'Enable','off')
    end
    if (length(get(handles.StopButton,'Enable')) == 2) 
        set(handles.StopButton,'Enable','off')
    end
    set(handles.eventsButton,'Enable','on')
    set(handles.spikesButton,'Enable','on')
    set(handles.SpectSelectButton,'Enable','on')
    set(handles.logPSD,'Enable','on')
    set(handles.PSDSelectButton,'Enable','on')
    set(handles.ADchanList,'Enable','on')
    set(handles.NotchFilter,'Enable','on')
    set(handles.eventBox,'Enable','on')
    if get(handles.spikesButton,'Value')
        set(handles.SpikeUnit,'Enable','on')
    end
    if get(handles.ExpertMode,'Value')
        set(handles.pre,'Enable','on')
        set(handles.post,'Enable','on')
        set(handles.win_shape,'Enable','on')
        set(handles.frequency_end,'Enable','on')
        set(handles.frequency_start,'Enable','on')
        set(handles.FrequencyRes,'Enable','on')
        set(handles.DCRemoval,'Enable','on')
        set(handles.text29,'Enable','on')
        if ~get(handles.PSDSelectButton,'Value')
            set(handles.hannwidth,'Enable','on')
            set(handles.step_size,'Enable','on')
            set(handles.text14,'Enable','on')
            set(handles.text13,'Enable','on')
            set(handles.SpectShading,'Enable','on')
            set(handles.text32,'Enable','on')
        end
    end
    set(handles.SpikeUnit,'Enable','off')
    set(handles.NumEvents2Plot,'Enable','on')
    set(handles.CentralFreq,'Enable','on')
    
    set(handles.ExpertMode,'Enable','on')

    set(handles.fouri_epon,'Enable','on')
    set(handles.mode,'Enable','on')

    handles.action = 'disconnect';
    guidata(hObject, handles);
    TriggeredLFPClientFns(handles, hObject)


function StopButton_Callback(hObject, eventdata, handles)
    stopped = 1;
    pause(0.5)
    set(handles.StartButton,'Enable','on')
    if (length(get(handles.redrawButton,'Enable')) == 3) & (get(handles.mode,'value') == 1) & get(handles.ExpertMode,'Value')
        set(handles.redrawButton,'Enable','on')
    end
    if (length(get(handles.resetButton,'Enable')) == 3) & get(handles.ExpertMode,'Value')
        set(handles.resetButton,'Enable','on')
    end
    set(handles.eventsButton,'Enable','on')
    set(handles.spikesButton,'Enable','on')
    set(handles.SpectSelectButton,'Enable','on')
    set(handles.logPSD,'Enable','on')
    set(handles.PSDSelectButton,'Enable','on')
    set(handles.ADchanList,'Enable','on')
    if get(handles.spikesButton,'Value')
        set(handles.SpikeUnit,'Enable','on')
    end
    set(handles.NotchFilter,'Enable','on')
    set(handles.eventBox,'Enable','on')
    if get(handles.ExpertMode,'Value')
        set(handles.pre,'Enable','on')
        set(handles.post,'Enable','on')
        set(handles.frequency_end,'Enable','on')
        set(handles.frequency_start,'Enable','on')
        set(handles.fouri_epon,'Enable','on')
        set(handles.win_shape,'Enable','on')
        set(handles.DCRemoval,'Enable','on')
        set(handles.text29,'Enable','on')
        if ~get(handles.PSDSelectButton,'Value')
            set(handles.hannwidth,'Enable','on')
            set(handles.step_size,'Enable','on')
            set(handles.text14,'Enable','on')
            set(handles.text13,'Enable','on')
            set(handles.SpectShading,'Enable','on')
            set(handles.text32,'Enable','on')
        end
    end
    set(handles.ADchanList,'Enable','on')
    set(handles.ADchanList,'BackgroundColor','white')
    set(handles.NumEvents2Plot,'Enable','on')
    set(handles.mode,'Enable','on')
    set(handles.StopButton,'Enable','off')
    set(handles.CentralFreq,'Enable','on')
    if get(handles.ExpertMode,'Value') 
        set(handles.FrequencyRes,'Enable','on')
    end
    set(handles.ExpertMode,'Enable','on')
    
    handles.action = 'stop';
    guidata(hObject, handles);
    TriggeredLFPClientFns(handles, hObject)

    
function StopButton_CreateFcn(hObject, eventdata, handles) 
    if (length(get(handles.StopButton,'Enable')) == 2) 
        set(handles.StopButton,'Enable','off')
    end
    guidata(hObject, handles);


function RedrawButton_Callback(hObject, eventdata, handles) 
    Fs = handles.PARS1(8); 
    handles.lfp_pre = GetPreTime(handles); 
    handles.lfp_post = GetPostTime(handles); 
    ADchan = GetADchan(handles);
    ADchanIndex = find(handles.activeChans==ADchan);
    handles.lfp_start = round((handles.eventCue(1) - handles.lfp_pre - handles.tt)*handles.Fs(ADchanIndex)) + 1;
    handles.lfp_stop = handles.lfp_start + (handles.lfp_pre + handles.lfp_post)*handles.Fs(ADchanIndex);

    handles.lfp_ave = handles.dd(handles.lfp_start:handles.lfp_stop,:);
    figure(handles.h);
    x = -handles.lfp_pre : 1/handles.Fs(ADchanIndex) : handles.lfp_post;
    if get(handles.mode,'Value') == 3
        ADchan = GetADchan(handles);
        ADchanIndex = find(handles.activeChans==ADchan);
        y = handles.lfp_ave(:,ADchanIndex);
    else
        y = handles.lfp_ave(:,1);
    end
    cla(handles.Time_plot);
    axes(handles.Time_plot)
    if handles.getTrueVoltage
        if max(abs(y))>0.001
            plot(handles.Time_plot, x,1000*y,'b')
            ylabel('Voltage (mV)','VerticalAlignment','middle')
        elseif max(abs(y))<0.001
            plot(handles.Time_plot, x,1000000*y,'b')
            ylabel('Voltage (uV)','VerticalAlignment','middle')
        end
    else
        plot(handles.Time_plot, x,y,'b')
        ylabel('Amplified Voltage','VerticalAlignment','middle')
    end
    hold(handles.Time_plot,'on')
    set(handles.Time_plot, 'color', 'white');
    set(handles.Time_plot,'XLim',[-handles.lfp_pre handles.lfp_post])
    ylimTime = get(handles.Time_plot,'YLim');
    plot(handles.Time_plot, x*0,[ones(1,length(y)-1)*ylimTime(1),ylimTime(2)],'k:')
    xlabel('Time (sec)');
    set(handles.Time_plot,'XTick',-handles.lfp_pre : (handles.lfp_pre + handles.lfp_post)/10 : handles.lfp_post)
    hold(handles.Time_plot,'off')

    %--------- Spectrogram Refresh ------------
    handles.userdata = y;
    if get(handles.DCRemoval,'Value')
        handles.userdata = handles.userdata - mean(handles.userdata);
    end
    handles.winWidth = str2num(get(handles.hannwidth, 'String'));
    if get(handles.SpectSelectButton,'Value') & ~get(handles.PSDSelectButton,'Value')
        handles.winN = handles.winWidth * handles.Fs(ADchanIndex); 
        handles.STFTstep = str2num(get(handles.step_size, 'String'));
        handles.noverlap = handles.winN - handles.STFTstep*handles.Fs(ADchanIndex);
    elseif ~get(handles.SpectSelectButton,'Value') & get(handles.PSDSelectButton,'Value')
        handles.winN = length(handles.userdata);
    end
    if get(handles.win_shape, 'Value') == 1
        handles.win = hann(handles.winN);
    elseif get(handles.win_shape, 'Value') == 2
        handles.win = hamming(handles.winN);         
    elseif get(handles.win_shape, 'Value') == 3
        handles.win = blackman(handles.winN);
    elseif get(handles.win_shape, 'Value') == 4
        handles.win = chebwin(handles.winN);
    elseif get(handles.win_shape, 'Value') == 5
        handles.win = flattopwin(handles.winN);
    elseif get(handles.win_shape, 'Value') == 6
        handles.win = gausswin(handles.winN);
    end
    figure(handles.h);
    cla(handles.Spectrogram_plot);
    set(handles.Spectrogram_plot,'AmbientLightColor','white');
    handles.FourierN = 2^(get(handles.fouri_epon,'Value') + 3);
    if get(handles.SpectSelectButton,'Value') & ~get(handles.PSDSelectButton,'Value')
        if get(handles.fouri_epon,'Value')==1
            tmpL = length(handles.win);
            [Spect,handles.FreqVect,T,P] = spectrogram(handles.userdata,handles.win,handles.noverlap,tmpL,handles.Fs(ADchanIndex));
        else
            [Spect,handles.FreqVect,T,P] = spectrogram(handles.userdata,handles.win,handles.noverlap,handles.FourierN,handles.Fs(ADchanIndex));
        end
        handles.timeaxis = linspace(-handles.lfp_pre,handles.lfp_post, length(T));
        f1 = str2num(get(handles.frequency_start, 'String'));
        f2 = str2num(get(handles.frequency_end, 'String'));
        freqIndex = find((handles.FreqVect>=f1) .* (handles.FreqVect<=f2));
        psd4view = P(freqIndex,:);
        if str2num(get(handles.CentralFreq,'String'))~=0
            siz = size(psd4view);
            for i = 1 : siz(2)
                ff = find(psd4view(:,i)<.01*min(max(psd4view)));
                psd4view(ff,i) = min(max(psd4view))/100;
            end
        end
        axes(handles.Spectrogram_plot)
        tmpStr = get(handles.SpectShading,'String');
        shadingType = tmpStr(get(handles.SpectShading,'Value'),:);
        displayspectrogram(handles.timeaxis,handles.FreqVect(freqIndex),psd4view,0,[str2num(get(handles.frequency_start, 'String')) str2num(get(handles.frequency_end, 'String')) min(handles.timeaxis) max(handles.timeaxis)],shadingType);
        colorbar;
        set(handles.text30,'Visible','on');
        f1 = str2num(get(handles.frequency_start, 'String'));
        f2 = str2num(get(handles.frequency_end, 'String'));
        freqIndex = find((handles.FreqVect>=f1) .* (handles.FreqVect<=f2));
        axis([handles.FreqVect(freqIndex(1)) handles.FreqVect(freqIndex(end)) min(handles.timeaxis) max(handles.timeaxis)]);
        set(handles.Spectrogram_plot,'YTick',-handles.lfp_pre : (handles.lfp_pre + handles.lfp_post)/10 : handles.lfp_post)
        view(90,-90);
        if get(handles.EEGmode,'Value') & ~isempty(handles.lfp_ave) & (str2num(get(handles.FrequencyRes,'String'))<=1)
            spectYLim = get(handles.Spectrogram_plot,'YLim');
            text(2,spectYLim(2),'\delta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(6,spectYLim(2),'\theta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(10,spectYLim(2),'\alpha','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(19,spectYLim(2),'\beta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(63,spectYLim(2),'\gamma','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            minVal = 10*log10(min(min(min(psd4view)))+eps);
            hold(handles.Spectrogram_plot,'on')
            tmpVect = [spectYLim(1):abs(spectYLim(2)-spectYLim(1))/50:spectYLim(2),spectYLim(2)];
            deltamat = 4*ones(1,length(tmpVect));
            plot3(deltamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            thetamat = 8*ones(1,length(tmpVect));
            plot3(thetamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            alphamat = 12*ones(1,length(tmpVect));
            plot3(alphamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            betamat = 26*ones(1,length(tmpVect));
            plot3(betamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            gammamat = 100*ones(1,length(tmpVect));
            plot3(gammamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            hold(handles.Spectrogram_plot,'off')
        end
        set(handles.Spectrogram_plot,'Position',handles.spectPosition)
    elseif ~get(handles.SpectSelectButton,'Value') & get(handles.PSDSelectButton,'Value')
        if get(handles.fouri_epon,'Value')==1
            tmpL = length(handles.userdata);
            FFTofWinData = fft(handles.userdata.*handles.win,tmpL);
            NumUniquePts = ceil((tmpL+1)/2);
        else
            FFTofWinData = fft(handles.userdata.*handles.win,handles.FourierN);
            NumUniquePts = ceil((handles.FourierN+1)/2);
        end
        FFTofWinData = FFTofWinData(1:NumUniquePts);
        handles.P = abs(FFTofWinData).^2;
        figure(handles.h);
        x = linspace(0,handles.Fs(ADchanIndex)/2,length(handles.P(1:NumUniquePts)));
        axes(handles.Spectrogram_plot)
        if get(handles.logPSD,'Value')
            plot(handles.Spectrogram_plot,x,10*log10(handles.P(1:NumUniquePts)+eps),'r')
            ylabel(handles.Spectrogram_plot,'PSD (dB)','VerticalAlignment','middle')
        else
            plot(handles.Spectrogram_plot,x,handles.P(1:NumUniquePts),'r')
            ylabel(handles.Spectrogram_plot,'PSD','VerticalAlignment','middle')
        end
        set(handles.Spectrogram_plot,'AmbientLightColor','white');
        set(handles.Spectrogram_plot, 'color', 'white');
        set(handles.Spectrogram_plot,'XLim',[str2num(get(handles.frequency_start,'String')) str2num(get(handles.frequency_end,'String'))])
        xlabel(handles.Spectrogram_plot,'Frequency (Hz)')
        if get(handles.EEGmode,'Value')
            psdYLim = get(handles.Spectrogram_plot,'YLim');
            text(2,psdYLim(1),'\delta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(6,psdYLim(1),'\theta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(10,psdYLim(1),'\alpha','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(19,psdYLim(1),'\beta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(63,psdYLim(1),'\gamma','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            set(handles.Spectrogram_plot,'XTick',[0 4 8 12 26 100])
            hold(handles.Spectrogram_plot,'on')
            tmpVect = [psdYLim(1):abs(psdYLim(2)-psdYLim(1))/50:psdYLim(2),psdYLim(2)];
            deltamat = 4*ones(1,length(tmpVect));
            plot(deltamat,tmpVect,':','color',[1 0 1])
            thetamat = 8*ones(1,length(tmpVect));
            plot(thetamat,tmpVect,':','color',[1 0 1])
            alphamat = 12*ones(1,length(tmpVect));
            plot(alphamat,tmpVect,':','color',[1 0 1])
            betamat = 26*ones(1,length(tmpVect));
            plot(betamat,tmpVect,':','color',[1 0 1])
            gammamat = 100*ones(1,length(tmpVect));
            plot(gammamat,tmpVect,':','color',[1 0 1])
            hold(handles.Spectrogram_plot,'off')
        end
        set(handles.Spectrogram_plot,'Position',handles.spectPosition)
    end
    dialogString=char('Plots were refreshed');
    set(handles.dialogBox,'String',dialogString);
    guidata(hObject, handles);

    
function ResetButton_Callback(hObject, eventdata, handles) 
    set(handles.redrawButton,'Enable','off')
    if (length(get(handles.redrawButton,'Enable')) == 2) 
        set(handles.redrawButton,'Enable','off')
    end
    if (length(get(handles.ExportFigures,'Enable')) == 2)
        set(handles.ExportFigures,'Enable','off')
    end

    if (length(get(handles.ExportCursor,'Enable')) == 2)
        set(handles.ExportCursor,'Enable','off')
    end
    
    set(handles.eventsButton, 'Value',1);
    set(handles.spikesButton, 'Value',0);
    set(handles.text1,'String','# Events Accumulated');
    set(handles.text2,'String','Event Channel');
    set(handles.SpikeUnit,'Value',1);
    set(handles.SpikeUnit,'String','Unsorted');
    set(handles.SpikeUnit,'Enable','off');
    set(handles.eventBox,'Enable','on');
    set(handles.eventBox,'String',2);
    set(handles.ADchanList,'Enable','on')
    set(handles.ADchanList,'Value',1)
    set(handles.mode,'Enable','on')
    set(handles.mode,'Value',1)
    set(handles.NumEvents2Plot,'Enable','on')
    set(handles.NumEvents2Plot,'Value',1)
    set(handles.NotchFilter,'Enable','on')
    set(handles.NotchFilter,'Value',1)
    if get(handles.ExpertMode,'Value')
        set(handles.pre,'Enable','on');
        set(handles.post,'Enable','on');
        set(handles.win_shape,'Enable','on')
        set(handles.hannwidth,'Enable','on')
        set(handles.step_size,'Enable','on')
        set(handles.frequency_end,'Enable','on');
        set(handles.frequency_start,'Enable','on');
        set(handles.SpectShading,'Enable','on')
        set(handles.text14,'Enable','on')
        set(handles.text13,'Enable','on')
        set(handles.text32,'Enable','on')
        set(handles.EEGmode,'Value',0)
    end
    set(handles.numEvents,'String',0);
    set(handles.SpectSelectButton,'Enable','on')
    set(handles.SpectSelectButton,'Value',1)
    set(handles.PSDSelectButton,'Enable','on')
    set(handles.PSDSelectButton,'Value',0)
    set(handles.logPSD,'Enable','on')
    set(handles.logPSD,'Visible','off')
    set(handles.uipanel3,'Title','Spectrogram Options')
    set(handles.fouri_epon,'Enable','on')
    set(handles.fouri_epon,'Value',1)
    set(handles.win_shape,'Value',1)
    if str2num(get(handles.CentralFreq,'String'))
        CentralFreq_Callback(hObject, eventdata, handles);
    else
        set(handles.CentralFreq,'String',0);
        set(handles.FrequencyRes,'String',0);
        set(handles.pre,'String',0.1);
        set(handles.post,'String',0.1);
        set(handles.hannwidth,'String',num2str((0.1+0.1)/5))
        set(handles.step_size,'String',num2str((0.1+0.1)/10))
        set(handles.frequency_start,'String',0);
   end
   cla(handles.Time_plot);
   cla(handles.Spectrogram_plot);
   dialogString = char('Everything has been Reset!');
   set(handles.dialogBox,'String',dialogString);
   set(handles.resetButton,'Enable','off');
   guidata(hObject, handles);


function ResetButton_CreateFcn(hObject, eventdata, handles)


function NumEvents2Plot_Callback(hObject, eventdata, handles)


function NumEvents2Plot_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);
    

function ExportFigures_Callback(hObject, eventdata, handles)
    Fs = handles.PARS1(8); 
    ADchan = GetADchan(handles);
    ADchanIndex = find(handles.activeChans==ADchan);
    x = -handles.lfp_pre : 1/handles.Fs(ADchanIndex) : handles.lfp_post;
    if get(handles.mode,'Value') == 3
        ADchan = GetADchan(handles);
        ADchanIndex = find(handles.activeChans==ADchan);
    end
    if get(handles.mode,'Value') <3
        y = handles.lfp_ave(:,1);
    elseif get(handles.mode,'Value') ==3
        y = handles.lfp_ave(1:length(x),ADchanIndex);
    end

    handles.Numfigs = handles.Numfigs + 1;
    fighandle = figure(handles.Numfigs); 
    h = newplot(fighandle);
    if handles.getTrueVoltage
        if max(abs(y))>0.001
            plot(h, x,1000*y,'b')
            ylabel('Voltage (mV)','VerticalAlignment','middle')
        elseif max(abs(y))<0.001
            plot(h, x,1000000*y,'b')
            ylabel('Voltage (uV)','VerticalAlignment','middle')
        end
    else
        plot(h, x,y,'b')
        ylabel('Amplified Voltage','VerticalAlignment','middle')
    end
    hold(h,'on')
    set(h, 'color', 'white');
    set(h,'XLim',[-handles.lfp_pre handles.lfp_post])
    ylimTime = get(h,'YLim');
    plot(h, x*0,[ones(1,length(y)-1)*ylimTime(1),ylimTime(2)],'k:')
    xlabel('Time (sec)');
    set(h,'XTick',-handles.lfp_pre : (handles.lfp_pre + handles.lfp_post)/10 : handles.lfp_post)
    hold(h,'off')

    %-------------- Export the spectrogram plot ---------------
    
    if get(handles.mode,'Value')==1  
        
        handles.userdata = y ;
        if get(handles.DCRemoval,'Value')
            handles.userdata = handles.userdata - mean(handles.userdata);
        end
        if get(handles.SpectSelectButton,'Value') & ~get(handles.PSDSelectButton,'Value')
            handles.winN = handles.winWidth * handles.Fs(ADchanIndex);  
            handles.STFTstep = str2num(get(handles.step_size, 'String'));
            handles.noverlap = handles.winN - handles.STFTstep*handles.Fs(ADchanIndex);
        elseif ~get(handles.SpectSelectButton,'Value') & get(handles.PSDSelectButton,'Value')
            handles.winN = length(handles.userdata);
        end
        if get(handles.win_shape, 'Value') == 1
            handles.win = hann(handles.winN);
        elseif get(handles.win_shape, 'Value') == 2
            handles.win = hamming(handles.winN);
        elseif get(handles.win_shape, 'Value') == 3
            handles.win = blackman(handles.winN);
        elseif get(handles.win_shape, 'Value') == 4
            handles.win = chebwin(handles.winN);
        elseif get(handles.win_shape, 'Value') == 5
            handles.win = flattopwin(handles.winN);
        elseif get(handles.win_shape, 'Value') == 6
            handles.win = gausswin(handles.winN);
        end
        handles.Numfigs = handles.Numfigs + 1;
        fighandle = figure(handles.Numfigs);
        hand = newplot(fighandle); 
        Fs = handles.PARS1(8);
        handles.FourierN = 2^(get(handles.fouri_epon,'Value') + 3);
        if get(handles.SpectSelectButton,'Value') & ~get(handles.PSDSelectButton,'Value')
            if (get(handles.mode,'Value') ==1)
                if get(handles.fouri_epon,'Value')==1
                    tmpL = length(handles.win);
                    [Spect,handles.FreqVect,T,P] = spectrogram(handles.userdata,handles.win,handles.noverlap,tmpL,handles.Fs(ADchanIndex));
                else
                    [Spect,handles.FreqVect,T,P] = spectrogram(handles.userdata,handles.win,handles.noverlap,handles.FourierN,handles.Fs(ADchanIndex));
                end
            else
                P = handles.myPSD;
                if get(handles.fouri_epon,'Value')==1
                    tmpL = length(handles.win);
                    [Spect,handles.FreqVect,T] = spectrogram(handles.userdata,handles.win,handles.noverlap,tmpL,handles.Fs(ADchanIndex));
                else
                    [Spect,handles.FreqVect,T] = spectrogram(handles.userdata,handles.win,handles.noverlap,handles.FourierN,handles.Fs(ADchanIndex));
                end
            end
            handles.timeaxis = linspace(-handles.lfp_pre,handles.lfp_post, length(T));
            f1 = str2num(get(handles.frequency_start, 'String'));
            f2 = str2num(get(handles.frequency_end, 'String'));
            freqIndex = find((handles.FreqVect>=f1) .* (handles.FreqVect<=f2));
            psd4view = P(freqIndex,:);
            if str2num(get(handles.CentralFreq,'String'))~=0
                siz = size(psd4view);
                for i = 1 : siz(2)
                    ff = find(psd4view(:,i)<.01*min(max(psd4view)));
                    psd4view(ff,i) = min(max(psd4view))/100;
                end
            end
            axes(hand)
            tmpStr = get(handles.SpectShading,'String');
            shadingType = tmpStr(get(handles.SpectShading,'Value'),:);
            displayspectrogram(handles.timeaxis,handles.FreqVect(freqIndex),psd4view,0,[str2num(get(handles.frequency_start, 'String')) str2num(get(handles.frequency_end, 'String')) min(handles.timeaxis) max(handles.timeaxis)],shadingType);
            colorbar;
            f1 = str2num(get(handles.frequency_start, 'String'));
            f2 = str2num(get(handles.frequency_end, 'String'));
            freqIndex = find((handles.FreqVect>=f1) .* (handles.FreqVect<=f2));
            axis(hand,[handles.FreqVect(freqIndex(1)) handles.FreqVect(freqIndex(end)) min(handles.timeaxis) max(handles.timeaxis)]);
            set(hand,'YTick',-handles.lfp_pre : (handles.lfp_pre + handles.lfp_post)/10 : handles.lfp_post)
            view(90,-90);
            if get(handles.EEGmode,'Value') & ~isempty(handles.lfp_ave) & (str2num(get(handles.FrequencyRes,'String'))<=1)
                spectYLim = get(hand,'YLim');
                text(2,spectYLim(2),'\delta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(6,spectYLim(2),'\theta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(10,spectYLim(2),'\alpha','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(19,spectYLim(2),'\beta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(63,spectYLim(2),'\gamma','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                minVal = 10*log10(min(min(min(psd4view)))+eps);
                hold(hand,'on')
                tmpVect = [spectYLim(1):abs(spectYLim(2)-spectYLim(1))/50:spectYLim(2),spectYLim(2)];
                deltamat = 4*ones(1,length(tmpVect));
                plot3(deltamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                thetamat = 8*ones(1,length(tmpVect));
                plot3(thetamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                alphamat = 12*ones(1,length(tmpVect));
                plot3(alphamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                betamat = 26*ones(1,length(tmpVect));
                plot3(betamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                gammamat = 100*ones(1,length(tmpVect));
                plot3(gammamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                hold(hand,'off')
            end

        elseif ~get(handles.SpectSelectButton,'Value') & get(handles.PSDSelectButton,'Value')

            if get(handles.fouri_epon,'Value')==1
                tmpL = length(handles.userdata);
                FFTofWinData = fft(handles.userdata.*handles.win,tmpL);
                NumUniquePts = ceil((tmpL+1)/2);
            else
                FFTofWinData = fft(handles.userdata.*handles.win,handles.FourierN);
                NumUniquePts = ceil((handles.FourierN+1)/2);
            end
            FFTofWinData = FFTofWinData(1:NumUniquePts);
            handles.myPSD = abs(FFTofWinData).^2;
            x = linspace(0,handles.Fs(ADchanIndex)/2,length(handles.myPSD));
            axes(hand)
            if get(handles.logPSD,'Value')
                plot(x,10*log10(handles.myPSD+eps),'r')
                ylabel(hand,'PSD (dB)','VerticalAlignment','middle')
            else
                plot(x,handles.myPSD,'r')
                ylabel(hand,'PSD','VerticalAlignment','middle')
            end
            set(hand,'AmbientLightColor','white');
            set(hand,'color', 'white');
            set(hand,'XLim',[str2num(get(handles.frequency_start,'String')) str2num(get(handles.frequency_end,'String'))])
            xlabel(hand,'Frequency (Hz)')
            if get(handles.EEGmode,'Value')
                psdYLim = get(hand,'YLim');
                text(2,psdYLim(1),'\delta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(6,psdYLim(1),'\theta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(10,psdYLim(1),'\alpha','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(19,psdYLim(1),'\beta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(63,psdYLim(1),'\gamma','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                set(hand,'XTick',[0 4 8 12 26 100])
                set(hand,'XTick',[0 4 8 12 26 100])
                hold(hand,'on')
                tmpVect = [psdYLim(1):abs(psdYLim(2)-psdYLim(1))/50:psdYLim(2),psdYLim(2)];
                deltamat = 4*ones(1,length(tmpVect));
                plot(deltamat,tmpVect,':','color',[1 0 1])
                thetamat = 8*ones(1,length(tmpVect));
                plot(thetamat,tmpVect,':','color',[1 0 1])
                alphamat = 12*ones(1,length(tmpVect));
                plot(alphamat,tmpVect,':','color',[1 0 1])
                betamat = 26*ones(1,length(tmpVect));
                plot(betamat,tmpVect,':','color',[1 0 1])
                gammamat = 100*ones(1,length(tmpVect));
                plot(gammamat,tmpVect,':','color',[1 0 1])
                hold(hand,'off')
            end

        end
    
    elseif get(handles.mode,'Value')==2  
        
        handles.Numfigs = handles.Numfigs + 1;
        fighandle = figure(handles.Numfigs); 
        hand = newplot(fighandle);
        Fs = handles.PARS1(8); 
        if get(handles.SpectSelectButton,'Value') & ~get(handles.PSDSelectButton,'Value')
            f1 = str2num(get(handles.frequency_start, 'String'));
            f2 = str2num(get(handles.frequency_end, 'String'));
            freqIndex = find((handles.FreqVect>=f1) .* (handles.FreqVect<=f2));
            psd4view = handles.myPSD(freqIndex,:);
            if str2num(get(handles.CentralFreq,'String'))~=0
                siz = size(psd4view);
                for i = 1 : siz(2)
                    ff = find(psd4view(:,i)<.01*min(max(psd4view)));
                    psd4view(ff,i) = min(max(psd4view))/100;
                end
            end
            axes(hand)
            tmpStr = get(handles.SpectShading,'String');
            shadingType = tmpStr(get(handles.SpectShading,'Value'),:);
            displayspectrogram(handles.timeaxis,handles.FreqVect(freqIndex),psd4view,0,[str2num(get(handles.frequency_start, 'String')) str2num(get(handles.frequency_end, 'String')) min(handles.timeaxis) max(handles.timeaxis)],shadingType);
            colorbar;
            f1 = str2num(get(handles.frequency_start, 'String'));
            f2 = str2num(get(handles.frequency_end, 'String'));
            freqIndex = find((handles.FreqVect>=f1) .* (handles.FreqVect<=f2));
            axis(hand,[handles.FreqVect(freqIndex(1)) handles.FreqVect(freqIndex(end)) min(handles.timeaxis) max(handles.timeaxis)]);
            set(hand,'YTick',-handles.lfp_pre : (handles.lfp_pre + handles.lfp_post)/10 : handles.lfp_post)
            view(90,-90);
            if get(handles.EEGmode,'Value') & ~isempty(handles.lfp_ave) & (str2num(get(handles.FrequencyRes,'String'))<=1)
                spectYLim = get(hand,'YLim');
                text(2,spectYLim(2),'\delta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(6,spectYLim(2),'\theta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(10,spectYLim(2),'\alpha','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(19,spectYLim(2),'\beta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(63,spectYLim(2),'\gamma','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                minVal = 10*log10(min(min(min(psd4view)))+eps);
                hold(hand,'on')
                tmpVect = [spectYLim(1):abs(spectYLim(2)-spectYLim(1))/50:spectYLim(2),spectYLim(2)];
                deltamat = 4*ones(1,length(tmpVect));
                plot3(deltamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                thetamat = 8*ones(1,length(tmpVect));
                plot3(thetamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                alphamat = 12*ones(1,length(tmpVect));
                plot3(alphamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                betamat = 26*ones(1,length(tmpVect));
                plot3(betamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                gammamat = 100*ones(1,length(tmpVect));
                plot3(gammamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                hold(hand,'off')
            end
        elseif ~get(handles.SpectSelectButton,'Value') & get(handles.PSDSelectButton,'Value')
            handles.myPSD = handles.myPSD;
            x = linspace(0,handles.Fs(ADchanIndex)/2,length(handles.myPSD));
            axes(hand)
            if get(handles.logPSD,'Value')
                plot(x,10*log10(handles.myPSD+eps),'r')
                ylabel(hand,'PSD (dB)','VerticalAlignment','middle')
            else
                plot(x,handles.myPSD,'r')
                ylabel(hand,'PSD','VerticalAlignment','middle')
            end
            set(hand,'AmbientLightColor','white');
            set(hand,'color', 'white');
            set(hand,'XLim',[str2num(get(handles.frequency_start,'String')) str2num(get(handles.frequency_end,'String'))])
            xlabel(hand,'Frequency (Hz)')
            if get(handles.EEGmode,'Value')
                psdYLim = get(hand,'YLim');
                text(2,psdYLim(1),'\delta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(6,psdYLim(1),'\theta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(10,psdYLim(1),'\alpha','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(19,psdYLim(1),'\beta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(63,psdYLim(1),'\gamma','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                set(hand,'XTick',[0 4 8 12 26 100])
                set(hand,'XTick',[0 4 8 12 26 100])
                hold(hand,'on')
                tmpVect = [psdYLim(1):abs(psdYLim(2)-psdYLim(1))/50:psdYLim(2),psdYLim(2)];
                deltamat = 4*ones(1,length(tmpVect));
                plot(deltamat,tmpVect,':','color',[1 0 1])
                thetamat = 8*ones(1,length(tmpVect));
                plot(thetamat,tmpVect,':','color',[1 0 1])
                alphamat = 12*ones(1,length(tmpVect));
                plot(alphamat,tmpVect,':','color',[1 0 1])
                betamat = 26*ones(1,length(tmpVect));
                plot(betamat,tmpVect,':','color',[1 0 1])
                gammamat = 100*ones(1,length(tmpVect));
                plot(gammamat,tmpVect,':','color',[1 0 1])
                hold(hand,'off')
            end
        end
        
    elseif get(handles.mode,'Value')==3 
        
        handles.Numfigs = handles.Numfigs + 1;
        fighandle = figure(handles.Numfigs);
        hand = newplot(fighandle);
        Fs = handles.PARS1(8); 
        index = ADchanIndex;
        if get(handles.SpectSelectButton,'Value') & ~get(handles.PSDSelectButton,'Value')
            NumUniquePts = sum(handles.FreqVect(:,index)~=0)+ (~handles.FreqVect(1));
            f1 = str2num(get(handles.frequency_start, 'String'));
            f2 = str2num(get(handles.frequency_end, 'String'));
            freqIndex = find((handles.FreqVect(1:NumUniquePts,index)>=f1) .* (handles.FreqVect(1:NumUniquePts,index)<=f2));
            psd4view = handles.myPSD(1:length(freqIndex),:,index);
            if str2num(get(handles.CentralFreq,'String'))~=0
                siz = size(psd4view);
                for i = 1 : siz(2)
                    ff = find(psd4view(:,i)<.01*min(max(psd4view)));
                    psd4view(ff,i) = min(max(psd4view))/100;
                end
            end
            axes(hand)
            tmpStr = get(handles.SpectShading,'String');
            shadingType = tmpStr(get(handles.SpectShading,'Value'),:);
            displayspectrogram(handles.timeaxis,handles.FreqVect(freqIndex,index),psd4view,0,[ str2num(get(handles.frequency_start, 'String')) str2num(get(handles.frequency_end, 'String')) min(handles.timeaxis) max(handles.timeaxis)],shadingType);
            colorbar;
            axis(hand,[handles.FreqVect(freqIndex(1),index) handles.FreqVect(freqIndex(end),index) min(handles.timeaxis) max(handles.timeaxis)]);
            set(hand,'YTick',-handles.lfp_pre : (handles.lfp_pre + handles.lfp_post)/10 : handles.lfp_post)
            view(90,-90);
            if get(handles.EEGmode,'Value') & ~isempty(handles.lfp_ave) & (str2num(get(handles.FrequencyRes,'String'))<=1)
                spectYLim = get(hand,'YLim');
                text(2,spectYLim(2),'\delta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(6,spectYLim(2),'\theta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(10,spectYLim(2),'\alpha','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(19,spectYLim(2),'\beta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(63,spectYLim(2),'\gamma','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                minVal = 10*log10(min(min(min(psd4view)))+eps);
                hold(hand,'on')
                tmpVect = [spectYLim(1):abs(spectYLim(2)-spectYLim(1))/50:spectYLim(2),spectYLim(2)];
                deltamat = 4*ones(1,length(tmpVect));
                plot3(deltamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                thetamat = 8*ones(1,length(tmpVect));
                plot3(thetamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                alphamat = 12*ones(1,length(tmpVect));
                plot3(alphamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                betamat = 26*ones(1,length(tmpVect));
                plot3(betamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                gammamat = 100*ones(1,length(tmpVect));
                plot3(gammamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
                hold(hand,'off')
            end
        elseif ~get(handles.SpectSelectButton,'Value') & get(handles.PSDSelectButton,'Value')
            tmpL = round((handles.lfp_pre+handles.lfp_post)*handles.Fs(index)+1);
            NumUniquePts = ceil((tmpL + 1)/2);
            x = linspace(0,handles.Fs(ADchanIndex)/2,length(handles.myPSD(1:NumUniquePts,index)));
            axes(hand)
            if get(handles.logPSD,'Value')
                plot(x,10*log10(handles.myPSD(1:NumUniquePts,index)+eps),'r')
                ylabel(hand,'PSD (dB)','VerticalAlignment','middle')
            else
                plot(x,handles.myPSD(1:NumUniquePts,index),'r')
                ylabel(hand,'PSD','VerticalAlignment','middle')
            end
            set(hand,'AmbientLightColor','white');
            set(hand,'color', 'white');
            set(hand,'XLim',[str2num(get(handles.frequency_start,'String')) str2num(get(handles.frequency_end,'String'))])
            xlabel(hand,'Frequency (Hz)')
            if get(handles.EEGmode,'Value')
                psdYLim = get(hand,'YLim');
                text(2,psdYLim(1),'\delta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(6,psdYLim(1),'\theta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(10,psdYLim(1),'\alpha','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(19,psdYLim(1),'\beta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                text(63,psdYLim(1),'\gamma','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
                set(hand,'XTick',[0 4 8 12 26 100])
                set(hand,'XTick',[0 4 8 12 26 100])
                hold(hand,'on')
                tmpVect = [psdYLim(1):abs(psdYLim(2)-psdYLim(1))/50:psdYLim(2),psdYLim(2)];
                deltamat = 4*ones(1,length(tmpVect));
                plot(deltamat,tmpVect,':','color',[1 0 1])
                thetamat = 8*ones(1,length(tmpVect));
                plot(thetamat,tmpVect,':','color',[1 0 1])
                alphamat = 12*ones(1,length(tmpVect));
                plot(alphamat,tmpVect,':','color',[1 0 1])
                betamat = 26*ones(1,length(tmpVect));
                plot(betamat,tmpVect,':','color',[1 0 1])
                gammamat = 100*ones(1,length(tmpVect));
                plot(gammamat,tmpVect,':','color',[1 0 1])
                hold(hand,'off')
            end
        end
        
    end
    
    guidata(hObject, handles);


function ExportFigures_CreateFcn(hObject, eventdata, handles) 

    if (length(get(handles.ExportFigures,'Enable')) == 2)
        set(handles.ExportFigures,'Enable','off')
    end
    guidata(hObject, handles);

    
function ExportCursor_Callback(hObject, eventdata, handles)
    Fs = handles.PARS1(8); 
    ADchan=GetADchan(handles);
    ADchanIndex = find(handles.activeChans==ADchan);

    x = -handles.lfp_pre : 1/handles.Fs(ADchanIndex) : handles.lfp_post;
    if get(handles.mode,'Value') == 3
        ADchan = GetADchan(handles);
        ADchanIndex = find(handles.activeChans==ADchan);
    end
    
    if get(handles.mode,'Value') <3
        y = handles.lfp_ave(:,1);
    elseif get(handles.mode,'Value') ==3
        y = handles.lfp_ave(1:length(x),ADchanIndex);
    end

    handles.userdata = y;
    if get(handles.DCRemoval,'Value')
        handles.userdata = handles.userdata - mean(handles.userdata);
    end
    handles.t = x;
    handles.tstep = handles.Fs(ADchanIndex);

    handles.yvalues = y;
    handles.xvalues = x;
    handles.tstep = handles.Fs(ADchanIndex);
    guidata(hObject, handles);
    Cursor_export(handles);

    
function ExportCursor_CreateFcn(hObject, eventdata, handles) 
    if (length(get(handles.ExportCursor,'Enable')) == 2)
        set(handles.ExportCursor,'Enable','off')
    end
    guidata(hObject, handles);


function NotchFilter_Callback(hObject, eventdata, handles)


function NotchFilter_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);
    
    
function filter_Callback(hObject, eventdata, handles)
    

function PSDSelect_Callback(hObject, eventdata, handles)
    set(handles.PSDSelectButton,'Value',1)
    set(handles.hannwidth,'Enable','off')
    set(handles.step_size,'Enable','off')
    set(handles.SpectShading,'Enable','off')
    set(handles.text14,'Enable','off')
    set(handles.text13,'Enable','off')
    set(handles.text32,'Enable','off')
    set(handles.uipanel3,'Title','Power Spectral Density Options')
    set(handles.logPSD,'Visible','on');
    set(handles.text30,'Visible','off');
    preVal = str2num(get(handles.pre,'String'));
    postVal = str2num(get(handles.post,'String'));
    if (preVal + postVal)<1
        FreqRes = fix(1/(preVal + postVal));
    else
        FreqRes = 1/(preVal + postVal);
    end
    set(handles.FrequencyRes,'String',num2str(FreqRes))
    if get(handles.SpectSelectButton,'Value')
        set(handles.SpectSelectButton,'Value',0)
        if get(handles.ExpertMode,'Value')
            set(handles.EEGmode,'Enable','on')
            set(handles.EEGtext,'Enable','on')
        end
        if handles.Connect 
            cla(handles.Spectrogram_plot)
            set(handles.Spectrogram_plot,'Color','white')
            set(handles.Spectrogram_plot,'AmbientLightColor','white')

            ylabel(handles.Spectrogram_plot,'PSD (dB)','VerticalAlignment','middle')
            ylim(handles.Spectrogram_plot,[0 100])
            xlabel(handles.Spectrogram_plot,'Frequency (Hz)')
            xlim(handles.Spectrogram_plot,[0 500])
        end
    end
    siz = size(handles.myPSD);
    ADchan = GetADchan(handles);
    if handles.Connect
        ADchanIndex = find(handles.activeChans==ADchan);
    end
    if  (get(handles.mode,'Value')==1) & (length(handles.myPSD)>1) & (length(handles.userdata)>1) & ~get(handles.SpectSelectButton,'Value') & handles.Connect & strcmp(get(handles.ExportFigures,'Enable'),'on')
        
        RedrawButton_Callback(hObject, eventdata, handles);
        
    elseif (get(handles.mode,'Value')==2) & (siz(2)==1) & ~get(handles.SpectSelectButton,'Value') & handles.Connect  & strcmp(get(handles.ExportFigures,'Enable'),'on')
        Fs = handles.PARS1(8); 
        if  handles.NumChan2Plot == 1
            index = 1;
        else
            index = ADchanIndex;
        end
        figure(handles.h);
        axes(handles.Spectrogram_plot)
        x = linspace(0,handles.Fs(ADchanIndex)/2,length(handles.myPSD(:,index)));
        if get(handles.logPSD,'Value')
            plot(handles.Spectrogram_plot,x,10*log10(handles.myPSD(:,index)+eps),'r')
            ylabel(handles.Spectrogram_plot,'PSD (dB)','VerticalAlignment','middle')
        else
            plot(handles.Spectrogram_plot,x,handles.myPSD(:,index),'r')
            ylabel(handles.Spectrogram_plot,'PSD','VerticalAlignment','middle')
        end
        set(handles.Spectrogram_plot,'AmbientLightColor','white');
        set(handles.Spectrogram_plot, 'color', 'white');
        set(handles.Spectrogram_plot,'XLim',[str2num(get(handles.frequency_start,'String')) str2num(get(handles.frequency_end,'String'))])
        xlabel(handles.Spectrogram_plot,'Frequency (Hz)')
        if get(handles.EEGmode,'Value')
            psdYLim = get(handles.Spectrogram_plot,'YLim');
            text(2,psdYLim(1),'\delta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(6,psdYLim(1),'\theta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(10,psdYLim(1),'\alpha','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(19,psdYLim(1),'\beta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(63,psdYLim(1),'\gamma','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            set(handles.Spectrogram_plot,'XTick',[0 4 8 12 26 100])
            hold(handles.Spectrogram_plot,'on')
            tmpVect = [psdYLim(1):abs(psdYLim(2)-psdYLim(1))/50:psdYLim(2),psdYLim(2)];
            deltamat = 4*ones(1,length(tmpVect));
            plot(deltamat,tmpVect,':','color',[1 0 1])
            thetamat = 8*ones(1,length(tmpVect));
            plot(thetamat,tmpVect,':','color',[1 0 1])
            alphamat = 12*ones(1,length(tmpVect));
            plot(alphamat,tmpVect,':','color',[1 0 1])
            betamat = 26*ones(1,length(tmpVect));
            plot(betamat,tmpVect,':','color',[1 0 1])
            gammamat = 100*ones(1,length(tmpVect));
            plot(gammamat,tmpVect,':','color',[1 0 1])
            hold(handles.Spectrogram_plot,'off')
        end
        set(handles.Spectrogram_plot,'Position',handles.spectPosition)
        
    elseif (get(handles.mode,'Value')==3) & (length(siz)==2) & ~get(handles.SpectSelectButton,'Value') & handles.Connect & strcmp(get(handles.ExportFigures,'Enable'),'on') & (length(handles.myPSD)>1)

        figure(handles.h);
        Fs = handles.PARS1(8); 
        x = -handles.lfp_pre : 1/handles.Fs(ADchanIndex) : handles.lfp_post;
        ADchan = GetADchan(handles);
        ADchanIndex = find(handles.activeChans==ADchan);
        if get(handles.mode,'Value') <3
            y = handles.lfp_ave(:,1);
        elseif get(handles.mode,'Value') ==3
            y = handles.lfp_ave(1:length(x),ADchanIndex);
        end
        cla(handles.Time_plot);
        figure(handles.h); 
        axes(handles.Time_plot)
        if handles.getTrueVoltage
            if max(abs(y))>0.001
                plot(handles.Time_plot, x,1000*y,'b')
                ylabel('Voltage (mV)','VerticalAlignment','middle')
            elseif max(abs(y))<0.001
                plot(handles.Time_plot, x,1000000*y,'b')
                ylabel('Voltage (uV)','VerticalAlignment','middle')
            end
        else
            plot(handles.Time_plot, x,y,'b')
            ylabel('Amplified Voltage','VerticalAlignment','middle')
        end
        hold(handles.Time_plot,'on')
        set(handles.Spectrogram_plot,'AmbientLightColor','white');
        set(handles.Spectrogram_plot, 'color', 'white');
        set(handles.Time_plot,'XLim',[-handles.lfp_pre handles.lfp_post])
        ylimTime = get(handles.Time_plot,'YLim');
        figure(handles.h);
        plot(handles.Time_plot, x*0,[ones(1,length(y)-1)*ylimTime(1),ylimTime(2)],'k:')
        xlabel('Time (sec)');
        set(handles.Time_plot,'AmbientLightColor','white');
        set(handles.Time_plot,'XTick',-handles.lfp_pre : (handles.lfp_pre + handles.lfp_post)/10 : handles.lfp_post)
        hold(handles.Time_plot,'off')
        if  handles.NumChan2Plot == 1
            index = 1;
        else
            index = ADchanIndex;
        end
        figure(handles.h);
        axes(handles.Spectrogram_plot)
        tmpL = round((handles.lfp_pre+handles.lfp_post)*handles.Fs(index)+1);
        NumUniquePts = ceil((tmpL + 1)/2);
        x = linspace(0,handles.Fs(ADchanIndex)/2,length(handles.myPSD(1:NumUniquePts,index)));
        if get(handles.logPSD,'Value')
            plot(handles.Spectrogram_plot,x,10*log10(handles.myPSD(1:NumUniquePts,index)+eps),'r')
            ylabel(handles.Spectrogram_plot,'PSD (dB)','VerticalAlignment','middle')
        else
            plot(handles.Spectrogram_plot,x,handles.myPSD(1:NumUniquePts,index),'r')
            ylabel(handles.Spectrogram_plot,'PSD','VerticalAlignment','middle')
        end
        set(handles.Spectrogram_plot,'AmbientLightColor','white');
        set(handles.Spectrogram_plot, 'color', 'white');
        set(handles.Spectrogram_plot,'XLim',[str2num(get(handles.frequency_start,'String')) str2num(get(handles.frequency_end,'String'))])
        xlabel(handles.Spectrogram_plot,'Frequency (Hz)')
        if get(handles.EEGmode,'Value')
            psdYLim = get(handles.Spectrogram_plot,'YLim');
            text(2,psdYLim(1),'\delta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(6,psdYLim(1),'\theta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(10,psdYLim(1),'\alpha','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(19,psdYLim(1),'\beta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(63,psdYLim(1),'\gamma','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            set(handles.Spectrogram_plot,'XTick',[0 4 8 12 26 100])
            hold(handles.Spectrogram_plot,'on')
            tmpVect = [psdYLim(1):abs(psdYLim(2)-psdYLim(1))/50:psdYLim(2),psdYLim(2)];
            deltamat = 4*ones(1,length(tmpVect));
            plot(deltamat,tmpVect,':','color',[1 0 1])
            thetamat = 8*ones(1,length(tmpVect));
            plot(thetamat,tmpVect,':','color',[1 0 1])
            alphamat = 12*ones(1,length(tmpVect));
            plot(alphamat,tmpVect,':','color',[1 0 1])
            betamat = 26*ones(1,length(tmpVect));
            plot(betamat,tmpVect,':','color',[1 0 1])
            gammamat = 100*ones(1,length(tmpVect));
            plot(gammamat,tmpVect,':','color',[1 0 1])
            hold(handles.Spectrogram_plot,'off')
        end
        set(handles.Spectrogram_plot,'Position',handles.spectPosition)
        
    end

    guidata(hObject, handles);


function SpectSelect_Callback(hObject, eventdata, handles)
    set(handles.SpectSelectButton,'Value',1)
    if get(handles.ExpertMode,'Value') & strcmp(get(handles.StopButton,'Enable'),'off')
        set(handles.hannwidth,'Enable','on')
        set(handles.step_size,'Enable','on')
        set(handles.text14,'Enable','on')
        set(handles.text13,'Enable','on')
        set(handles.FrequencyRes,'Enable','on')
        set(handles.text25,'Enable','on')
        set(handles.frequency_end,'Enable','on')
        set(handles.frequency_start,'Enable','on')
        set(handles.SpectShading,'Enable','on')
        set(handles.text32,'Enable','on')
    end
    set(handles.logPSD,'Visible','off');
    winLength = str2num(get(handles.hannwidth,'String'));
    if winLength<1
        FreqRes = fix(1/winLength);
    else
        FreqRes = 1/winLength;
    end
    set(handles.FrequencyRes,'String',num2str(FreqRes))
    set(handles.uipanel3,'Title','Spectrogram Options')
    if get(handles.PSDSelectButton,'Value')
        set(handles.PSDSelectButton,'Value',0)
        if handles.Connect 
            cla(handles.Spectrogram_plot)
            set(handles.Spectrogram_plot,'Color','white')
            set(handles.Spectrogram_plot,'AmbientLightColor','white')
            xlabel(handles.Spectrogram_plot,'Time (sec)')
            xlim(handles.Spectrogram_plot,[-str2num(get(handles.pre,'String')) str2num(get(handles.post,'String'))])
            ylabel(handles.Spectrogram_plot,'Frequency (Hz)')
            ylim(handles.Spectrogram_plot,[0 500])
        end
    end
    siz = size(handles.myPSD);
    ADchan = GetADchan(handles);
    if handles.Connect
        ADchanIndex = find(handles.activeChans==ADchan);
    end

    if  (get(handles.mode,'Value')==1) & (length(handles.myPSD)>1) & (length(handles.userdata)>1) & ~get(handles.PSDSelectButton,'Value') & handles.Connect & strcmp(get(handles.ExportFigures,'Enable'),'on')

        RedrawButton_Callback(hObject, eventdata, handles);
        
    elseif (get(handles.mode,'Value')==2) & (siz(2)>1) & ~get(handles.PSDSelectButton,'Value') & handles.Connect & strcmp(get(handles.ExportFigures,'Enable'),'on')

        if  handles.NumChan2Plot == 1
            index = 1;
        else
            index = ADchanIndex;
        end
        f1 = str2num(get(handles.frequency_start, 'String'));
        f2 = str2num(get(handles.frequency_end, 'String'));
        freqIndex = find((handles.FreqVect(:,index)>=f1) .* (handles.FreqVect(:,index)<=f2));
        psd4view = handles.myPSD(freqIndex,:,index);
        if str2num(get(handles.CentralFreq,'String'))~=0
            siz = size(psd4view);
            for i = 1 : siz(2)
                ff = find(psd4view(:,i)<.01*min(max(psd4view)));
                psd4view(ff,i) = min(max(psd4view))/100;
            end
        end
        axes(handles.Spectrogram_plot)
        tmpStr = get(handles.SpectShading,'String');
        shadingType = tmpStr(get(handles.SpectShading,'Value'),:);
        displayspectrogram(handles.timeaxis,handles.FreqVect(freqIndex,index),psd4view,0,[ str2num(get(handles.frequency_start, 'String')) str2num(get(handles.frequency_end, 'String')) min(handles.timeaxis) max(handles.timeaxis)],shadingType);
        colorbar;
        set(handles.text30,'Visible','on');
        f1 = str2num(get(handles.frequency_start, 'String'));
        f2 = str2num(get(handles.frequency_end, 'String'));
        freqIndex = find((handles.FreqVect(:,index)>=f1) .* (handles.FreqVect(:,index)<=f2));
        axis([handles.FreqVect(freqIndex(1),index) handles.FreqVect(freqIndex(end),index) min(handles.timeaxis) max(handles.timeaxis)]);
        set(handles.Spectrogram_plot,'YTick',-handles.lfp_pre : (handles.lfp_pre + handles.lfp_post)/10 : handles.lfp_post)
        view(90,-90);
        if get(handles.EEGmode,'Value') & ~isempty(handles.lfp_ave) & (str2num(get(handles.FrequencyRes,'String'))<=1)
            spectYLim = get(handles.Spectrogram_plot,'YLim');
            text(2,spectYLim(2),'\delta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(6,spectYLim(2),'\theta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(10,spectYLim(2),'\alpha','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(19,spectYLim(2),'\beta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(63,spectYLim(2),'\gamma','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            minVal = 10*log10(min(min(min(psd4view)))+eps);
            hold(handles.Spectrogram_plot,'on')
            tmpVect = [spectYLim(1):abs(spectYLim(2)-spectYLim(1))/50:spectYLim(2),spectYLim(2)];
            deltamat = 4*ones(1,length(tmpVect));
            plot3(deltamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            thetamat = 8*ones(1,length(tmpVect));
            plot3(thetamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            alphamat = 12*ones(1,length(tmpVect));
            plot3(alphamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            betamat = 26*ones(1,length(tmpVect));
            plot3(betamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            gammamat = 100*ones(1,length(tmpVect));
            plot3(gammamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            hold(handles.Spectrogram_plot,'off')
        end
        set(handles.Spectrogram_plot,'Position',handles.spectPosition)
        
    elseif (get(handles.mode,'Value')==3) & (length(siz)==3) & ~get(handles.PSDSelectButton,'Value') & handles.Connect & strcmp(get(handles.ExportFigures,'Enable'),'on')

        figure(handles.h);
        Fs = handles.PARS1(8); 
        x = -handles.lfp_pre : 1/handles.Fs(ADchanIndex) : handles.lfp_post;
        ADchan = GetADchan(handles);
        ADchanIndex = find(handles.activeChans==ADchan);
        if get(handles.mode,'Value') <3
            y = handles.lfp_ave(:,1);
        elseif get(handles.mode,'Value') ==3
            y = handles.lfp_ave(1:length(x),ADchanIndex);
        end
        cla(handles.Time_plot);
        figure(handles.h); 
        axes(handles.Time_plot)
        if handles.getTrueVoltage
            if max(abs(y))>0.001
                plot(handles.Time_plot, x,1000*y,'b')
                ylabel('Voltage (mV)','VerticalAlignment','middle')
            elseif max(abs(y))<0.001
                plot(handles.Time_plot, x,1000000*y,'b')
                ylabel('Voltage (uV)','VerticalAlignment','middle')
            end
        else
            plot(handles.Time_plot, x,y,'b')
            ylabel('Amplified Voltage','VerticalAlignment','middle')
        end
        hold(handles.Time_plot,'on')
        set(handles.Spectrogram_plot,'AmbientLightColor','white');
        set(handles.Spectrogram_plot, 'color', 'white');
        set(handles.Time_plot,'XLim',[-handles.lfp_pre handles.lfp_post])
        ylimTime = get(handles.Time_plot,'YLim');
        figure(handles.h);
        plot(handles.Time_plot, x*0,[ones(1,length(y)-1)*ylimTime(1),ylimTime(2)],'k:')
        xlabel('Time (sec)');
        set(handles.Time_plot,'AmbientLightColor','white');
        set(handles.Time_plot,'XTick',-handles.lfp_pre : (handles.lfp_pre + handles.lfp_post)/10 : handles.lfp_post)
        hold(handles.Time_plot,'off')
        if  handles.NumChan2Plot == 1
            index = 1;
        else
            index = ADchanIndex;
        end
        NumUniquePts = sum(handles.FreqVect(:,index)~=0)+ (~handles.FreqVect(1));
        f1 = str2num(get(handles.frequency_start, 'String'));
        f2 = str2num(get(handles.frequency_end, 'String'));
        freqIndex = find((handles.FreqVect(1:NumUniquePts,index)>=f1) .* (handles.FreqVect(1:NumUniquePts,index)<=f2));
        psd4view = handles.myPSD(1:length(freqIndex),:,index);
        if str2num(get(handles.CentralFreq,'String'))~=0
            siz = size(psd4view);
            for i = 1 : siz(2)
                ff = find(psd4view(:,i)<.01*min(max(psd4view)));
                psd4view(ff,i) = min(max(psd4view))/100;
            end
        end
        axes(handles.Spectrogram_plot)
        tmpStr = get(handles.SpectShading,'String');
        shadingType = tmpStr(get(handles.SpectShading,'Value'),:);
        displayspectrogram(handles.timeaxis,handles.FreqVect(freqIndex,index),psd4view,0,[ str2num(get(handles.frequency_start, 'String')) str2num(get(handles.frequency_end, 'String')) min(handles.timeaxis) max(handles.timeaxis)],shadingType);
        colorbar; 
        set(handles.text30,'Visible','on');
        axis([handles.FreqVect(freqIndex(1),index) handles.FreqVect(freqIndex(end),index) min(handles.timeaxis) max(handles.timeaxis)]);
        set(handles.Spectrogram_plot,'YTick',-handles.lfp_pre : (handles.lfp_pre + handles.lfp_post)/10 : handles.lfp_post)
        view(90,-90);
        if get(handles.EEGmode,'Value') & ~isempty(handles.lfp_ave) & (str2num(get(handles.FrequencyRes,'String'))<=1)
            spectYLim = get(handles.Spectrogram_plot,'YLim');
            text(2,spectYLim(2),'\delta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(6,spectYLim(2),'\theta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(10,spectYLim(2),'\alpha','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(19,spectYLim(2),'\beta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(63,spectYLim(2),'\gamma','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            minVal = 10*log10(min(min(min(psd4view)))+eps);
            hold(handles.Spectrogram_plot,'on')
            tmpVect = [spectYLim(1):abs(spectYLim(2)-spectYLim(1))/50:spectYLim(2),spectYLim(2)];
            deltamat = 4*ones(1,length(tmpVect));
            plot3(deltamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            thetamat = 8*ones(1,length(tmpVect));
            plot3(thetamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            alphamat = 12*ones(1,length(tmpVect));
            plot3(alphamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            betamat = 26*ones(1,length(tmpVect));
            plot3(betamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            gammamat = 100*ones(1,length(tmpVect));
            plot3(gammamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            hold(handles.Spectrogram_plot,'off')
        end
        set(handles.Spectrogram_plot,'Position',handles.spectPosition)
        
    end

    guidata(hObject, handles);
    
    
function win_shape_Callback(hObject, eventdata, handles)


function win_shape_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);


function hannwidth_Callback(hObject, eventdata, handles)
    val = str2num(get(handles.hannwidth,'String'));
    handles.STFTstep = str2num(get(handles.step_size, 'String'));
    handles.lfp_post = str2num(get(handles.post,'String'));
    handles.lfp_pre = str2num(get(handles.pre,'String'));
    if isempty(val)
        set(handles.hannwidth,'String',num2str((handles.lfp_post+handles.lfp_pre)*0.2 ));
    else
        if(str2num(get(handles.hannwidth, 'String')) >= (handles.lfp_post+handles.lfp_pre-handles.STFTstep))
            errordlg('The window length must be less than the duration of the selected signal',...
                'Incorrect Selection','modal')
            set(handles.hannwidth, 'String' ,num2str((handles.lfp_post+handles.lfp_pre)*0.2 ))
        end
        if str2num(get(handles.CentralFreq,'String'))
            if str2num(get(handles.hannwidth,'String')) < 1/str2num(get(handles.CentralFreq,'String'))
                errordlg('The window length must not be less than one-tenth of the duration of the selected signal',...
                    'Incorrect Selection','modal')
                set(handles.hannwidth, 'String' ,num2str((handles.lfp_post+handles.lfp_pre)*0.1 ))
            end
        end
        if str2num(get(handles.hannwidth,'String')) < str2num(get(handles.step_size,'String'))
            set(handles.step_size,'String',str2num(get(handles.hannwidth,'String'))*0.5);
        end
        if ~get(handles.PSDSelectButton,'Value')
            hannwidth = str2num(get(handles.hannwidth,'String'));
            if hannwidth<1
                FreqRes = fix(1/hannwidth);
            else
                FreqRes = 1/hannwidth;
            end
            set(handles.FrequencyRes,'String',num2str(FreqRes))
        end
    end
    guidata(hObject, handles);
    

function hannwidth_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);


function step_size_Callback(hObject, eventdata, handles)
    val = str2num(get(handles.step_size,'String'));
    if isempty(val)
        set(handles.step_size,'String',0.5*str2num(get(handles.hannwidth, 'String')));
    end
    handles.lfp_post = str2num(get(handles.post,'String'));
    handles.lfp_pre = str2num(get(handles.pre,'String'));
    if str2num(get(handles.step_size,'String')) > str2num(get(handles.hannwidth,'String'))
        errordlg('Step size must be no greater than window length',...
            'Incorrect Selection','modal')
        set(handles.step_size, 'String' ,str2num(get(handles.hannwidth, 'String'))*0.5);
    elseif str2num(get(handles.step_size,'String'))>= ((handles.lfp_post+handles.lfp_pre)-str2num(get(handles.hannwidth, 'String')))
        errordlg('Window length and step size too long for selected signal ',...
            'Incorrect Selection','modal')
        set(handles.step_size, 'String' ,(num2str(((handles.lfp_post+handles.lfp_pre)-str2num(get(handles.hannwidth, 'String')))*0.5 )));
    end

    guidata(hObject,handles);
    
    
function step_size_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);
    

function fouri_epon_Callback(hObject, eventdata, handles)
    handles.FourierN = 2^(get(handles.fouri_epon,'Value') + 3); 
    guidata(hObject,handles);

    
function fouri_epon_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);
    
    
function EventButton_Callback(hObject, eventdata, handles)
    set(handles.eventsButton, 'Value',1);
    if get(handles.spikesButton, 'Value')
        set(handles.spikesButton, 'Value',0);
    end
    set(handles.text2,'String','Event Channel')
    set(handles.text1,'String','# Events Accumulated')
    set(handles.text9,'String','# Events to Plot')
    set(handles.NumEvents2Plot,'Value',1)
    if (get(handles.mode,'Value') == 1 )
        set(handles.NumEvents2Plot,'Enable','on')
    end
    set(handles.SpikeUnit,'Value',1);
    set(handles.SpikeUnit,'String','Unsorted')
    set(handles.SpikeUnit,'Enable','off')
    guidata(hObject, handles);
    
    
function spikesButton_Callback(hObject, eventdata, handles)
    set(handles.spikesButton, 'Value',1);
    if get(handles.eventsButton, 'Value')
        set(handles.eventsButton, 'Value',0);
    end
    set(handles.text2,'String','Spike Channel')
    set(handles.text1,'String','# Spikes Accumulated')
    set(handles.text9,'String','# Spikes to Plot')
    set(handles.NumEvents2Plot,'Value',1)
    set(handles.NumEvents2Plot,'Enable','off')
    if handles.Connect & (get(handles.spikesButton,'Value') == 1) & (get(handles.eventsButton,'Value') == 0)
        set(handles.SpikeUnit,'Enable','on')
        chanNo = str2num(get(handles.eventBox,'String'));
        unitsNo = handles.counts(1,chanNo);
        if ~unitsNo
            set(handles.SpikeUnit,'Value',1);
            set(handles.SpikeUnit,'String','Unsorted')
        else
            set(handles.SpikeUnit,'String',{'Unsorted' ; char((96+[1:unitsNo])')})
        end
    end
    guidata(hObject, handles);
    
    
function frequency_end_Callback(hObject, eventdata, handles)
    if handles.Connect
        ADchan = GetADchan(handles);
        ADchanIndex = find(handles.activeChans==ADchan);
        Fs=handles.PARS1(8); 
        if str2num(get(hObject,'String'))>handles.Fs(ADchanIndex)/2
            set(hObject, 'String' ,num2str(handles.Fs(ADchanIndex)/2));
        end
        val = str2num(get(handles.frequency_end,'String'));
        if isempty(val)
            set(handles.frequency_end,'String',num2str(handles.Fs(ADchanIndex)/2));
        end
    end
    guidata(hObject,handles);
    

function frequency_end_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);


function frequency_start_Callback(hObject, eventdata, handles)
    if handles.Connect
        Fs = handles.PARS1(8); 
        if ( str2num(get(hObject,'String')) > str2num(get(handles.frequency_end,'String')) ) | (str2num(get(hObject,'String'))<0)
            set(hObject, 'String' ,0);
        end
        val = str2num(get(handles.frequency_start,'String'));
        if isempty(val)
            set(handles.frequency_start,'String',0);
        end
    end
    guidata(hObject,handles);
    

function frequency_start_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);

    
function EEGmode_Callback(hObject, eventdata, handles)
    if get(handles.EEGmode,'Value') & get(handles.PSDSelectButton,'Value')
        if strcmp(get(handles.frequency_start,'Enable'),'on') & strcmp(get(handles.frequency_end,'Enable'),'on')
            set(handles.frequency_start,'String',0)
            set(handles.frequency_end,'String',100)
        end
        if get(handles.EEGmode,'Value') & ~isempty(handles.lfp_ave)
            axes(handles.Spectrogram_plot)
            psdYLim = get(handles.Spectrogram_plot,'YLim');
            text(2,psdYLim(1),'\delta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(6,psdYLim(1),'\theta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(10,psdYLim(1),'\alpha','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(19,psdYLim(1),'\beta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(63,psdYLim(1),'\gamma','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            set(handles.Spectrogram_plot,'XTick',[0 4 8 12 26 100])
            hold(handles.Spectrogram_plot,'on')
            tmpVect = [psdYLim(1):abs(psdYLim(2)-psdYLim(1))/50:psdYLim(2),psdYLim(2)];
            deltamat = 4*ones(1,length(tmpVect));
            plot(deltamat,tmpVect,':','color',[1 0 1])
            thetamat = 8*ones(1,length(tmpVect));
            plot(thetamat,tmpVect,':','color',[1 0 1])
            alphamat = 12*ones(1,length(tmpVect));
            plot(alphamat,tmpVect,':','color',[1 0 1])
            betamat = 26*ones(1,length(tmpVect));
            plot(betamat,tmpVect,':','color',[1 0 1])
            gammamat = 100*ones(1,length(tmpVect));
            plot(gammamat,tmpVect,':','color',[1 0 1])
            hold(handles.Spectrogram_plot,'off')
        end
        if strcmp(get(handles.StopButton,'Enable'),'off') & ~isempty(handles.lfp_ave) & ~isempty(handles.eventCue)
            if get(handles.mode,'Value')==1
                RedrawButton_Callback(hObject, eventdata, handles);
            else
                PSDSelect_Callback(hObject, eventdata, handles);
            end
        end
    elseif get(handles.EEGmode,'Value') & get(handles.SpectSelectButton,'Value')
        if strcmp(get(handles.frequency_start,'Enable'),'on') & strcmp(get(handles.frequency_end,'Enable'),'on')
            set(handles.frequency_start,'String',0)
            set(handles.frequency_end,'String',100)
        end
        if get(handles.EEGmode,'Value') & ~isempty(handles.lfp_ave) & (str2num(get(handles.FrequencyRes,'String'))<=1)
            axes(handles.Spectrogram_plot)
            spectYLim = get(handles.Spectrogram_plot,'YLim');
            text(2,spectYLim(2),'\delta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(6,spectYLim(2),'\theta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(10,spectYLim(2),'\alpha','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(19,spectYLim(2),'\beta','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            text(63,spectYLim(2),'\gamma','VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold','FontSize',14,'Color',[1 0 1]);
            minVal = 10*log10(min(min(min(handles.myPSD)))+eps);
            hold(handles.Spectrogram_plot,'on')
            tmpVect = [spectYLim(1):abs(spectYLim(2)-spectYLim(1))/50:spectYLim(2),spectYLim(2)];
            deltamat = 4*ones(1,length(tmpVect));
            plot3(deltamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            thetamat = 8*ones(1,length(tmpVect));
            plot3(thetamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            alphamat = 12*ones(1,length(tmpVect));
            plot3(alphamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            betamat = 26*ones(1,length(tmpVect));
            plot3(betamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            gammamat = 100*ones(1,length(tmpVect));
            plot3(gammamat,tmpVect,minVal*ones(1,length(tmpVect)),'-.','color',[1 0 1])
            hold(handles.Spectrogram_plot,'off')
        end
        if (str2num(get(handles.FrequencyRes,'String'))>1)
            if strcmp(get(handles.StopButton,'Enable'),'off')
                set(handles.FrequencyRes,'String',1);
                FrequencyRes_Callback(hObject, eventdata, handles)
                set(handles.redrawButton,'Enable','off')
            else
                errordlg('You need to set the frequency resolution to less than or equal to 1Hz')
                set(handles.EEGmode,'Value',0)
            end
        end
    else
        if ~isempty(handles.lfp_ave) & ~isempty(handles.eventCue)
            if get(handles.mode,'Value')==1
                if  strcmp(get(handles.redrawButton,'Enable'),'on') | get(handles.PSDSelectButton,'Value')
                    RedrawButton_Callback(hObject, eventdata, handles);
                end
            else
                if get(handles.PSDSelectButton,'Value')
                    PSDSelect_Callback(hObject, eventdata, handles);
                else
                    SpectSelect_Callback(hObject, eventdata, handles);
                end
            end
        end
    end
    guidata(hObject, handles);
    
    
function logPSD_Callback(hObject, eventdata, handles)
    if strcmp(get(handles.StopButton,'Enable'),'off') & ~isempty(handles.lfp_ave) & ~isempty(handles.eventCue)
        if get(handles.mode,'Value')==1
            RedrawButton_Callback(hObject, eventdata, handles);
        else
            PSDSelect_Callback(hObject, eventdata, handles);
        end
    end
    guidata(hObject, handles);
    
    