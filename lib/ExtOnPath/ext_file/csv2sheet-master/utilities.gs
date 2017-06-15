/**
 * Array.prototype.equals
 * 
 * Helper method for comparing e.g., csv 
 * and sheet headers 
 * 
 * @param {Array} arr - array for comparison 
 */
Array.prototype.equals = function(arr) {
	if (this.length !== arr.length) {
		return false;
	};
	
	for (var i = this.length; i--;) {
		if (this[i] !== arr[i]) {
			return false;
		};
	};
	
	return true;
};


/**
 * Array.prototype.sortByProp
 * 
 * Helper method for sorting array of
 * objects,  e.g., sorting csv queue by time
 * 
 * @param {String} prop - property by which to sort 
 */
Array.prototype.sortByProp = function(prop){
	return this.sort(function(a,b){
		return (a[prop] > b[prop]) ? 1 : (a[prop] < b[prop]) ? -1 : 0;
	});
}


/**
 * Object.prototype.extend
 * 
 * Semi-safe helper method for incorporating object property/values
 * directly in other object (ie, static inheritance)
 * 
 * @param {Object} obj
 */
Object.defineProperty ( 
	Object.prototype, 
	"extend", 	{ 
		value: function extend(obj) {
			for(var i in obj) {
				this[i] = obj[i]
			}
		},			
		enumerable: false
	}
);


/**
* Profile
* 
* Log execution times. ISSUE: Old logs seem
* to get mixed into new. Logger.clear() doesn't
* help.
*/
function Profile() {
	this.times = [new Date().getTime()];
	Logger.log("PROFILE: \'Start\'");
};

Profile.prototype = {
	
	/**
	 * log
	 * 
	 * @param {String} status - What's happened since last profile call
	 */
	log : function(status) {
      
		this.times.push(new Date().getTime());
		Logger.log("PROFILE: \'%s\'.\nTime since last profile: %s ms. \nCumulative time: %s ms", 
			status, this.times.slice(-1)[0] - this.times.slice(-2)[0], this.times.slice(-1)[0] - this.times.slice(0)[0]);
	}
};


/**
* publishLog
* 
* Save Google Apps Script log to csv2sheet/logs/ folder
*/
function publishLog() {
	
	// Get log
    this.text = Logger.getLog();
  
    // Prune excess date info
    this.text = this.text.replace( /.*(\d\d:\d\d:\d\d).*INFO/g, '$1')
	
    // Set title to date string
    this.filename = (new Date().toISOString());
    
    // Create Google Doc  
    this.doc = DocumentApp.create(this.filename);
    this.doc.setText(this.text);
    
    // Move to logs folder
    CSVAPP.root.moveFile(DriveApp.getFileById(this.doc.getId()), CSVAPP.folders.logs);
};
  