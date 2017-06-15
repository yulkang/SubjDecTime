
function varargout = ContinuousLFPClient(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ContinuousLFPClient_OpeningFcn, ...
                   'gui_OutputFcn',  @ContinuousLFPClient_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
    
gui_State.gui_Name = 'ContinuousLFPClient'; 

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


% End initialization code - DO NOT EDIT

function ContinuousLFPClient_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to ContinuousLFPClient (see VARARGIN)

    % Choose default command line output for ContinuousLFPClient
    handles.output = hObject;
    handles.getTrueVoltage = 1;
    i = 0;
    handles.S1 = [];
    handles.PARS1 = [];
    handles.CONNECTED1  = [];
    handles.RUNNING1 = [];
    handles.hhh = [];
    handles.Fs = 1000;
    handles.chansIndex4Plot = [];
    handles.STFTstep = 0.01;    
    handles.FourierN = 2048;    
    handles.myPSD = 0;
    handles.Connect = 0;
    handles.dd = 0;
    handles.start = 0;
    handles.previousEndIndex = 0;
    handles.P = 0;
    handles.timeaxis = 0;
    handles.FreqVect = 0;
    set(handles.fouri_epon,'Value',1)
    set(handles.text1,'String','# Plots Accumulated');
    set(handles.text6,'Enable','on')
    set(handles.updateTime,'Enable','on')
    set(handles.ExpertMode,'Value',0)
    if get(handles.ExpertMode,'Value')
        set(handles.text15,'Enable','on')
        set(handles.win_shape,'Enable','on')
        set(handles.notchtext,'Enable','on')
        set(handles.NotchFilter,'Enable','on')
        set(handles.text38,'Enable','on')
        set(handles.SpectShading,'Enable','on')
        set(handles.text14,'Enable','on')
        set(handles.hannwidth,'Enable','on')
        set(handles.text13,'Enable','on')
        set(handles.step_size,'Enable','on')
        set(handles.text12,'Enable','on')
        set(handles.frequency_end,'Enable','on')
        set(handles.text21,'Enable','on')
        set(handles.frequency_start,'Enable','on')
    else
        set(handles.text15,'Enable','off')
        set(handles.win_shape,'Enable','off')
        set(handles.notchtext,'Enable','off')
        set(handles.NotchFilter,'Enable','off')
        set(handles.text38,'Enable','off')
        set(handles.SpectShading,'Enable','off')
        set(handles.text12,'Enable','off')
        set(handles.frequency_end,'Enable','off')
        set(handles.text21,'Enable','off')
        set(handles.frequency_start,'Enable','off')
    end
    set(handles.numPlots,'String',0);
    set(handles.Time_plot,'XLim',[0 100])
    set(handles.Time_plot,'YLim',[0 1])
    ylabel(handles.Time_plot,'PSD')
    xlabel(handles.Time_plot,'Frequency (Hz)')
    set(handles.Spectrogram_plot,'YLim',[0 60])
    set(handles.Spectrogram_plot,'XLim',[0 100])
    ylabel(handles.Spectrogram_plot,'Time (sec)')
    xlabel(handles.Spectrogram_plot,'Frequency (Hz)')
    set(handles.SelectADchan,'Enable','on')
    set(handles.SelectEventchan,'Enable','on')
    set(handles.ConnectBtn,'Enable','on')
    set(handles.DisConBtn,'Enable','off')
    set(handles.samplingFreq,'String',0)
    set(handles.MaxScale,'Enable','on')
    set(handles.MaxScale,'Value',1)
    set(handles.AutoScale,'Enable','on')
    set(handles.AutoScale,'Value',1)
    set(handles.logPSD,'Enable','on')
    set(handles.logPSD,'Value',1)
    set(handles.EEGmode,'Value',0)
    set(handles.EEGmode,'Enable','off')
    set(handles.EEGtext,'Enable','off')

    set(handles.dialogBox,'String','Please connect to server')
    set(handles.dialogBox,'ForegroundColor',[0 0 0]);
    handles.spectPosition = get(handles.Spectrogram_plot,'Position');
    guidata(hObject, handles);


    cla(handles.Time_plot);
    cla(handles.Spectrogram_plot);


function varargout = ContinuousLFPClient_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ContinuousLFPClientFns(handles, hObject)

    global stopped
    
    switch handles.action

        case 'connect'
            
            if ~isempty(handles.RUNNING1) | ~isempty(handles.CONNECTED1)
                dialogString = char('Already Connected to Server');
                set(handles.dialogBox,'String',dialogString);
                set(handles.dialogBox,'ForegroundColor',[0 0 0]);
                set(handles.DisConBtn,'Enable','on')
                set(handles.ConnectBtn,'Enable','off')
                return
            end
            handles.S1 = 0;
            handles.S1 = PL_InitClient(0);
            set(handles.SelectADchan,'Value',1)
            set(handles.SelectADchan,'String','None')
            set(handles.SelectEventchan,'Value',1)
            handles.counts = PL_GetNumUnits(handles.S1);
            if handles.S1 ~=  0
                handles.PARS1 = PL_GetPars(handles.S1);
                tmpPARS1 = handles.PARS1(270:525);
                handles.activeChans = tmpPARS1(find(tmpPARS1~=0));
                set(handles.listbox1,'Value',1);
                set(handles.listbox1,'String',char(num2str(handles.activeChans)))
                set(handles.listbox1,'Value',1);
                set(handles.listbox2,'String',[])
                listBox1chan = get(handles.listbox1,'Value');
                tmpStr4chan = get(handles.listbox1,'String');
                ADchan = str2num(char(tmpStr4chan(listBox1chan,:)));
                ADchanIndex = find(handles.activeChans==ADchan);
                tmpStr4chan = get(handles.listbox1,'String');
                handles.Fs = handles.PARS1(14:13+length(tmpStr4chan));
                try
                    handles.ADGains = PL_GetADGains(handles.S1);
                catch
                    errordlg('The Rasputin version id older than 2.5.0. You cannot get actual voltage values!','Old Version!')
                    handles.getTrueVoltage = 0;
                end
                SetSamplingFreq(handles,ADchanIndex);
                set(handles.frequency_end,'String',min(fix(handles.Fs(ADchanIndex)/2),str2num(get(handles.frequency_end,'String'))));
                set(handles.DisConBtn,'Enable','on')
                set(handles.ConnectBtn,'Enable','off')
                if (length(get(handles.StartButton,'Enable')) == 3)
                    set(handles.StartButton,'Enable','on')
                end
                handles.CONNECTED1 = 1;
                dialogString = char('Connected to Server');
                set(handles.dialogBox,'String',dialogString);
                set(handles.dialogBox,'ForegroundColor',[0 0 0]);
                handles.chansIndex4Plot = [];
            end
            
            guidata(hObject, handles);

        case 'disconnect'

            if ~isempty(handles.RUNNING1)
                handles.action = 'stop';
                ContinuousLFPClientFns(handles, hObject);
                pause(0.5);
            end
            if ~isempty(handles.CONNECTED1)
                PL_Close(handles.S1);
                handles.S1=[];
                handles.CONNECTED1=[];
                handles.RUNNING1 = [];
                dialogString=char('Disconnected from Server');
                set(handles.dialogBox,'String',dialogString);
                set(handles.dialogBox,'ForegroundColor',[0 0 0]);
            end
            set(handles.StopButton, 'Value', 0);
            set(handles.ConnectBtn,'Enable','on')
            set(handles.DisConBtn,'Enable','off')
            handles.chansIndex4Plot = [];
            ResetSamplingFreq(handles);
            guidata(hObject, handles);

        case 'stop'

            if ~isempty(handles.RUNNING1)
                dialogString=char('Stopped Plotting');
                set(handles.dialogBox,'String',dialogString);
                set(handles.dialogBox,'ForegroundColor',[0 0 0]);
            else
                set(handles.StopButton, 'Value', 0);
            end
            stopped = 1;
            handles.RUNNING1 = [];
            guidata(hObject, handles);

        case 'plot'
            
            if isempty(handles.CONNECTED1)
                dialogString = char('Error: First Connect to Server');
                set(handles.dialogBox,'String',dialogString);
                return
            end
            if ~isempty(handles.RUNNING1)
                return
            end

            cla(handles.Spectrogram_plot);
            dialogString = char('Plotting AD Data');
            set(handles.dialogBox,'String',dialogString);
            handles.RUNNING1 = 1;
            stopped = 0;
            tmpD = []; 
            NumADchan = handles.PARS1(7);
            handles.NumChan4Plot = length(get(handles.listbox2,'String'));
            handles.chans4Plot = str2num(char(get(handles.listbox2,'String'))); 
            Fs = handles.PARS1(8); 
            handles.updateTime4Plot = str2num(get(handles.updateTime,'String')); 
            handles.FreqRes = str2num(get(handles.FrequencyRes,'String'));
            RequiredTime = max(handles.updateTime4Plot,1/handles.FreqRes); 
            OverlapTime = RequiredTime - handles.updateTime4Plot;
            
            handles.Fs4Plot = handles.Fs(handles.chansIndex4Plot); 
            ADchan = GetADchan(handles); 
            ADchanIndex = find(handles.activeChans==ADchan);
            SetSamplingFreq(handles,ADchanIndex);
            NumUniquePts = zeros(1,handles.NumChan4Plot);
            handles.eventCue = [];
            totNumPlots = 0; 
            SetNumPlots(totNumPlots, handles)
            handles.userdata = 0;
            handles.FreqVect = 0; 
            T = 0;
            count = 0; 
            pausecount = 0;
            handles.P = 0;
            handles.timeaxis = 0;
            handles.myPSD = 0;
            handles.dd = 0;
            timeIndex = 0;
            curEvents = [];
            firstFlag = 0;
            freezFlag = 0;
            handles.F = 0;
            dialogString = ['Plotting Spectrogram for AD # ' num2str(ADchan)];
            set(handles.dialogBox,'String',dialogString);
            set(handles.dialogBox,'ForegroundColor',[0 0 0]);
            tmpStr = get(handles.SpectShading,'String');
            shadingType = tmpStr(get(handles.SpectShading,'Value'),:);
            %------------preparing the plots area-------------
            fac = factor(handles.NumChan4Plot);
            if handles.NumChan4Plot>16
                errordlg('The number of channels cannot be more than 16!','Incorrect Selection','modal');
                handles.action = 'stop';
                ContinuousLFPClientFns(handles, hObject);
                return;
            end
            if length(fac)==1
                rows = fac;
                columns = 1;
                if handles.NumChan4Plot==1
                    fontsize = 10;
                elseif handles.NumChan4Plot==2 | handles.NumChan4Plot==3
                    fontsize = 8;
                elseif handles.NumChan4Plot==5 | handles.NumChan4Plot==7
                    fontsize = 7;
                else
                    fontsize = 6;
                end
            elseif length(fac)==2
                rows = max(fac);
                columns = min(fac);
                if handles.NumChan4Plot==4
                    fontsize = 8;
                elseif handles.NumChan4Plot==6 | handles.NumChan4Plot==9 | handles.NumChan4Plot==10
                    fontsize = 7;
                else
                    fontsize = 6;
                end
            elseif length(fac)==3
                tmp = [fac(2)*fac(3),fac(1)*fac(3),fac(1)*fac(2)];
                [tmax tInd] = max(tmp);
                rows = max(tmax);
                columns = fac(tInd);
                fontsize = 7;
            elseif handles.NumChan4Plot==16
                rows = 4;
                columns = 4;
                fontsize = 6;
            end
            figure(handles.h);
            if handles.start == 0
                axes(handles.Time_plot)
                newHandle = newplot(handles.Time_plot);
                handles.start = 1;
            else
                if ~isempty(handles.hhh)
                    siz = size(handles.hhh);
                    for i = 1 : siz(1)
                        for j = 1 : siz(2)
                            if ishandle(handles.hhh(i,j))
                                delete(handles.hhh(i,j));
                            end
                        end
                    end
                end
                handles.hhh = [];
                init4PSDPlot(handles.h);
            end
            for i = 1 : rows
                for j = 1 : columns
                    handles.hhh(i,j) = subplot(rows,columns,(i-1)*columns + j);
                    set(handles.hhh(i,j),'FontSize',fontsize)
                    set(handles.hhh(i,j),'Units','characters')
                    hhhPosition(:,:,i,j) = get(handles.hhh(i,j),'Position');
                end
            end
            guidata(hObject, handles);
           %--------------------------------------------------
            
            startTimeIndex = 0;
            stopTimeIndex = str2num(get(handles.SpectTimeLength,'String'));
            handles.userdata = zeros(round(handles.updateTime4Plot * max(handles.Fs4Plot)),handles.NumChan4Plot);
            handles.lfp_start = zeros(1,handles.NumChan4Plot);
            handles.lfp_stop = zeros(1,handles.NumChan4Plot);
            
            eventchan = get(handles.SelectEventchan,'Value');
            if eventchan <= 17
                event = eventchan - 1;
            elseif eventchan == 18
                event = 257;
            elseif eventchan>=19 & eventchan<=27
                event = 101 + eventchan - 19;
            end
                
            for i = 1 : handles.NumChan4Plot
                Len(i) = round(RequiredTime*handles.Fs4Plot(i));
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
                for i = 1 : handles.NumChan4Plot
                    w0 = notchFreq/handles.Fs4Plot(i)*2;
                    bw = const1/handles.Fs4Plot(i)*2;
                    nbw = bw*pi;
                    nw0 = w0*pi;
                    g = 10^(-const2/20);
                    tmp = tan(nbw/2)*(sqrt(1-g^2)/g);
                    G = 1/(1+tmp);
                    bCoeffs(:,i) = G*[1 -2*cos(nw0) 1];
                    aCoeffs(:,i) = [1 -2*G*cos(nw0) (2*G-1)];
                end
            end

            [num,ts] = PL_GetTS(handles.S1);
            [n,t,d] = PL_GetADEx(handles.S1);
            d = d(:,handles.chansIndex4Plot);
            n = n(handles.chansIndex4Plot);
            if handles.getTrueVoltage
                for i = 1 : length(n)
                    d(:,i) = d(:,i)/2048*5/handles.ADGains(handles.activeChans(i));
                end
            end
            nn = n;
            if ~stopped
                t1 = t;
                handles.dd = d;
            end
            handles.previousEndIndex = n;
            flag = 0;
            tic;
            
            while ~get(handles.StopButton, 'Value') & handles.Connect & ~stopped 
                
                nn = n;
                [mxnn mxInd] = max(nn);
                OverlapSamplesVect = round(OverlapTime * handles.Fs4Plot);
                if ~isempty(d) & flag 
                    Nrows = mxnn + max(OverlapSamplesVect);
                    tempdd = zeros(round(Nrows),handles.NumChan4Plot);
                    for i = 1 : handles.NumChan4Plot
                        if count
                            try
                                tempdd(:,i) = handles.dd((handles.previousEndIndex(i)-OverlapSamplesVect(i)+1) : (handles.previousEndIndex(i)+mxnn) , i);
                            catch
                                tempdd = handles.dd;
                            end
                        else
                            tempdd = handles.dd;
                        end
                    end
                else
                    tempdd = [];
                end
                handles.dd = tempdd;
                
                pausecount = 0;
                serverEventIn = 0;
                while serverEventIn == 0
                    if get(handles.StopButton, 'Value') | (~handles.Connect) | (stopped)
                        set(handles.StopButton, 'Value',1);
                        return
                    end
                    if flag 
                        residualTime = length(handles.dd(:,1))/max(handles.Fs4Plot);
                    else
                        residualTime = 0;
                    end
                    tmpTime = toc;
                    if ((RequiredTime - tmpTime)>0) & (~flag)
                        pause(RequiredTime - tmpTime);
                    elseif flag & (residualTime < RequiredTime) & ((RequiredTime - residualTime - tmpTime)>0) 
                        pause(RequiredTime - residualTime - tmpTime);
                        pausecount = pausecount + 1;
                    end
                    tic;
                    try
                        %serverEventIn = PL_WaitForServer(handles.S1,5000);
                        if ((RequiredTime - tmpTime)>0) & (~flag)
                            serverEventIn = PL_WaitForServer(handles.S1,(RequiredTime - tmpTime)*1000);
                        elseif flag & (residualTime < RequiredTime) & ((RequiredTime - residualTime - tmpTime)>0) 
                            serverEventIn = PL_WaitForServer(handles.S1,(RequiredTime - residualTime - tmpTime)*1000);
                        else
                            serverEventIn = PL_WaitForServer(handles.S1,0);
                        end
                    catch
                        errordlg('Cannot get data from the server!');
                        return
                    end
                    if pausecount > 1
                        break;
                    end
                end
                
                [num,ts] = PL_GetTS(handles.S1);
                [n,t,d] = PL_GetADEx(handles.S1);
                d = d(:,handles.chansIndex4Plot);
                n = n(handles.chansIndex4Plot);
                if handles.getTrueVoltage
                    for i = 1 : length(n)
                        d(:,i) = d(:,i)/2048*5/handles.ADGains(handles.activeChans(i));
                    end
                end

                if get(handles.NotchFilter, 'Value')~=1
                    try
                        for i = 1 : handles.NumChan4Plot
                            d(1:n(i),i) = filtfilt(bCoeffs(:,i), aCoeffs(:,i),  d(1:n(i),i));
                        end
                    catch
                        if(~handles.F)
                            handles.F = 1;
                            guidata(hObject, handles);
                            errordlg('There is not enough data to apply the notch filter!', 'Notch Filter');
                        end
                    end
                end

                if flag == 0
                    initTime = t + RequiredTime - handles.updateTime4Plot;
                end

                if event
                    eventsTimeStamp = ts(find((ts(:,1) == 4).*(ts(:,2) == event)),4) - initTime;
                    curEvents = [curEvents ; eventsTimeStamp];
                end
                
                if ~flag
                    tmpNoPlottedSamples = RequiredTime * handles.Fs4Plot;
                end
                
                handles.dd = [handles.dd;d];
                for i = 1 : handles.NumChan4Plot
                    if flag
                        if count
                            handles.dd((nn(i)+OverlapSamplesVect(i)+1):(nn(i)+OverlapSamplesVect(i)+n(i)),i) = d(1:n(i),i);
                            if (nn(i)+n(i)+OverlapSamplesVect(i)+1) < length(handles.dd(:,i))
                                handles.dd((nn(i)+n(i)+OverlapSamplesVect(i)+1):end,i) = 0;
                            end
                        else
                            handles.dd((nn(i)+1):(nn(i)+n(i)),i) = d(1:n(i),i);
                            if (nn(i)+n(i)+1) < length(handles.dd(:,i))
                                handles.dd((nn(i)+n(i)+1):end,i) = 0;
                            end
                        end
                    end
                end
                
                if flag 
                    if count
                        n = nn + n + OverlapSamplesVect;
                    else
                        n = nn + n;
                    end
                else
                    n = n;
                end
                
                if ~flag
                    nn = 0;
                    flag = 1;
                end
                if count
                    count = 0;
                end
                handles.previousEndIndex = zeros(size(n));
                
                while (n./handles.Fs4Plot >= RequiredTime) 
                    
                    %-----------------------------------------------------
                    % To repeat the spectrogram for the lagged
                    % time and go to the next data chunk to preserve 
                    % syncronization, The following code within "If" was
                    % written
                    if tmpTime(end)>handles.updateTime4Plot & firstFlag
                        tmpStart = startColumn;
                        tmpStop = stopColumn;
                        
                        while (n./handles.Fs4Plot >= RequiredTime) 
                            count = count + 1;
                            if (totNumPlots < tmpRatio)
                                startColumn = rem(totNumPlots,tmpRatio) * length(T(:,1)) + 1;
                                stopColumn = startColumn -1 + length(T(:,1));
                                handles.mySpect(:,startColumn:stopColumn,1) = handles.mySpect(:,tmpStart:tmpStop,1);
                            elseif tmpRatio>1
                                handles.mySpect(:,1:(end-1),1) = handles.mySpect(:,2:end,1) ;
                                startColumn = length(handles.mySpect(1,1:end,1));
                                stopColumn = startColumn -1 + length(T(:,1));
                                handles.mySpect(:,startColumn:stopColumn,1) = handles.mySpect(:,tmpStart:tmpStop,1);
                            else
                                startColumn = 1;
                                stopColumn = 1;
                                handles.mySpect(:,startColumn:stopColumn,1) = handles.mySpect(:,tmpStart:tmpStop,1);
                            end
                            n = n - handles.updateTime4Plot * handles.Fs4Plot;
                            totNumPlots = totNumPlots + 1;
                            if (totNumPlots >= tmpRatio) 
                                startTimeIndex = startTimeIndex + handles.updateTime4Plot;
                                stopTimeIndex = stopTimeIndex + handles.updateTime4Plot;
                            elseif (totNumPlots < tmpRatio) & stopColumn*handles.updateTime4Plot == str2num(get(handles.SpectTimeLength,'String'))
                                startTimeIndex = startTimeIndex + stopColumn*handles.updateTime4Plot;
                                stopTimeIndex = stopTimeIndex + stopColumn*handles.updateTime4Plot;
                            end
                            for i = 1 : handles.NumChan4Plot
                                if ~handles.previousEndIndex(i)
                                    handles.lfp_start(i) = 1;
                                else
                                    handles.lfp_start(i) = handles.lfp_start(i) + handles.updateTime4Plot*handles.Fs4Plot(i);
                                end
                                handles.lfp_stop(i) = handles.lfp_start(i) - 1 + floor(tmpNoPlottedSamples(i)); 
                                handles.previousEndIndex(i) = handles.lfp_stop(i);
                            end
                        end
                        
                        timeIndex = stopColumn*handles.updateTime4Plot;
                        handles.timeaxis = linspace(startTimeIndex,stopTimeIndex,(tmpRatio+1)*length(T(:,1)));
                        dialogString = ['Updating is too fast!'];
                        set(handles.dialogBox,'String',dialogString);
                        set(handles.dialogBox,'ForegroundColor',[1 0 0]);
                        continue;
                    end
                    %-----------------------------------------------------%
                    
                    count = count + 1;
                    for i = 1 : handles.NumChan4Plot
                        if ~handles.previousEndIndex(i)
                            handles.lfp_start(i) = 1;
                        else
                            handles.lfp_start(i) = handles.lfp_start(i) + handles.updateTime4Plot*handles.Fs4Plot(i);
                        end
                        handles.lfp_stop(i) = handles.lfp_start(i) - 1 + floor(tmpNoPlottedSamples(i)); 
                        handles.previousEndIndex(i) = handles.lfp_stop(i);
                    end

                    for i = 1 : handles.NumChan4Plot
                        handles.userdata(1:Len(i),i) = handles.dd(handles.lfp_start(i):handles.lfp_stop(i),i); 
                        if get(handles.DCRemoval,'Value')
                            handles.userdata(1:Len(i),i) = handles.userdata(1:Len(i),i) - mean(handles.userdata(1:Len(i),i));
                        end
                    end

                    figure(handles.h);
                    temp_ADchan = ADchan;
                    currPoint = get(handles.h,'CurrentPoint');
                    pos = currPoint(1,1:2);
                    uipanel4Pos = get(handles.uipanel4,'Position');
                    for i = 1 : rows 
                        for j = 1 : columns
                            currPointIndex = (i-1)*columns + j;
                            plotPosition = get(handles.hhh(i,j),'Position');
                            plotPosition(1) = plotPosition(1) + uipanel4Pos(1);
                            plotPosition(2) = plotPosition(2) + uipanel4Pos(2);
                            tempADchanIndex = currPointIndex;
                            if (pos(1)>=plotPosition(1)) & (pos(1)<=plotPosition(1)+plotPosition(3)) & (pos(2)>=plotPosition(2)) & (pos(2)<=plotPosition(2)+plotPosition(4)) 
                                try
                                    if prevPos ~= pos
                                        if (tempADchanIndex~=find(handles.chans4Plot==temp_ADchan))
                                            ADchanIndex = currPointIndex;
                                            set(handles.SelectADchan,'Value',ADchanIndex);
                                            SelectADchan_Callback(handles.SelectADchan, [], handles)
                                            prevPos = pos;
                                        end
                                    end
                                catch
                                    if (tempADchanIndex~=find(handles.chans4Plot==temp_ADchan)) & firstFlag
                                        ADchanIndex = currPointIndex;
                                        set(handles.SelectADchan,'Value',ADchanIndex);
                                        SelectADchan_Callback(handles.SelectADchan, [], handles)
                                        prevPos = pos;
                                    else
                                        ADchanIndex = find(handles.chans4Plot==temp_ADchan);
                                        set(handles.SelectADchan,'Value',ADchanIndex);
                                        prevPos = pos;
                                    end
                                end
                            end
                        end
                    end
                    firstFlag = 1;
                    ADchan = GetADchan(handles);
                    ADchanIndex = find(handles.chans4Plot==ADchan);
                    handles.winWidth = RequiredTime;
                    handles.winN4Spect = floor(handles.winWidth * handles.Fs4Plot(ADchanIndex));  
                    handles.STFTstep = handles.winN4Spect;
                    handles.noverlap = 0;

                    if get(handles.win_shape, 'Value') == 1
                        handles.win4Spect = hann(handles.winN4Spect);          %defines a hannN-point Hanning window
                    elseif get(handles.win_shape, 'Value') == 2
                        handles.win4Spect = hamming(handles.winN4Spect);       %defines a hannN-point Hamming window
                    elseif get(handles.win_shape, 'Value') == 3
                        handles.win4Spect = blackman(handles.winN4Spect);      %defines a hannN-point Blackman window
                    elseif get(handles.win_shape, 'Value') == 4
                        handles.win4Spect = chebwin(handles.winN4Spect);       %defines a hannN-point Chebyshev window
                    elseif get(handles.win_shape, 'Value') == 5
                        handles.win4Spect = flattopwin(handles.winN4Spect);    %defines a hannN-point Flat-top window
                    elseif get(handles.win_shape, 'Value') == 6
                        handles.win4Spect = gausswin(handles.winN4Spect);      %defines a hannN-point Gaussian window
                    end

                    handles.winN4PSD = Len;
                    for i = 1 : handles.NumChan4Plot
                        if get(handles.win_shape, 'Value') == 1
                            handles.win4PSD(1:handles.winN4PSD(i),i) = hann(handles.winN4PSD(i));
                        elseif get(handles.win_shape, 'Value') == 2
                            handles.win4PSD(1:handles.winN4PSD(i),i) = hamming(handles.winN4PSD(i));
                        elseif get(handles.win_shape, 'Value') == 3
                            handles.win4PSD(1:handles.winN4PSD(i),i) = blackman(handles.winN4PSD(i));
                        elseif get(handles.win_shape, 'Value') == 4
                            handles.win4PSD(1:handles.winN4PSD(i),i) = chebwin(handles.winN4PSD(i));
                        elseif get(handles.win_shape, 'Value') == 5
                            handles.win4PSD(1:handles.winN4PSD(i),i) = flattopwin(handles.winN4PSD(i));
                        elseif get(handles.win_shape, 'Value') == 6
                            handles.win4PSD(1:handles.winN4PSD(i),i) = gausswin(handles.winN4PSD(i));
                        end
                    end

                    if ~isempty(ADchanIndex)
                        if get(handles.fouri_epon,'Value')==1
                            tmpL = length(handles.win4Spect);
                            [Spect,handles.FreqVect,T,handles.P] = spectrogram(handles.userdata(1:Len(ADchanIndex),ADchanIndex),handles.win4Spect,handles.noverlap,tmpL,handles.Fs4Plot(ADchanIndex));
                        else
                            handles.FourierN = 2^(get(handles.fouri_epon,'Value') + 3);
                            [Spect,handles.FreqVect,T,handles.P] = spectrogram(handles.userdata(1:Len(ADchanIndex),i),handles.win4Spect,handles.noverlap,handles.FourierN,handles.Fs4Plot(ADchanIndex));
                        end
                        T = T';
                        handles.P(:,:,1) = handles.P; 
                        f1 = str2num(get(handles.frequency_start, 'String'));
                        f2 = str2num(get(handles.frequency_end, 'String'));
                        freqIndex = find((handles.FreqVect>=f1) .* (handles.FreqVect<=f2));
                        handles.FreqVect = handles.FreqVect(freqIndex);
                        T(:,1) = T;
                        if (totNumPlots == 0)
                            siz = size(handles.FreqVect);
                            tmpRatio = fix( str2num(get(handles.SpectTimeLength,'String')) / str2num(get(handles.updateTime,'String')) );
                        end
                        
                        loopInd = rem(totNumPlots,tmpRatio);
                        
                        if (totNumPlots == 0) 
                            handles.mySpect = zeros(siz(1),tmpRatio*siz(2));
                        end
                        if (temp_ADchan ~= ADchan)
                            curEvents = [];
                            initTime = t;
                            siz = size(handles.FreqVect);
                            handles.mySpect = zeros(siz(1),tmpRatio*siz(2));
                            totNumPlots = 0;
                            startTimeIndex = 0;
                            stopTimeIndex = str2num(get(handles.SpectTimeLength,'String'));
                        end

                        if (totNumPlots < tmpRatio)
                            startColumn = rem(totNumPlots,tmpRatio) * length(T(:,1)) + 1;
                            stopColumn = startColumn -1 + length(T(:,1));
                            handles.mySpect(:,startColumn:stopColumn,1) = handles.P(freqIndex);
                        elseif tmpRatio>1
                            handles.mySpect(:,1:(end-1),1) = handles.mySpect(:,2:end,1) ;
                            startColumn = length(handles.mySpect(1,1:end,1));
                            stopColumn = startColumn -1 + length(T(:,1));
                            handles.mySpect(:,startColumn:stopColumn,1) = handles.P(freqIndex);
                        else
                            startColumn = 1;
                            stopColumn = 1;
                            handles.mySpect(:,startColumn:stopColumn,1) = handles.P(freqIndex);
                        end

                        if (stopColumn ~= length(handles.mySpect(1,:,1))) & (totNumPlots < tmpRatio)
                            psd4view = handles.mySpect(:,1:stopColumn,1);
                            tmpVal = min(max(psd4view))/100;
                            for i = (stopColumn+1) : length(handles.mySpect(1,:,1))
                                handles.mySpect(:,i,1) = tmpVal;
                            end
                        end

                        psd4view = handles.mySpect(:,:,1);
                        psdsize = size(psd4view);
                        if (stopColumn ~= length(handles.mySpect(1,:,1))) 
                            tmpVal = min(max(psd4view(:,1:stopColumn)))/100;
                            for i = 1 : stopColumn
                                ff = find(psd4view(:,i)<tmpVal);
                                psd4view(ff,i) = tmpVal;
                            end
                            psd4view(:,stopColumn+1:end) = tmpVal;
                        end
                        tmpVal = min(max(psd4view))/100;
                        for i = 1 : psdsize(2)
                            ff = find(psd4view(:,i)<tmpVal);
                            psd4view(ff,i) = tmpVal;
                        end
                        psd4view(:,end+1) = psd4view(:,end);
                        handles.timeaxis = linspace(startTimeIndex,stopTimeIndex,(tmpRatio+1)*length(T(:,1))); 
                    end
                    %--------------------PSD Calculation-----------------------
                    
                    if (totNumPlots == 0)
                        [mx mxInd] = max(Len);
                        if get(handles.fouri_epon,'Value')==1
                            tmpL = length(handles.userdata(1:Len(mxInd),mxInd));
                            FFTofWinData = fft(handles.userdata(1:Len(mxInd),mxInd).*handles.win4PSD(1:handles.winN4PSD(mxInd),mxInd),tmpL);
                            NumUniquePts(mxInd) = ceil((tmpL + 1)/2);
                        else
                            FFTofWinData = fft(handles.userdata(1:Len(mxInd),mxInd).*handles.win4PSD(1:handles.winN4PSD(mxInd),mxInd),handles.FourierN);
                            NumUniquePts(mxInd) = ceil((handles.FourierN + 1)/2);
                        end
                        FFTofWinData = FFTofWinData(1 : NumUniquePts(mxInd));
                        handles.P = (abs(FFTofWinData).^2) / ((handles.win4PSD(1:handles.winN4PSD(mxInd),mxInd))' * (handles.win4PSD(1:handles.winN4PSD(mxInd),mxInd)));
                        handles.P(:,1) = zeros(size(handles.P));
                        handles.P(:,handles.NumChan4Plot) = zeros(size(handles.P));
                        if (totNumPlots == 0)
                            handles.myPSD = zeros(size(handles.P(:,1:handles.NumChan4Plot)));
                        end
                    end

                    for i = 1 : handles.NumChan4Plot
                        
                        if i~=ADchanIndex

                            if get(handles.fouri_epon,'Value')==1
                                tmpL = Len(i);
                                FFTofWinData = fft(handles.userdata(1:Len(i),i).*handles.win4PSD(1:handles.winN4PSD(i),i),tmpL);
                                NumUniquePts(i) = ceil((tmpL + 1)/2);
                            else
                                FFTofWinData = fft(handles.userdata(1:Len(i),i).*handles.win4PSD(1:handles.winN4PSD(i),i),handles.FourierN);
                                NumUniquePts(i) = ceil((handles.FourierN + 1)/2);
                            end
                            FFTofWinData = FFTofWinData(1 : NumUniquePts(i));
                            handles.P(1:NumUniquePts(i),i) = (abs(FFTofWinData).^2) / ((handles.win4PSD(1:handles.winN4PSD(i),i))' * (handles.win4PSD(1:handles.winN4PSD(i),i))); 
                            if rem(tmpL,2),
                                handles.P(1:NumUniquePts(i),i) = [handles.P(1,i); 2*handles.P(2:NumUniquePts(i),i)];  
                            else
                                handles.P(1:NumUniquePts(i),i) = [handles.P(1,i); 2*handles.P(2:(NumUniquePts(i)-1),i); handles.P(NumUniquePts(i),i)]; 
                            end
                            handles.myPSD(1:NumUniquePts(i),i) = handles.P(1:NumUniquePts(i),i)./handles.Fs4Plot(i); 
                            
                        else
                            
                            NumUniquePts(i) = ceil((Len(i) + 1)/2);
                            handles.myPSD(freqIndex,i) = handles.mySpect(:,startColumn:stopColumn,1);
                        end
                        
                    end
                    
                   %%------------------PSD Plot---------------------
                   for i = 1 : rows
                        for j = 1 : columns
                            plotindex = (i-1)*columns + j;
                            psdVect = handles.myPSD(1:NumUniquePts(plotindex),plotindex);
                            if totNumPlots==0
                                if get(handles.logPSD,'Value')
                                    ylimitmax(i,j) = 10*log10(max(psdVect(psdVect>0)));
                                    ylimitmin(i,j) = 10*log10(min(psdVect(psdVect>0)));
                                else
                                    ylimitmax(i,j) = max(psdVect(psdVect>0));
                                    ylimitmin(i,j) = min(psdVect(psdVect>0));
                                end
                            elseif ~get(handles.AutoScale,'Value') & ~freezFlag
                                tmpLim = get(handles.hhh(i,j),'YLim');
                                ylimitmax(i,j) = tmpLim(2);
                                ylimitmin(i,j) = tmpLim(1);
                            end
                        end
                    end
                    
                    if get(handles.MaxScale,'Value') & ~freezFlag
                        if get(handles.logPSD,'Value')
                            ylimitmax(1:rows,1:columns) = 10*log10(max(max(handles.myPSD(handles.myPSD>0)))+eps);
                            ylimitmin(1:rows,1:columns) = 10*log10(min(min(handles.myPSD(handles.myPSD>0)))+eps);
                        else
                            ylimitmax(1:rows,1:columns) = max(max(handles.myPSD(handles.myPSD>0)));
                            ylimitmin(1:rows,1:columns) = min(min(handles.myPSD(handles.myPSD>0)));
                        end
                    end
                    for i = 1 : rows 
                        for j = 1 : columns
                            figure(handles.h);
                            axes(handles.hhh(i,j))
                            plotindex = (i-1)*columns + j;
                            x = linspace(0,handles.Fs4Plot(plotindex)/2,length(handles.myPSD(1:NumUniquePts(plotindex),plotindex)));
                            if get(handles.logPSD,'Value')
                                plot(handles.hhh(i,j),x,10*log10(handles.myPSD(1:NumUniquePts(plotindex),plotindex)+eps),'r','LineWidth',2)
                                if j == 1
                                    ylabel(handles.hhh(i,j),'PSD (dB)','Color',[0 0 0])
                                end
                            else
                                plot(handles.hhh(i,j),x,handles.myPSD(1:NumUniquePts(plotindex),plotindex),'r','LineWidth',2)
                                if j == 1
                                    ylabel(handles.hhh(i,j),'PSD','Color',[0 0 0])
                                end
                            end
                            maxFreq = min(handles.Fs4Plot(plotindex)/2,str2num(get(handles.frequency_end,'String')));
                            minFreq = str2num(get(handles.frequency_start,'String'));
                            if minFreq > handles.Fs4Plot(plotindex)/2
                                minFreq = 0;
                            end
                            set(handles.hhh(i,j),'XLim',[minFreq maxFreq])
                            if handles.chans4Plot(plotindex) == ADchan
                                set(handles.hhh(i,j),'XColor',[1 0 1])
                                set(handles.hhh(i,j),'YColor',[1 0 1])
                            else
                                set(handles.hhh(i,j),'XColor',[0 0 0])
                                set(handles.hhh(i,j),'YColor',[0 0 0])
                            end
                            if i == rows
                                xlabel(handles.hhh(i,j),'Frequency (Hz)','Color',[0 0 0])
                            end
                            title(handles.hhh(i,j),['Channel ' num2str(handles.chans4Plot(plotindex))],'Color',[0 0 0])
                            if get(handles.logPSD,'Value')
                                if j == 1
                                    ylabel(handles.hhh(i,j),'PSD (dB)','Color',[0 0 0])
                                end
                            else
                                if j == 1
                                    ylabel(handles.hhh(i,j),'PSD','Color',[0 0 0])
                                end
                            end
                            if ~(get(handles.AutoScale,'Value') & ~get(handles.MaxScale,'Value'))
                                ylim(handles.hhh(i,j),[ylimitmin(i,j) ylimitmax(i,j)])    
                            end
                            if get(handles.EEGmode,'Value')
                                psdYLim = get(handles.hhh(i,j),'YLim');
                                text(2,psdYLim(1),'\delta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize+5,'Color',[1 0 1]);
                                text(6,psdYLim(1),'\theta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize+5,'Color',[1 0 1]);
                                text(10,psdYLim(1),'\alpha','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize+5,'Color',[1 0 1]);
                                text(19,psdYLim(1),'\beta','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize+5,'Color',[1 0 1]);
                                text(63,psdYLim(1),'\gamma','VerticalAlignment','bottom','HorizontalAlignment','center','FontWeight','bold','FontSize',fontsize+5,'Color',[1 0 1]);
                                set(handles.hhh(i,j),'XTick',[0 4 8 12 26 100])
                                hold(handles.hhh(i,j),'on')
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
                                hold(handles.hhh(i,j),'off')
                            end
                            set(handles.hhh(i,j),'Position',hhhPosition(:,:,i,j))
                        end
                    end
                    if ~get(handles.AutoScale,'Value') 
                        freezFlag = 1;
                    else
                        freezFlag = 0;
                    end
                    %%--------------Spectrogram-------------------
                    axes(handles.Spectrogram_plot)
                    displayspectrogram(handles.timeaxis,handles.FreqVect,psd4view/min(min(psd4view)),0,[ str2num(get(handles.frequency_start, 'String')) str2num(get(handles.frequency_end, 'String')) min(handles.timeaxis) max(handles.timeaxis)],shadingType); 
                    axis([handles.FreqVect(1) handles.FreqVect(end) min(handles.timeaxis) max(handles.timeaxis)]); 
                    view(90,-90);
                    set(handles.Spectrogram_plot,'Position',handles.spectPosition) 
                    timeIndex = stopColumn*handles.updateTime4Plot;
                    if totNumPlots < tmpRatio
                        lineVect = timeIndex*ones(1,length(f1:f2));
                    else
                        lineVect = stopTimeIndex*ones(1,length(f1:f2));
                    end
                    hold(handles.Spectrogram_plot,'on')
                    plot(f1:f2,lineVect,'-r','LineWidth',3)
                    if event
                        curEvents = curEvents(find((curEvents >= startTimeIndex)));
                        events2plot = curEvents(find(curEvents < lineVect(1)));
                    end

                    if event
                        for j = 1 : length(events2plot)
                            if (events2plot(j)>=startTimeIndex) & (events2plot(j)<stopTimeIndex)
                                lineVect = events2plot(j)*ones(1,length(f1:f2));
                                plot(f1:f2,lineVect,'--r','LineWidth',1)
                            end
                        end
                    end
                    hold(handles.Spectrogram_plot,'off')
                    
                    tmpTime2 = toc;
                    if tmpTime2 > handles.updateTime4Plot/2
                        drawnow;
                    end

                    n = n - handles.updateTime4Plot * handles.Fs4Plot;
                    if get(handles.dialogBox,'ForegroundColor') == [1 0 0]
                        dialogString = ['Plotting Spectrogram for AD # ' num2str(ADchan)];
                        set(handles.dialogBox,'String',dialogString);
                        set(handles.dialogBox,'ForegroundColor',[0 0 0]);
                    end
                    totNumPlots = totNumPlots + 1;
                    if (totNumPlots >= tmpRatio) 
                        startTimeIndex = startTimeIndex + handles.updateTime4Plot;
                        stopTimeIndex = stopTimeIndex + handles.updateTime4Plot;
                    elseif (totNumPlots < tmpRatio) & timeIndex == str2num(get(handles.SpectTimeLength,'String'))
                        startTimeIndex = startTimeIndex + timeIndex;
                        stopTimeIndex = stopTimeIndex + timeIndex;
                    end
                    SetNumPlots(totNumPlots, handles)
                    guidata(hObject, handles);
                end
                
                if count
                    n = n - OverlapSamplesVect;
                end

            end
            
            set(handles.StopButton, 'Value', 0); 
            handles.RUNNING1 = [];
            guidata(hObject, handles);

    end

%-----------------------------------------------------
%Functions for ContinuousLFPClientFns

function SetNumPlots(n,handles)
    % Set the #Events text string
    set(handles.numPlots,'String',n)

function SetSamplingFreq(handles,ADchanIndex)
    set(handles.samplingFreq,'String',num2str(handles.Fs(ADchanIndex)))

function ResetSamplingFreq(handles)
    set(handles.samplingFreq,'String',num2str(0))

function y = GetADchan(handles)
    % get AD channel
    string = get(handles.SelectADchan,'String');
    value = get(handles.SelectADchan,'Value');
    string = cellstr(string);
    y = str2num(string{value});

%%%---------------------------------------------------------------%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
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

    
function FrequencyRes_Callback(hObject, eventdata, handles)
    if handles.Connect
        ADchan = GetADchan(handles);
        ADchanIndex = find(ADchan==handles.activeChans);
        val = str2num(get(handles.FrequencyRes,'String'));
        if isempty(val)
            updateTimeVal = str2num(get(handles.updateTime,'String'));
            if updateTimeVal < 1
                FreqRes = fix(10/updateTimeVal)/10;
            else
                FreqRes = 1/updateTimeVal;
            end
            set(handles.FrequencyRes,'String',FreqRes);
        elseif str2num(get(handles.FrequencyRes,'String'))>handles.Fs(ADchanIndex)/2
            set(handles.FrequencyRes, 'String' ,num2str(handles.Fs(ADchanIndex)/2));
        elseif round(val)~=val 
            FreqRes = fix(10*val)/10;
            if FreqRes>1
                set(handles.FrequencyRes,'String',FreqRes);
            else
                set(handles.FrequencyRes,'String',1);
            end
        end
        
    end
    guidata(hObject, handles);
    
    
function FrequencyRes_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(handles.FrequencyRes,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(handles.FrequencyRes,'BackgroundColor','white');
    end
    guidata(hObject, handles);
    
    
function updateTime_Callback(hObject, eventdata, handles)
    val = str2num(get(handles.updateTime,'String'));
    if isempty(val) | (val<=0)
        set(handles.updateTime,'String',0.5);
    end
    updateTimeVal = str2num(get(handles.updateTime,'String'));
    if updateTimeVal < 1
        FreqRes = fix(10/updateTimeVal)/10;
    else
        FreqRes = 1/updateTimeVal;
    end
    set(handles.SpectTimeLength,'String',num2str(100*updateTimeVal))
    set(handles.frequency_start,'String',num2str(FreqRes));
    set(handles.FrequencyRes,'String',num2str(FreqRes));
    guidata(hObject, handles);
    
    
function updateTime_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(handles.post,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(handles.post,'BackgroundColor','white');
    end
    guidata(hObject, handles);


function SpectTimeLength_Callback(hObject, eventdata, handles)
    val = str2num(get(handles.SpectTimeLength,'String'));
    updateTimeVal = str2num(get(handles.updateTime,'String'));
    if isempty(val) | (val<=0)
        set(handles.SpectTimeLength,'String',num2str(10*updateTimeVal));
    end
    SpectTimeLengthVal = str2num(get(handles.SpectTimeLength,'String'));
    if rem(SpectTimeLengthVal,updateTimeVal)~=0
        tmpVal = SpectTimeLengthVal - rem(SpectTimeLengthVal,updateTimeVal);
        set(handles.SpectTimeLength,'String',num2str(tmpVal));
    end
    guidata(hObject, handles);
    

function SelectADchan_Callback(hObject, eventdata, handles)
    if handles.Connect
        selectedchan = get(handles.SelectADchan,'Value');
        tmpStr4chan = get(handles.SelectADchan,'String');
        ADchan = str2num(char(tmpStr4chan(selectedchan,:)));
        if ~isempty(ADchan)
            ADchanIndex = find(handles.activeChans==ADchan);
            handles.Fs4Plot = handles.Fs(handles.chansIndex4Plot);
            if strcmp(get(handles.StopButton,'Enable'),'off')
                set(handles.frequency_end,'String',min(fix(handles.Fs(ADchanIndex)/2),str2num(get(handles.frequency_end,'String'))));
                set(handles.frequency_start,'String',0)
            elseif str2num(get(handles.frequency_end,'String')) > handles.Fs(ADchanIndex)/2
                set(handles.frequency_end,'String',num2str(fix(handles.Fs(ADchanIndex)/2)));
                set(handles.frequency_start,'String',0)
            end
            SetSamplingFreq(handles,ADchanIndex); 
        end
    end

    if handles.Connect 
        ADchan = GetADchan(handles);
        dialogString = ['Plotting Spectrogram for AD # ' num2str(ADchan)];
        set(handles.dialogBox,'String',dialogString);
        set(handles.dialogBox,'ForegroundColor',[0 0 0]);
    end
    guidata(hObject, handles);

    
function SelectADchan_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);
    
    
function SelectEventchan_Callback(hObject, eventdata, handles)


function ListBox1_Callback(hObject, eventdata, handles)
    if handles.Connect
        listBox1chan = get(handles.listbox1,'Value');
        tmpStr4chan = get(handles.listbox1,'String');
        ADchan = str2num(char(tmpStr4chan(listBox1chan,:)));
        if ~isempty(ADchan) & strcmp(get(handles.StopButton,'Enable'),'off')
            ADchanIndex = find(handles.activeChans==ADchan);
            SetSamplingFreq(handles,ADchanIndex); 
        end
    end
        
    guidata(hObject, handles);
    

function ListBox1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);
   
    
function ListBox2_Callback(hObject, eventdata, handles)
    if handles.Connect
        listBox2chan = get(handles.listbox2,'Value');
        tmpStr4chan = get(handles.listbox2,'String');
        ADchan = str2num(char(tmpStr4chan(listBox2chan,:)));
        if ~isempty(ADchan) & strcmp(get(handles.StopButton,'Enable'),'off')
            ADchanIndex = find(handles.activeChans==ADchan);
            SetSamplingFreq(handles,ADchanIndex); 
        end
    end
        
    guidata(hObject, handles);
    

function ListBox2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);


function AddAllChanButton_Callback(hObject, eventdata, handles)
    if handles.Connect
        set(handles.listbox1,'Value',1);
        tmpStr4listbox1 = get(handles.listbox1,'String');
        newTmpStr4listbox1 = tmpStr4listbox1;
        while ~isempty(newTmpStr4listbox1)
            listBox1chan = get(handles.listbox1,'Value');
            listBox2chan = get(handles.listbox2,'Value');
            tmpStr4listbox2 = get(handles.listbox2,'String');
            newTmpStr4listbox2 = cell(length(tmpStr4listbox2)+1,1);
            newTmpStr4listbox2(1 : length(tmpStr4listbox2)) = tmpStr4listbox2;
            newTmpStr4listbox2(length(tmpStr4listbox2)+1) = {char(newTmpStr4listbox1(listBox1chan,:))};
            set(handles.listbox2,'Value',1)
            set(handles.listbox2,'String',newTmpStr4listbox2)
            set(handles.listbox2,'Value',length(newTmpStr4listbox2))
            set(handles.SelectADchan,'Value',1)
            set(handles.SelectADchan,'String',newTmpStr4listbox2)
            tmpChanIndex = find(handles.activeChans == str2num(char(newTmpStr4listbox1(listBox1chan,:))));
            handles.chansIndex4Plot = [handles.chansIndex4Plot;tmpChanIndex];
            newTmpStr4listbox1 = cellstr(newTmpStr4listbox1);
            newTmpStr4listbox1(listBox1chan) = [];
            set(handles.listbox1,'Value',1)
            set(handles.listbox1,'String',newTmpStr4listbox1)
        end
    else
        errordlg('Please Connect to the Plexon Server','Incorrect Selection','modal');
    end
    guidata(hObject, handles);


function AddChanButton_Callback(hObject, eventdata, handles)
    if handles.Connect
        listBox1chan = get(handles.listbox1,'Value');
        tmpStr4listbox1 = get(handles.listbox1,'String');
        if ~isempty(tmpStr4listbox1)
            listBox2chan = get(handles.listbox2,'Value');
            tmpStr4listbox2 = get(handles.listbox2,'String');
            newTmpStr4listbox2 = cell(length(tmpStr4listbox2)+1,1);
            newTmpStr4listbox2(1 : length(tmpStr4listbox2)) = tmpStr4listbox2;
            newTmpStr4listbox2(length(tmpStr4listbox2)+1) = {char(tmpStr4listbox1(listBox1chan,:))};
            set(handles.listbox2,'Value',1)
            set(handles.listbox2,'String',newTmpStr4listbox2)
            set(handles.listbox2,'Value',length(newTmpStr4listbox2))
            set(handles.SelectADchan,'Value',1)
            set(handles.SelectADchan,'String',newTmpStr4listbox2)
            newTmpStr4listbox1 = cellstr(tmpStr4listbox1);
            newTmpStr4listbox1(listBox1chan) = [];
            set(handles.listbox1,'Value',max(listBox1chan-1,1))
            set(handles.listbox1,'String',newTmpStr4listbox1)
            tmpChanIndex = find(handles.activeChans == str2num(char(tmpStr4listbox1(listBox1chan,:))));
            handles.chansIndex4Plot = [handles.chansIndex4Plot;tmpChanIndex];
        end
    else
        errordlg('Please Connect to the Plexon Server','Incorrect Selection','modal');
    end
    guidata(hObject, handles);


function RemoveChanButton_Callback(hObject, eventdata, handles)
    if handles.Connect
        listBox2chan = get(handles.listbox2,'Value');
        tmpStr4listbox2 = get(handles.listbox2,'String');
        if ~isempty(tmpStr4listbox2)
            listBox1chan = get(handles.listbox1,'Value');
            tmpStr4listbox1 = get(handles.listbox1,'String');
            newTmpStr4listbox1 = cell(length(tmpStr4listbox1)+1,1);
            newTmpStr4listbox1(1 : length(tmpStr4listbox1)) = tmpStr4listbox1;
            newTmpStr4listbox1(length(tmpStr4listbox1)+1) = {char(tmpStr4listbox2(listBox2chan,:))};
            set(handles.listbox1,'Value',1)
            set(handles.listbox1,'String',newTmpStr4listbox1)
            set(handles.listbox1,'Value',length(newTmpStr4listbox1))
            newTmpStr4listbox2 = cellstr(tmpStr4listbox2);
            newTmpStr4listbox2(listBox2chan) = [];
            set(handles.listbox2,'Value',max(listBox2chan-1,1))
            set(handles.listbox2,'String',newTmpStr4listbox2)
            set(handles.SelectADchan,'Value',1)
            if isempty(newTmpStr4listbox2)
                set(handles.SelectADchan,'String','None')
            else
                set(handles.SelectADchan,'String',newTmpStr4listbox2)
            end
            tmpChanIndex = find(handles.chansIndex4Plot ~= find(handles.activeChans == str2num(char(tmpStr4listbox2(listBox2chan,:)))));
            handles.chansIndex4Plot = handles.chansIndex4Plot(tmpChanIndex);
        end
    else
        errordlg('Please Connect to the Plexon Server','Incorrect Selection','modal');
    end
    guidata(hObject, handles);
    

function RemoveAllChanButton_Callback(hObject, eventdata, handles)
    if handles.Connect
        set(handles.listbox2,'Value',1);
        tmpStr4listbox2 = get(handles.listbox2,'String');
        newTmpStr4listbox2 = tmpStr4listbox2;
        while ~isempty(newTmpStr4listbox2)
            listBox2chan = get(handles.listbox2,'Value');
            listBox1chan = get(handles.listbox1,'Value');
            tmpStr4listbox1 = get(handles.listbox1,'String');
            newTmpStr4listbox1 = cell(length(tmpStr4listbox1)+1,1);
            newTmpStr4listbox1(1 : length(tmpStr4listbox1)) = tmpStr4listbox1;
            newTmpStr4listbox1(length(tmpStr4listbox1)+1) = {char(newTmpStr4listbox2(listBox2chan,:))};
            set(handles.listbox1,'Value',1)
            set(handles.listbox1,'String',newTmpStr4listbox1)
            set(handles.listbox1,'Value',length(newTmpStr4listbox1))
            newTmpStr4listbox2 = cellstr(newTmpStr4listbox2);
            newTmpStr4listbox2(listBox2chan) = [];
            set(handles.listbox2,'Value',1)
            set(handles.listbox2,'String',newTmpStr4listbox2)
        end
        set(handles.SelectADchan,'Value',1)
        set(handles.SelectADchan,'String','None')
        handles.chansIndex4Plot = [];
    else
        errordlg('Please Connect to the Plexon Server','Incorrect Selection','modal');
    end
    guidata(hObject, handles);


function AutoScale_Callback(hObject, eventdata, handles)
    if get(handles.AutoScale,'Value')
        set(handles.MaxScale,'Enable','on')
        set(handles.logPSD,'Enable','on')
    else
        set(handles.MaxScale,'Enable','off')
        set(handles.logPSD,'Enable','off')
    end
    guidata(hObject, handles);
    
    
function ExpertMode_Callback(hObject, eventdata, handles)
    if get(handles.ExpertMode,'Value')
        set(handles.text15,'Enable','on')
        set(handles.win_shape,'Enable','on')
        set(handles.notchtext,'Enable','on')
        set(handles.NotchFilter,'Enable','on')
        set(handles.text25,'Enable','on')
        set(handles.FrequencyRes,'Enable','on')
        set(handles.text12,'Enable','on')
        set(handles.frequency_end,'Enable','on')
        set(handles.text21,'Enable','on')
        set(handles.frequency_start,'Enable','on')
        set(handles.text30,'Enable','on')
        set(handles.SpectTimeLength,'Enable','on')        
        set(handles.text38,'Enable','on')
        set(handles.SpectShading,'Enable','on')        
        set(handles.DCRemoval,'Enable','on')
        set(handles.text29,'Enable','on')
        set(handles.EEGmode,'Enable','on')
        set(handles.EEGtext,'Enable','on')
    else
        set(handles.text15,'Enable','off')
        set(handles.win_shape,'Enable','off')
        set(handles.notchtext,'Enable','off')
        set(handles.NotchFilter,'Enable','off')
        set(handles.text25,'Enable','off')
        set(handles.FrequencyRes,'Enable','off')
        set(handles.text12,'Enable','off')
        set(handles.frequency_end,'Enable','off')
        set(handles.text21,'Enable','off')
        set(handles.frequency_start,'Enable','off')
        set(handles.text30,'Enable','off')
        set(handles.SpectTimeLength,'Enable','off')
        set(handles.text38,'Enable','off')
        set(handles.SpectShading,'Enable','off')        
        set(handles.DCRemoval,'Enable','off')
        set(handles.text29,'Enable','off')
        set(handles.EEGmode,'Enable','off')
        set(handles.EEGtext,'Enable','off')
    end
    guidata(hObject, handles);
    

function ConnectBtn_Callback(hObject, eventdata, handles)
    if ~(handles.Connect)
        set(handles.SelectADchan,'Value',1)
    end
    handles.FourierN = 2^(get(handles.fouri_epon,'Value') + 3);
    handles.h = gcf;
    handles.Connect = 1;
    handles.action = 'connect';
    guidata(hObject, handles);
    ContinuousLFPClientFns(handles, hObject)
    handles = guidata(handles.ConnectBtn);
    guidata(hObject, handles);
    
    
function ConnectBtn_CreateFcn(hObject, eventdata, handles)
    handles.Connect = 0;
    guidata(hObject, handles);


function StartButton_Callback(hObject, eventdata, handles)
    if strcmp(get(handles.SelectADchan,'String'),'None')
        errordlg('Please Add Channel to Start','Incorrect Selection','modal');
        return;
    end
    set(handles.SelectADchan,'Enable','on')
    set(handles.SelectEventchan,'Enable','off')
    stopped = 0;
    set(handles.StartButton,'Enable','off')
    if (length(get(handles.StopButton,'Enable')) == 3) 
        set(handles.StopButton,'Enable','on')
    end
    set(handles.AddChanButton,'Enable','off')
    set(handles.AddAllChanButton,'Enable','off')
    set(handles.RemoveChanButton,'Enable','off')
    set(handles.RemoveAllChanButton,'Enable','off')
    set(handles.listbox1,'Enable','off')
    set(handles.listbox2,'Enable','off')
    set(handles.updateTime,'Enable','off')
    set(handles.FrequencyRes,'Enable','off')
    set(handles.ExpertMode,'Enable','off')
    set(handles.frequency_end,'Enable','off')
    set(handles.frequency_start,'Enable','off')
    set(handles.fouri_epon,'Enable','off')
    set(handles.win_shape,'Enable','off')
    set(handles.NotchFilter,'Enable','off')
    set(handles.DCRemoval,'Enable','off')
    set(handles.SpectTimeLength,'Enable','off')
    set(handles.SpectShading,'Enable','off')

    handles.action = 'plot';
    guidata(hObject, handles);
    ContinuousLFPClientFns(handles, hObject)

    
function StartButton_CreateFcn(hObject, eventdata, handles) 
    if (length(get(handles.StartButton,'Enable')) == 2) 
        set(handles.StartButton,'Enable','off')
    end
    guidata(hObject, handles);

    
function DisConBtn_Callback(hObject, eventdata, handles)
    handles.Connect = 0;
    set(handles.StartButton,'Enable','on')

    if (length(get(handles.StartButton,'Enable')) == 2) 
        set(handles.StartButton,'Enable','off')
    end
    if (length(get(handles.StopButton,'Enable')) == 2) 
        set(handles.StopButton,'Enable','off')
    end
    set(handles.AddChanButton,'Enable','on')
    set(handles.AddAllChanButton,'Enable','on')
    set(handles.RemoveChanButton,'Enable','on')
    set(handles.RemoveAllChanButton,'Enable','on')
    set(handles.listbox1,'Enable','on')
    set(handles.listbox2,'Enable','on')

    set(handles.SelectADchan,'Enable','on')
    set(handles.SelectEventchan,'Enable','on')
    set(handles.updateTime,'Enable','on')
    if get(handles.ExpertMode,'Value')
        set(handles.win_shape,'Enable','on')
        set(handles.NotchFilter,'Enable','on')
        set(handles.frequency_end,'Enable','on')
        set(handles.frequency_start,'Enable','on')
        set(handles.FrequencyRes,'Enable','on')
        set(handles.DCRemoval,'Enable','on')
        set(handles.SpectTimeLength,'Enable','on')
        set(handles.SpectShading,'Enable','on')
    end
    
    set(handles.ExpertMode,'Enable','on')

    set(handles.fouri_epon,'Enable','on')

    handles.action = 'disconnect';
    guidata(hObject, handles);
    ContinuousLFPClientFns(handles, hObject)


function StopButton_Callback(hObject, eventdata, handles)
    stopped = 1;
    set(handles.StartButton,'Enable','on')
    set(handles.AddChanButton,'Enable','on')
    set(handles.AddAllChanButton,'Enable','on')
    set(handles.RemoveChanButton,'Enable','on')
    set(handles.RemoveAllChanButton,'Enable','on')
    set(handles.listbox1,'Enable','on')
    set(handles.listbox2,'Enable','on')

    set(handles.SelectADchan,'Enable','on')
    set(handles.SelectEventchan,'Enable','on')
    set(handles.updateTime,'Enable','on')
    if get(handles.ExpertMode,'Value')
        set(handles.frequency_end,'Enable','on')
        set(handles.frequency_start,'Enable','on')
        set(handles.fouri_epon,'Enable','on')
        set(handles.win_shape,'Enable','on')
        set(handles.NotchFilter,'Enable','on')
        set(handles.DCRemoval,'Enable','on')
        set(handles.SpectTimeLength,'Enable','on')
        set(handles.SpectShading,'Enable','on')
    end
    set(handles.SelectADchan,'BackgroundColor','white')
    set(handles.StopButton,'Enable','off')
    if get(handles.ExpertMode,'Value') 
        set(handles.FrequencyRes,'Enable','on')
    end
    set(handles.ExpertMode,'Enable','on')
    
    handles.action = 'stop';
    guidata(hObject, handles);
    ContinuousLFPClientFns(handles, hObject)

    
function StopButton_CreateFcn(hObject, eventdata, handles) 
    if (length(get(handles.StopButton,'Enable')) == 2) 
        set(handles.StopButton,'Enable','off')
    end
    guidata(hObject, handles);
    
    
function win_shape_Callback(hObject, eventdata, handles)


function win_shape_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);
    
    
function SpectShading_Callback(hObject, eventdata, handles)


function fouri_epon_Callback(hObject, eventdata, handles)
    handles.FourierN = 2^(get(handles.fouri_epon,'Value') + 3); 
    guidata(hObject,handles);

    
function fouri_epon_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject, handles);
    
    
function frequency_end_Callback(hObject, eventdata, handles)
    if handles.Connect
        ADchan = GetADchan(handles);
        ADchanIndex = find(ADchan==handles.activeChans);
        if ~isempty(ADchan)
            if str2num(get(hObject,'String'))>handles.Fs(ADchanIndex)/2 | str2num(get(hObject,'String'))<=0
                set(hObject, 'String' ,num2str(handles.Fs(ADchanIndex)/2));
            end
        else
            if str2num(get(hObject,'String'))>handles.Fs(1)/2 | str2num(get(hObject,'String'))<=0
                set(hObject, 'String' ,num2str(handles.Fs(1)/2));
            end
        end
        val = str2num(get(handles.frequency_end,'String'));
        if isempty(val)
            if ~isempty(ADchan)
                set(handles.frequency_end,'String',num2str(handles.Fs(ADchanIndex)/2));
            else
                set(handles.frequency_end,'String',num2str(handles.Fs(1)/2));
            end
        end
        frequency_start_Callback(handles.frequency_start, eventdata, handles);
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
    if get(handles.EEGmode,'Value') 
        if strcmp(get(handles.frequency_start,'Enable'),'on') & strcmp(get(handles.frequency_end,'Enable'),'on')
            set(handles.frequency_start,'String',0)
            set(handles.frequency_end,'String',100)
        end
    end
    guidata(hObject, handles);
    
    
