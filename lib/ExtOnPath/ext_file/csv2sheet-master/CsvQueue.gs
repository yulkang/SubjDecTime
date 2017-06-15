/**
* CsvQueue
* 
* Build queue of new csvs/metadata and remove invalid files
*/

function CsvQueue() {
	
	// Initialize csv array 
	this.queue = [];

	// Get files in csvs_new folder keyed by filename
	var files = CSVAPP.folders.csvs_new.getFiles();
	
	// Remove invalid files and parse valid ones
	for (var name in files) {
		
		// Test for csv file by MimeType
		if (files[name].getMimeType() == 'text/csv') { 
			
			// Valid: csv with metadata			
			if (files[name + '-metadata.json']) {
				
				// Fetch parsed csv
				var csv = new Csv(files[name]);
				
				// Extend with parsed metadata
				csv.getMetadata(files[name + '-metadata.json']);
				
				// Enqueue
				this.queue.push(csv);
			}
			
			// Not valid: Csv without metadata
			else {	
				
				// Log
				Logger.log('WARNING: Csv file \'%s\' has no associated metadata file', name);
				
				// Move to csvs_notValid folder
				CSVAPP.folders.csvs_new.moveFile(files[name], CSVAPP.folders.csvs_notValid);				
			}
		} 
		
		// Not valid: Metadata without csv
		else if ( (/.csv-metadata.json$/.test(name)) && (!files[name.replace(/-metadata.json/,'')]) ) {
			
			// Log
			Logger.log('WARNING: Metadata file \'%s\' has no associated csv file', name);
			
			// Move to csvs_notValid folder
			CSVAPP.folders.csvs_new.moveFile(files[name], CSVAPP.folders.csvs_notValid);				
		}
		
		// Not valid: Unrecognized file type
		else if (!/.csv-metadata.json$/.test(name))  {
			
			// Log
			Logger.log('WARNING: File \'%s\' not recognized as csv or metadata', name);
			
			// Move to csvs_notValid folder
			CSVAPP.folders.csvs_new.moveFile(files[name], CSVAPP.folders.csvs_notValid);				
		}
	};

	// Sort earliest first for orderly merge. Times set in metadata file.
	this.queue = this.queue.sortByProp('time');
};

CsvQueue.prototype = {
	
	/**
	 * isEmpty
	 * 
	 * @returns {Boolean}
	 */
	isEmpty : function() {
		return (!this.queue.length)
	},
	
	/**
	 * dequeue
	 * 
	 * @returns {Object} - Csv
	 */
	dequeue : function() {
		return this.queue.shift();
	}
};
