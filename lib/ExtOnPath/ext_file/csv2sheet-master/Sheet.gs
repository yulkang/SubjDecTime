/**
* Sheet
* 
* Wraps Google Sheet object with methods for merging csv.
* Parallel methods exist for Csv. Note: Google Apps Script 
* does not allow addition of prototype properties to its
* native classes.
* 
* @param {Object} DriveSheet - Google Sheet object.  
*/

function Sheet(DriveSheet) {
	
	this.obj = DriveSheet; 
	this.name = this.obj.getSheetName();
};

Sheet.prototype = {
	
	/**
	 * deleteCol
	 * 
	 * Delete column in sheet and headers array
	 * 
	 * @param {integer} pos - column position
	 */ 
	deleteCol : function(pos) {
		
		// Delete from sheet
		this.obj.deleteColumn(pos);
		
		// Delete from headers
  		this.headers.splice(pos - 1, 1);    
  		
  		// Log
 		Logger.log('Column deleted in sheet \'%s\' at position %s', this.name, pos);
	},
	
	/**
	 * getHeaders
	 * 
	 * Get array of column names for merge with csv
	 */
	getHeaders: function() {
		
		// Test for content in sheet before getting
		this.numCols = this.obj.getLastColumn();
		this.numCols ? this.headers = 
			this.obj.getRange(1, 1, 1, this.numCols).getValues()[0] :
			this.headers = false;
	},

	/**
	 * getPrimaryKeyVals
	 * 
	 * Get values in sheet for primary key defined in metadata.
	 * Used to prevent duplicate records.
	 *  
	 * @param {String} name - name of primaryKey column from metadata
	 */
	getPrimaryKeyVals: function(name) {
		
		// Find primary key column in sheet
		var keyPos = this.headers.indexOf(name) + 1;
		
		// Get column values (returned as array of single cell arrays [[value1],[value2] ...])
		return this.obj.getRange(2, keyPos, this.obj.getLastRow() - 1, 1).getValues() || [];
	},
  
	/**
	 * insertCol
	 * 
	 * Insert named column in sheet and headers
	 * 
	 * @param {String} name - column name
	 * @param {Integer} pos - column position
	 */
	insertCol : function(pos, name) {
		
		// Insert in sheet
		this.obj.insertColumns(pos); 
		this.obj.getRange(1, pos).setValue(name);
		this.obj.setColumnWidth(pos, CSVAPP.defaultColWidth);
        
		// Insert in headers
 		this.headers.splice(pos - 1, 0, name);
 		
 		// Log
 		Logger.log('Column \'%s\' inserted in sheet \'%s\' at position %s',
 				name, this.name, pos);
	},
	
	/**
	 * insertData
	 * 
	 * Write csv data rows to sheet
	 *  
	 * @param {Object} csv - CsvApp csv object
	 */
	insertData : function(csv) {					
		var range = this.obj.getRange(this.obj.getLastRow() + 1, 1, 
				csv.data.length, csv.headers.length);
		range.setValues(csv.data);
	},
	
	/**
	 * mergeCsv
	 * 
	 * Core function for implementing merge logic by 
	 * incrementally modifying live sheet.
	 * 
	 * @param {object} csv
	 */
	merge : function(csv) {
		
		// Get sheet header row
		this.getHeaders();
      
		// If sheet has no content, insert csv header as-is
		if(!this.headers) {      
			this.obj.appendRow(csv.headers);
			
			// Widen columns so longer headers/data elements are readable
			// Note: Could easily make formatting smarter and richer 
			for (var i=0; i < csv.headers.length; i++) {
				this.obj.setColumnWidth(i + 1, CSVAPP.defaultColWidth);
			}
		} 
      
		// Check if csv records are already in sheet.
		else if (!csv.removeDuplicates(this.getPrimaryKeyVals(csv.primaryKey))) {
			
			// Return if no data remains
			return true
		}
 
		// If headers are different, execute merge rules
		else if(!this.headers.equals(csv.headers)) {
			
			// Loop until end of longer headers array
			for (var i=0; i < Math.max(csv.headers.length, this.headers.length); i++) {
			
				// Get relative positions of current header in data and sheet
				var pos = i + 1, // columns are indexed from 1
					csvHeader = csv.headers[i],
					sheetHeader = this.headers[i],
					pos_csvHeaderInSheet = this.headers.indexOf(csvHeader) + 1,
					pos_sheetHeaderInCsv = csv.headers.indexOf(sheetHeader) + 1;
				
				// If current header is the same
				if (csvHeader == sheetHeader) {
					continue;
				}
				
				// If csv header not in sheet ...
				else if (csvHeader && !pos_csvHeaderInSheet) {
					
					// Log
					Logger.log('Csv \'%s\' has header \'%s\' that is not in sheet \'%s\'',
							csv.name, csvHeader, this.name);
					
					// Apply active merge rule
					switch (CSVAPP.mergeRules.onlyInCsv) {
			  
					  case 'preserve' :
						  this.insertCol(pos, csvHeader);
						  break;
						  
					  case 'moveAfter' :
						  this.insertCol(this.getLastColumn() + 1, csvHeader);
						  csv.moveCol(pos, csv.headers.length + 1);
						  break;
						  
					  case 'delete' :
						  csv.deleteCol(pos);
						  break;
					}
				}
				  
				// If sheet header not in csv ...
				else if (sheetHeader && !pos_sheetHeaderInCsv) {
					
					// Log
					Logger.log('Sheet \'%s\' has header \'%s\' that is not in csv',
							this.name, sheetHeader);
					
					// Apply active merge rule
					switch (CSVAPP.mergeRules.onlyInSheet) {
			  
					  case 'preserve' :
						  csv.insertCol(pos, sheetHeader)
						  break;
						  
					  case 'moveAfter' :
						  csv.insertCol( csv.headers.length + 1, sheetHeader);
						  this.moveCol(pos, this.getLastColumn() + 1);
						  break;
						  
					  case 'delete' :
						  this.deleteCol(pos);
						  break;
					}
				}
			
				// If headers in different positions ...
				else {
					
					// Log
					Logger.log('Header \'%s\' is in different positions in csv \'%s\' and sheet \'%s\'',
							csvHeader, csv.name, this.name);
					
					// Apply active merge rule
					switch (CSVAPP.mergeRules.differentPos) {
					
						case 'csvWins' :
							this.moveCol(pos_csvHeaderInSheet, pos);
							break;
						
						case 'sheetWins' :
							csv.moveCol(pos_sheetHeaderInCsv, pos);
							break;
					}
				}
			}
		}
		
		// Append resulting data to sheet
		this.insertData(csv); 
		
		// Move csv and metadata to processed folder
		csv.setProcessed();
	},

	/**
	 * moveCol
	 * 
	 * Move column in sheet and headers array
	 * 
	 * @param {Integer} fromPos - current column position
	 * @param {Integer} toPos - desired column position
	 */
	moveCol : function(fromPos, toPos) {
		
		// Insert new blank col 
		this.obj.insertColumns(toPos);
		
		// Increment fromPos if affected by insertion above
		var fromPosNew = fromPos + (fromPos > toPos);  
		
		//Copy data to new column
		var numRows = this.obj.getLastRow();
		this.obj.getRange(1, fromPosNew, numRows, 1).copyTo(this.obj.getRange(1, toPos, numRows,1));
		this.obj.setColumnWidth(toPos, CSVAPP.defaultColWidth);
        
		// Delete old column
		this.obj.deleteColumn(fromPosNew);
		
		// Update headers array
		this.headers.splice(toPos - 1, 0, this.headers.splice(fromPos - 1, 1)[0]);
        
		// Log
 		Logger.log('Column moved from position %s to %s in sheet \'%s\'',
 				fromPos, toPos, this.name);
	}
}