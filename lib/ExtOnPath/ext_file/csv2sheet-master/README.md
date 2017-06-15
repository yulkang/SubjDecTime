# csv2sheet
Google Apps Scripts (aka JavaScript) to create and update Google spreadsheets with CSV files.

# Installation
The scripts expect the following folder structure:
```
csv2sheet
|   csv2sheet (Google Apps Script Project)
|—— deploy
|    |—— csvs_new
|    |—— csvs_notValid
|    |—— csvs_processed
|    |—— logs
|    '—— spreadsheets
'—— test
     |—— csvs_new
     |—— csvs_notValid
     |—— csvs_processed
     |—— logs
     '—— spreadsheets
```

# Usage
The CSV generator (i.e., MATLAB) should output files to `csv2sheet/runs/csvs_new/`. Each new record or record set consists of two files: 

#### CSV file
Each CSV must have:
* One header row
* One or more data rows
* Column specified as primary key in metadata below
* Mime type `text/csv` (e.g., `filename.csv`).

#### Metadata file
Loosely following [W3C recommendations for CSV data and metadata](http://www.w3.org/TR/tabular-data-model/#standard-file-metadata), each CSV must be associated with a JSON file of the same name, plus the extension `-metadata.json`, e.g.,
`filename.csv-metadata.json`.

Metadata must specify:
* `time` value used to determine order in which CSVs are converted
* `spreadsheet` name. If no spreadsheet by this name exists in `spreadsheets/` folder, it will be created.
* `sheet` name. If no sheet by this name exists in spreadsheet, it will be created.
* `primaryKey`. Column name in CSV used to identify and prevent duplicate records. 

Example:
```
{
  "time": "20150123T130634",
  "spreadsheet": "Saccade Experiments",
  "sheet" : "Memory Guided",
  "primaryKey" : "Run ID"
}
```

Metadata could be extended to specify column-level merge policies, formatting, etc.

#### Scripts
Run the scripts from `main.gs` or by setting up a Google Apps trigger, such as a [time-driven trigger](https://developers.google.com/apps-script/guides/triggers/installable#time-driven_triggers) (unfortunately there's no simple way to monitor a folder for new CSV files). Make sure `testMode` is set to `false` in `main.gs`.

The scripts do the following:
* Process files found in `csvs_new/` 
* Merge new data into sheets in `spreadsheets/`
* Move processed CSVs to `csvs_processed` (or `csvs_notValid`)
* Save activity log to `logs/` 

# Merge options
The scripts are intended for a workflow where additional spreadsheet data and formatting are maintained manually, so the merge tampers minimally with the spreadsheet. The default options (easily changed in `main.gs`) attempt to preserve columns and their order in both CSV and sheet, though they do give precedence to the CSV in the case where the same columns are in different positions.

# Tests
The `test/` directory includes CSVs and metadata that demonstrate the basic functionality of csv2sheet and support further customization. When `testMode` is set to `true` in `main.gs`, running the script will generate new spreadsheets in `test/spreadsheets/` (after first removing previously generated test sheets and restoring CSV files moved to `csvs_processed/` or `csvs_notValid/`).

# Limitations
The activity log includes useful messaging. Some reasonable error handling is in place. But the script is still quite breakable, due primarily to unexpected input. The good news: the script is unlikely to overwrite valuable spreadsheet data—instead, it will simply error out.

Also, Google file operations can take a long (and variable) amount of time. It's not unusual for the testMode to run for 60 seconds, with over 50 seconds dedicated to moving files around. 
