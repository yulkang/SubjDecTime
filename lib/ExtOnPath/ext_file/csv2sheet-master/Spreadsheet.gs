/**
 * Spreadsheet
 * 
 * Wraps Google Spreadsheet object with useful methods. 
 * Note: Google Apps Script does not allow direct addition
 * of prototype properties to its native classes.
 * 
 * @param {Object} DriveSpreadsheet - Google Spreadsheet object
 */
function Spreadsheet(DriveSpreadsheet) {
	
	this.obj = DriveSpreadsheet;
	this.file = DriveApp.getFileById(this.obj.getId());
	this.name = this.file.getName();
};

Spreadsheet.prototype = {
		
	/**
	 * createSheet
	 * 
	 * @param {String} name
	 * @returns {Object} CsvApp Sheet object
	 */
	createSheet : function(name) {
		
		// If there's a blank "Sheet1", rename it rather than create
		// new sheet.
		if ( (this.sheets.Sheet1) && (!this.sheets.Sheet1.obj.getLastRow()) ) {
			Logger.log("Changed name of \'Sheet1\' to \'%s\' in spreadsheet \'%s\'", name, this.name)			
			return new Sheet(this.sheets.Sheet1.obj.setName(name));
		} else {
			this.obj.insertSheet(name);
			Logger.log("New sheet \'%s\' created in spreadsheet \'%s\'", name, this.name)
			return new Sheet(this.obj.getActiveSheet());
		}
	},

	/**
	 * getSheets
	 * 
	 * Return CsvApp Sheet objects keyed by sheet name
	 */
	getSheets : function() {
		var sheets = this.obj.getSheets();
		this.sheets = {};
		for (var i=0; i < sheets.length; i++) {
	        var sheet = new Sheet(sheets[i]);
	        this.sheets[sheet.name] = sheet;
	    } 
	},
	
	/**
	 * getSheetByName
	 * 
	 * @param {String} name
	 * @returns {Object} sheet - CsvApp Sheet object
	 */
	getSheetByName : function(name) {
		this.getSheets();
		return this.sheets[name] || false;
	}
}
		






