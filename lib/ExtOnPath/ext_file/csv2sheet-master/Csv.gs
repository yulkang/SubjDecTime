/**
 * Csv
 * 
 * Parses csv and provides methods for merge. Parallel methods
 * exist for Sheet. Note: Accommodates multiple data rows in 
 * case reports are somehow batched.
 * 
 * @param {Object} - DriveFile - csv file as Google File object
 * 
 */
function Csv(DriveFile) {

	this.file = DriveFile;
	this.name = this.file.getName();
		
	// Use Google Apps Script Utilities.parseCsv to convert to 2D array
	this.data = Utilities.parseCsv(this.file.getBlob().getDataAsString());	  

	// Remove first row and return as header
	this.headers = this.data.shift();
};

Csv.prototype = {
		
	/**
	 * deleteCol
	 * 
	 * Delete column in csv header and data
	 * 
	 * @param {integer} pos - column position (numbered from 1)
	 */ 
	deleteCol : function(pos) {
		
		// Headers
		this.headers.splice(pos - 1, 1);
		
		// Loop through data rows		
		this.data.forEach(function(row) { 
			row.splice(pos - 1, 1);	
		});		
	},
	
	/**
	 * getMetadata
	 * 
	 * @param {Object} DriveFile - metadata file as Google File object
	 */
	getMetadata : function(DriveFile) {
		
		this.metadataFile = DriveFile;
		
		// Parse metadata json and incorporate into Csv object
		this.extend(JSON.parse(this.metadataFile.getBlob().getDataAsString()));	
	},
  
 	/**
	 * getPrimaryKeyVals
	 * 
	 * Gets values in csv for primary key defined in metadata.
	 * Used to prevent duplicate records.
	 */
	getPrimaryKeyVals: function() {
		
		// Get index of primary key column
		var i = this.headers.indexOf(this.primaryKey),
			vals = [];
		
		// Loop through data rows		
		this.data.forEach(function(row) { 
			vals.push(row[i]);	
		});
      
		this.primaryKeyVals = vals;
	}, 
		
	/**
	 * insertCol
	 * 
	 * Insert named column in headers and data
	 * 
	 * @param {String} name - column name
	 * @param {Integer} pos - column position (numbered from 1)
	 */	
	insertCol : function(pos, name) {
		
		// Headers
		this.headers.splice(pos - 1, 0, name);
		
		// Loop through data rows		
		this.data.forEach(function(row){ 
			row.splice(pos - 1, 0, '');	
		});
	},
  
  	/**
	 * removeDuplicates
	 * 
	 * Test for duplicate records (rather messily)
	 *  
	 * @param {Array} sheetVals - 2D array of primaryKey
	 * values (eg, timestamp) from sheet [[time1],[time2] ...]
	 */
	removeDuplicates : function(sheetVals) {
		
		// Get primary keys in csv
		this.getPrimaryKeyVals();
		
		// Loop through keys in csv. Note: Loop counter reversed 
		// so duplicate records can be removed without shifting 
		// position of untested records
		for(var i = this.primaryKeyVals.length - 1; i > -1; i--) { 
			
			// Loop through sheet keys. Note: Google returns column
			// as nested array and flattening it seems less performant.
			for(var j = 0; j < sheetVals.length; j++) {
        		
				// Check if record exists in sheet
				if(this.primaryKeyVals[i] == sheetVals[j][0]) {
        			
					// Delete duplicate row
					this.data.splice(i, 1);
        			
					// Log
					Logger.log('WARNING: Row %s of csv \'%s\' removed because sheet row %s has same %s: \'%s\'', 
        					i + 2, csv.name, j + 2, csv.primaryKey, sheetVals[j][0]);
        			
					break;
        		}
        	}
        }
        
        // 0 for emptied csv
        return this.data.length;
    },
    
	/**
	 * setProcessed
	 * 
	 *  Move processed csvs to csvs_processed folder
	 */
	setProcessed : function() {
		CSVAPP.folders.csvs_new.moveFile(this.file, CSVAPP.folders.csvs_processed);
		CSVAPP.folders.csvs_new.moveFile(this.metadataFile, CSVAPP.folders.csvs_processed);
	},
	
	/**
	 * moveCol
	 * 
	 * Move column in headers and data
	 * 
	 * @param {Integer} fromPos - current column position
	 * @param {Integer} toPos - desired column position
	 */	
	moveCol : function(fromPos, toPos) {
		
		// Headers
		this.headers.splice(toPos - 1, 0, row.splice(fromPos - 1, 1)[0]);
		
		// Loop through data rows
		this.data.forEach(function(row){ 
			row.splice(toPos - 1, 0, row.splice(fromPos - 1, 1)[0]);	
		});
	}	
}
