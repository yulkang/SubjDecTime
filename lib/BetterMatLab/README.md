# Better MatLab / Bless My Life (BML) Package
: A collection of ~1000 MATLAB utilities organized in subpackages.

## Highlights
- Plotting (bml.plot.*)
  - **crossLine**: add one or multiple vertical, horizontal, or diagonal line(s) that span the axes
  - **errorbar_wo_tick**: errorbar without tickmarks
  - **errorbarShade**: shaded confidence interval
  - **figure2struct**: package components of a figure/axes into fields of a struct such as lines or markers.
  - **get_all_xy**: get all x and y coordinates of lines in an axes.
  - **fig_tag**: get a handle to a figure with a name rather than a number.
  - **gltitle**: global title (top, column, row) for a set of axes.
  - **gradLine**: line with gradually changing colors.
  - **imgather**: gather image files into subplots.
  - **isvalidhandle**: test if the handle is valid (not deleted) across versions of MATLAB.
  - **openfig_to_axes**: open a .fig file to an axes.
  - **position_subplots**: position subplots within a figure with margins (top, bottom, left, right, between columns/rows).
  - **sameAxes**: set axes limits to the maximum extent among given.
  - **savefigs**: save a figure into .fig *and* print to custom formats (.png or .tif) with one command.
  - **subplot_by_pos**: obtain an array of handle of subplots by position (useful when subplots are moved for printing).
  - **subplotRC**: similar to subplot but with row and column indices: subplotRC(n_row, n_col, row, col).
  - **ylim_robust**: adjust ylim excluding outlier data points.
  
- Object-oriented programming (bml.oop.*)
  - **CodeClip**: produce boilerplate codes for object-oriented programming, such as get_* or set_* functions.
  - **copyprops**: find and copy properties after filtering (include/exclude hidden, protected, etc.)
  - **DeepCopyable**: deep copy handles recursively.
  - **PropFileNameTree**: easily get descriptive strings from properties suitable for file names.
  - **VisitableTree**: implements the visitor pattern.
  - **varargin2props**: set properties from varargin
  
- Package management (bml.pkg.*)
  - **PackageOrganizer**: easily rename classes/packages 
  
- String operations (bml.str.*)
  - **bsxStrcmp**: compare two sets of strings
  - **cmd2link**: make a link from a MATLAB command that is clickable when displayed.
  - **csprintf**: obtain a cell array of strings from an array of arguments.
  - **err_msg**: produce a formatted string that resembles that from error() that can be displayed by disp() or warning().
  - **is_alphanumeric**: test if the string consists alphabets and numbers only.
  - **is_valid_variable_name**: test if the string is a valid MATLAB variable name.
  - **Serializer**: serializes a variable (numeric, string, struct, cell) in a format suitable for file names.
  - **strrep_cell**: perform strrep with multiple pairs of source and destination substrings.
  - **strrep_rdir**: perform strrep in files in all subdirectories.
  - **wrap_text**: add newlines to wrap the text.
  
- Statistics
- Distributions
- Math
- Function arguments

... And many more!
