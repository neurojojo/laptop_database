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
    
    properties(Constant)
        Nstates = 2; % For the HMM
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
               obj.hmmsegs.(sprintf('obj_%i',i)).metadata.switchDC = 1;
           end
           not_toswitch = find( structfun( mydiff, obj.hmmsegs, 'UniformOutput', true ) == 0);
           for i = not_toswitch'
               obj.hmmsegs.(sprintf('obj_%i',i)).metadata.switchDC = 0;
           end
        end
        
        function makeTrackObjs(obj)
            for i = 1:size(obj.subfolderTable) % Leave where you left off
               searchquery = regexp( obj.subfolderTable(i,:).Name{1}, '.*[Ch1]', 'match'); searchquery = searchquery{1};
               try
                   tmp_ = tracksTableClass( searchquery, i, obj.metadata.options.optional_args );
                   obj.tracks.(sprintf('obj_%i',i)) = tmp_;
                   obj.metadata.logs.tracks{i} = sprintf('Success');
               catch
                   obj.tracks.(sprintf('obj_%i',i)) = tracksTableClass(i);
                   obj.metadata.logs.tracks{i} = sprintf('%i failed: %s (%s)', i, lasterr, datetime()); % Tell on the failing file
               end
            end
        end
        
        function makeSegObjs(obj)
            for i = 1:size(obj.subfolderTable) % Leave where you left off power
                try
                    tmp_ = segsTableClass( obj.tracks.(sprintf('obj_%i',i)), i, obj.metadata.options.optional_args );
                    obj.segs.(sprintf('obj_%i',i)) = tmp_;
                    obj.metadata.logs.segs{i} = sprintf('Success');
                catch
                    obj.segs.(sprintf('obj_%i',i)) = segsTableClass(i);
                    obj.metadata.logs.segs{i} = sprintf('%i failed: %s (%s)', i, lasterr, datetime()); % Tell on the failing file
                end
            end
        end
        
        % This was added 12/5 and needs to be more properly integrated
        function computeRelativeSegIdx(obj)
            obj.segs = structfun( @(x) obj.expand_DC_MSS_Segs(x), obj.segs,'ErrorHandler',@(x,y) obj.doNothing ,'UniformOutput',false);
        end
        
        function output = expand_DC_MSS_Segs(obj,input_structure)
            try
                toexpand = histc( input_structure.segsTable.trackIdx, [1:max(input_structure.segsTable.trackIdx)] );
                input_structure.segsTable.segIdx_relative = cell2mat(arrayfun( @(x) [1:x]', toexpand,'UniformOutput',false ) );
                input_structure.segsTable.segIdx_identifier = [ eq( diff( input_structure.segsTable.segIdx_relative,1 ), 0 ); 0 ];
                output = input_structure;
            catch
                output = input_structure;
            end
        end
        % End of 12/5 additions
        
        function varargout = doNothing(obj,varargin)
            varargout{1}=[];
        end
        
        function varargout = returnNaN(obj,varargin)
            varargout{1}=repmat(NaN,1,varargin{1});
        end
        
        function makeHMMSegObjs(obj)
            
            for i = 1:size(obj.subfolderTable) % Leave where you left off power
                try
                    tmp_ = brownianTableClass( obj.segs.(sprintf('obj_%i',i)), i, '' );
                    obj.hmmsegs.(sprintf('obj_%i',i)) = tmp_;
                    obj.metadata.logs.hmmsegs{i} = sprintf('Success for obj %i',i);
                catch
                    obj.hmmsegs.(sprintf('obj_%i',i)) = brownianTableClass(i);
                    obj.hmmsegs.(sprintf('obj_%i',i)).metadata.logs.hmmsegs{i} = sprintf('%i failed: %s (%s)', i, lasterr, datetime()); % Tell on the failing file
                    fprintf('Failure for obj %i',i);
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
        
        function clearTables(obj, varargin)
            if nargin>2
                if and( strcmp( class(varargin{1}), 'double'),strcmp( class(varargin{2}), 'char') )
                    obj.hmmsegs.(sprintf('obj_%i',objToClear)).brownianTable = brownianTableClass( obj.hmmsegs.(sprintf('obj_%i',objToClear)), comment);
                end
            end
            
            if ~isempty( strfind( varargin{1},'.csv' ) )
                myt = readtable(varargin{1},'delimiter',',');
                myfxn = @(x) sum(find( ismember( obj.subfolderTable.Name , x ) == 1 ))
                toremove = rowfun( myfxn , myt, 'OutputFormat', 'uniform' );
                comment = sprintf('Removed through %s',varargin{1});
                for i = toremove'; if i>0; obj.hmmsegs.(sprintf('obj_%i',i)) = brownianTableClass( i, comment); fprintf('Emptied obj_%i Browniantables\n',i); end; end
            end
        end
        
        function patchTracks(obj)
            
            myobjs = fields( obj.hmmsegs );
            
            for I = myobjs'
                thisObj = I{1};
                % Currently this only workr two state models
                if and( ~strcmp( obj.hmmsegs.(thisObj).metadata.Type, 'Error' ), isfield( obj.hmmsegs.(thisObj).brownianTable, 'State1' ) ); 
                    tmp = [ obj.hmmsegs.(thisObj).brownianTable.State1;obj.hmmsegs.(thisObj).brownianTable.State2];
                    segs = tmp.segIdx;
                    segs_histogram = table( unique(segs), histc( segs, unique(segs) ) , 'VariableNames', {'segIdx','NumSegs'} );
                    segNumber = zeros( size(tmp,1), 1 );

                    for i = unique(segs_histogram.NumSegs)'
                        theseSegs = segs_histogram.segIdx( ismember( segs_histogram.NumSegs, i ) ); % The indices of segments 
                        segNumber( find(ismember( tmp.segIdx, theseSegs ) == 1) ) = i;
                    end
                    
                    try
                        obj.hmmsegs.(thisObj).brownianTable.State1.tracksInSeg = segNumber([1:numel( obj.hmmsegs.(thisObj).brownianTable.State1.tracksInSeg )]);
                        obj.hmmsegs.(thisObj).brownianTable.State2.tracksInSeg = segNumber([numel( obj.hmmsegs.(thisObj).brownianTable.State1.tracksInSeg )+1:numel(segNumber)]);
                    catch
                        1
                    end
                    
                end
            end
            
        end
        
        
    end
    
end