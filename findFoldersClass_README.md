findFoldersClass
----------------
assignNames,"Takes the subfolderTable table from the object and runs each row through parseFilename, an independent function, which outputs a structure with different fields such as 'Experimenter', 'Gprotein', 'Quantities', 'Concentrations'"

computeRelativeSegIdx,"Takes segs structure from the object and runs the findFoldersClass method DC_MSS_Segs which (1) numbers the segments in a track and (2) identifies the segment as either being at the start (-1), middle (0), or end(1)"

findFoldersClass,"This creates the object based on the input of an options structure (which has three fields: TLD, search_folder containing a regexp, search_subfolder containing a regexp)"

makeTrackObjs,"Runs a for loop through each of the directories located in subfolderTable, attempts to create a tracksTableClass object; if the object based on the files present cannot be made then an empty object is created to fill in"

saveTables,"Saves the object -- essentially save(filename, thisobject)"

clearTables,"Works in two modes: (1) Clears out brownianTableClass object from the hmmsegs structure for a reason specified in the second argument (2) If a csv is given with subfolders, the brownianTableClass objects matching those subfolders will be cleared from the hmmsegs structure"

makeHMMSegObjs,""

patchTracks,""

switchHMMstates,""

collectParameters,""

expand_DC_MSS_Segs,""

makeSegObjs,""

doNothing,"Returns an empty double" 
returnNaN,""     
