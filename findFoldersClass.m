classdef findFoldersClass < handle
    
    properties
        folderTable;
        subfolderTable;
        metadata;
        tracks = struct();
        segs = struct();
        hmmsegs = struct();
        namesTable;
    end
    
    % Constructor method takes one structure as an argument (options)
    %
    % options fields:
    %   TLD: The top level directory where all folders are located
    %   search_folder: This specifies the text of the FOLDERS to return
    %       ie. "_SM_" will return all folders containing those initials
    %   search_subfolder: This specifies the FILENAME to look for within the
    %       subfolders, and will return a table with locations to every such
    %       filename (use analysis_output.m for Bayesian, results.m for
    %       Tracking, etc)
    %   savelocation: This specifies the location to save the tables that
    %       are output
    %   optional_args: Goes only to makeTrackObjs and makeHMMSegObjs
    %
    % In-place methods:
    %   .saveTables() saves allfolders_date.mat to a options.savelocation
    %   .makeTrackObjs() produces tracks
    %   .makeSegObjs() produces segs
    %   .makeHMMSegObjs() produces hmmsegs
    %   .switchHMMstates() goes into each hmmsegs object and determines
    %   whether to switch the data in the State1 and State2 fields
    
    methods
        function obj = findFoldersClass(options)
            
            TLD = options.TLD;
            folder_regexpstring = options.search_folder;
            file_regexpstring = options.search_subfolder;
            
            obj.metadata.options = options;

            ALL_files=dir(TLD);
            allresults={};
            
            % Check each folders of the TLD to find folder_regexpstring matches
            % Result goes to obj.folderTable
            for i = 2:size(ALL_files,1)
                % Create myhits to search within the first level
                myhits = dir( sprintf('%s\\%s',ALL_files(i).folder,ALL_files(i).name) );
                results = arrayfun(@(x) ~isempty(regexp(x.name,...
                    folder_regexpstring...
                    )), myhits, 'UniformOutput', false);
                results = find(cell2mat(results)==1);
                for j = 1:size(results,1)
                    allresults = [allresults; {sprintf('%s\\%s',myhits(results(j)).folder,myhits(results(j)).name)}];
                end
            end
            
            obj.folderTable = allresults;
            
            % Check each subfolder from above for file_regexpstring matches
            % Result goes to obj.subfolderTable
            mytable = table();
           for i = 1:size(allresults)
               myt = rdir( sprintf('%s\\**\\%s', allresults{i}, file_regexpstring ) ); % For Bayesian: use analysis_output.mat
               if ~isempty(myt); mytable = [mytable; cell2table( extractfield(myt,'name')' )]; end
               fprintf('Currently located %i folders containing the file you want\n',size( mytable, 1 ));
           end
            
            obj.subfolderTable = mytable;
            obj.subfolderTable.Properties.VariableNames={'Name'};
            
        end
        
        function saveTables(obj)
            save( sprintf('allfolders_%s.mat',date), 'obj' );
        end
        
        function switchHMMstates(obj)
           mydiff = @(x) any( gt( diff(x.metadata.DiffCoeff), 0 )); % Is positive only if DC1 < DC2 
           % Our assumption is that DC1 should be > DC2
           toswitch = find( structfun( mydiff, obj.hmmsegs, 'UniformOutput', true ) == 1);
           for i = toswitch'
               tmp=obj.hmmsegs.(sprintf('obj_%i',i)).brownianTable.State1; obj.hmmsegs.(sprintf('obj_%i',i)).brownianTable.State1 = obj.hmmsegs.(sprintf('obj_%i',i)).brownianTable.State2; 
               obj.hmmsegs.(sprintf('obj_%i',i)).brownianTable.State2 = tmp;
               obj.hmmsegs.(sprintf('obj_%i',i)).metadata.DiffCoeff = fliplr( obj.hmmsegs.(sprintf('obj_%i',i)).metadata.DiffCoeff );
           end
        end
        
        function makeTrackObjs(obj)
            for i = max(1,numel(fields( obj.tracks ))):size(obj.subfolderTable) % Leave where you left off power
               searchquery = regexp( obj.subfolderTable(i,:).Name{1}, '.*[Ch1]', 'match'); searchquery = searchquery{1};
               try
                   tmp_ = tracksTableClass( searchquery, i, obj.metadata.options.optional_args );
                   obj.tracks.(sprintf('obj_%i',i)) = tmp_;
                   obj.metadata.logs.tracks{i} = sprintf('Success');
               catch
                   obj.metadata.logs.tracks{i} = sprintf('%i failed: %s (%s)', i, lasterr, datetime()); % Tell on the failing file
               end
            end
        end
        
        function makeSegObjs(obj)
            for i = max(1,numel(fields( obj.segs ))):size(obj.subfolderTable) % Leave where you left off power
                try
                    tmp_ = segsTableClass( obj.tracks.(sprintf('obj_%i',i)), obj.metadata.options.optional_args );
                    obj.segs.(sprintf('obj_%i',i)) = tmp_;
                    obj.metadata.logs.segs{i} = sprintf('Success');
                catch
                    obj.metadata.logs.segs{i} = sprintf('%i failed: %s (%s)', i, lasterr, datetime()); % Tell on the failing file
                end
            end
        end
        
        function makeHMMSegObjs(obj)
            
            for i = max(1,numel(fields( obj.hmmsegs ))):size(obj.subfolderTable) % Leave where you left off power
                try
                    tmp_ = brownianTableClass( obj.segs.(sprintf('obj_%i',i)), obj.metadata.options.optional_args );
                    obj.hmmsegs.(sprintf('obj_%i',i)) = tmp_;
                    obj.metadata.logs.hmmsegs{i} = sprintf('Success');
                catch
                    obj.hmmsegs.(sprintf('obj_%i',i)) = brownianTableClass(0);
                    obj.metadata.logs.hmmsegs{i} = sprintf('%i failed: %s (%s)', i, lasterr, datetime()); % Tell on the failing file
                end
            end
        end
       
        function assignNames(obj)
            
            mynames = rowfun( @parseFilename, obj.subfolderTable );
            mynames = struct2table( mynames.Var1 );
            mynames = rowfun( @convertRowToStr, mynames );
            mynames = table( [1:numel(mynames)]', table2array( mynames ) , 'VariableNames', {'AbsoluteIdxToSubfolders','Shortname'} )
            obj.namesTable = mynames;
            
        end
        
        function clearTables(obj, objToClear, comment)
            if and( strcmp( class(objToClear), 'double'),strcmp( class(comment), 'char') )
                obj.hmmsegs.(sprintf('obj_%i',objToClear)).brownianTable = brownianTableClass(comment);
            else
                fprintf("Please enter the object to clear and the comment as text. clearTables(10,'Testing parameters')\n");
            end
        end
        
        function patchTracks(obj)
            
            myobjs = fields( obj.hmmsegs );
            
            for I = myobjs'
                thisObj = I{1};
                % Currently this only works for two state models
                if ~strcmp( obj.hmmsegs.(thisObj).metadata.Type, 'Error' ) 
                    tmp = [ obj.hmmsegs.(thisObj).brownianTable.State1;obj.hmmsegs.(thisObj).brownianTable.State2];
                    segs = tmp.segIdx;
                    segs_histogram = table( unique(segs), histc( segs, unique(segs) ) , 'VariableNames', {'segIdx','NumSegs'} )
                    segNumber = zeros( size(tmp,1), 1 );

                    for i = unique(segs_histogram.NumSegs)'
                        theseSegs = segs_histogram.segIdx( ismember( segs_histogram.NumSegs, i ) ); % The indices of segments 
                        segNumber( find(ismember( tmp.segIdx, theseSegs ) == 1) ) = i;
                    end

                    obj.hmmsegs.(thisObj).brownianTable.State1.tracksInSeg = segNumber([1:numel( obj.hmmsegs.(thisObj).brownianTable.State1.tracksInSeg )]);
                    obj.hmmsegs.(thisObj).brownianTable.State2.tracksInSeg = segNumber([numel( obj.hmmsegs.(thisObj).brownianTable.State1.tracksInSeg )+1:numel(segNumber)]);
                end
            end
            
        end
        
        
    end
    
end

