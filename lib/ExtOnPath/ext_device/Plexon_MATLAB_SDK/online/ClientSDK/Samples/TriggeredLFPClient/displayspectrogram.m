function displayspectrogram(t,f,Pxx,isFsnormalized,faxisloc,shadingType)

% Cell array of the standard frequency units strings
frequnitstrs = getfrequnitstrs;
if isFsnormalized, 
    idx = 1;
else
    idx = 2;
end

newplot;
if strcmpi(faxisloc,'yaxis'),
    if length(t)==1
        % surf requires a matrix for the third input.
        args = {[0 t],f,10*log10(abs([Pxx Pxx])+eps)};
    else
        args = {t,f,10*log10(abs(Pxx)+eps)};
    end

    % Axis labels
    xlbl = 'Time (sec)';
    ylbl = frequnitstrs{idx};
else
    if length(t)==1
        args = {f,[0 t],10*log10(abs([Pxx' Pxx'])+eps)};
    else
        args = {f,t,10*log10(abs(Pxx')+eps)};
    end
    xlbl = frequnitstrs{idx};
    ylbl = 'Time (sec)';
end
hndl = surf(args{:},'EdgeColor','none');

axis xy; axis tight;
colormap(jet);

% AZ = 0, EL = 90 is directly overhead and the default 2-D view.
%view(0,90);
view(90,-90);
if strcmp(shadingType,'Flat')
    shading flat
elseif strcmp(shadingType,'Faceted')
    shading faceted
elseif strcmp(shadingType,'Interpolated')
    shading interp
end

ylabel(ylbl);
xlabel(xlbl);
