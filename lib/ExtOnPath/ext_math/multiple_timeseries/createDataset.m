function d = createDataset(datasetname, value, startperiod, anzahl_werte )
series      = org.jfree.data.time.TimeSeries(java.lang.String(datasetname));  % create TimeSeries
for i =0:1:anzahl_werte
    series.add(startperiod, value);
    startperiod = startperiod.next();
    value = value * (1 + (rand(1) - 0.495) / 10.0);
end;

dataset_timeseries = org.jfree.data.time.TimeSeriesCollection(series);        % dataset generation
dataset_timeseries.removeAllSeries
dataset_timeseries.addSeries(series);
d = dataset_timeseries;

