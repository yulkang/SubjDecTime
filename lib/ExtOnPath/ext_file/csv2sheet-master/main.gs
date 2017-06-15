/**
* main
* 
* The function to start it all.
*/
function main() {
	
	/* START PROFILER */
	// Write key execution times to log. Note: Google Apps Script 
	// provides detail under View > Execution transcript. File 
	// manipulation (creating, opening, moving) dominates
	// execution time.
	var profile = new Profile();
	
	
	/* CONFIGURE */
	var config = {

		// True => process csvs in test/ rather than runs/ 
		testMode   : true, 
		
		// Default policies for merging columns. Conflict occurs when 
		// column is (1) only in spreadsheet, (2) only in csv, or (3) in
		// both at different positions. 
		//
		// Conservative option attempts to preserve columns and order,
		// moving things only in case 3. Note: csv metadata could support 
		// more operations (such as rename column) or granularity (delete 
		// specific column in spreadsheet).
		mergeRules : {
			onlyInSheet   : 'preserve', // preserve | moveAfter | delete 
			onlyInCsv     : 'preserve', // preserve | moveAfter | delete
			differentPos  : 'csvWins'   // csvWins  | sheetWins
		},
	};
	
	// Initialize global app object
	CSVAPP = new CsvApp(config);

	// Log execution time
	profile.log('App initialized');  
	
	
	/* QUEUE CSVs */
	// Load csvs as 2d arrays and pair with metadata files
	var csvQueue = new CsvQueue();

	// Log execution time
	profile.log('Csv queue created'); 
	
	/* MERGE WITH SHEETS */
	while (!csvQueue.isEmpty()) {

		// Dequeue csv
		csv = csvQueue.dequeue();

		// Open or create spreadsheet and sheet specified in metadata
		var spreadsheet = CSVAPP.getSpreadsheetByName(csv.spreadsheet) ||
		                  CSVAPP.createSpreadsheet(csv.spreadsheet);
		sheet =           spreadsheet.getSheetByName(csv.sheet) || 
		                  spreadsheet.createSheet(csv.sheet);
		
		// Merge
		sheet.merge(csv);
		
		// Log execution time per csv		
		profile.log(csv.name + ' merged'); 
	};	
	
	
	/* SAVE LOG */
	publishLog();
}
