/**
* Folder
* 
* Wraps Google Folder object with useful methods. 
* Note: Google Apps Script does not allow addition
* of prototype properties to its native classes.
*  
* @param {Object} DriveFolder - Google Drive Folder object
*/

function Folder(DriveFolder) {
  
	this.obj = DriveFolder;
	this.name = this.obj.getName();
};

Folder.prototype = {
		
	/**
	 * empty
	 * 
	 * Set all files in folder to Trashed
	 */
	empty : function() {
		var files = this.obj.getFiles();
		while (files.hasNext()) {
			files.next().setTrashed(true);
		}
	},
	
	/**
	 * getFiles
	 * 
	 * @returns {Object} files - Google File objects keyed by file name
	 */
	getFiles : function() {
		var files = {};
		var fileIterator = this.obj.getFiles();
		while (fileIterator.hasNext()) {
			var file = fileIterator.next();
			files[file.getName()] = file;
		}
		
		return files;
	},
		
	/**
	 * getSubFolders
	 * 
	 * Traverse path to get Drive folders by name. Note: This does 
	 * not handle multiple folders with same name and DriveApp offers
	 * no reliable way to identify current folder. Caveat emptor!
	 * 
	 * @param {array} - path - folder hierarchy as array of folder
	 * names ending with array of 1 or more subfolders
	 * @return {object} - folders - 	CsvApp Folder objects keyed by
	 * folder name.
	 */
	getSubFolders : function (path) {
		
		// Traverse parents
		var parent = this.obj;
		for (var i=0; i < path.length - 1; i++) {
			parent = parent.getFoldersByName(path[i]).next();
		};
		
		// Get folders listed in final element and instantiate CsvApp folder object
		var folders = {};
		path.pop().forEach( function(el) {
			folders[el] = new Folder(parent.getFoldersByName(el).next());
		});
		
		return folders
	},
  
	/**
	 * moveFile
	 * 
	 * @param {Object} DriveFile - Google file object
	 * @param {Object} toFolder - CsvApp folder object
	 */
	moveFile : function(DriveFile, toFolder) { 
		toFolder.obj.addFile(DriveFile);
		this.obj.removeFile(DriveFile);
	},
	
	/**
	 * moveFiles
	 * 
	 * Move all files to another folder
	 * 
	 * @param {Object} toFolder - CsvApp Folder object
	 */ 
	moveFiles : function (toFolder) { 
		var fileIterator = this.obj.getFiles();
		while (fileIterator.hasNext()) {
			var file = fileIterator.next();
			toFolder.obj.addFile(file);
			this.obj.removeFile(file);
		}
	}				
}