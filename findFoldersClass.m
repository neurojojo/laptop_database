classdef findFoldersClass < handle
    
    properties
        folderTable;
        subfolderTable;
        trackingParametersTable;
        metadata;
        tracks = struct();
        segs = struct();
        hmmsegs = struct();
        namesTable;
    end
    
    properties(Constant)
        Nstates = 2; % For the HMM
        nparams = 18;
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
    %   .makeTrackObjs() produces tracks from Tracking.m files
    %   .makeSegObjs() produces segs from results.m files
    %   .makeHMMSegObjs() produces hmmsegs from 
    %   .switchHMMstates() goes into each hmmsegs object and determines
    %   whether to switch the data in the State1 and State2 fields
    
    methods
        function obj = findFoldersClass(options)
            
            TLD = options.TLD;
            folder_regexpstring = options.search_folder;
            file_regexpstring = options.search_subfolder;
            
            obj.metadata.options = options;

            ALL_files=dir(TLD);
            % Restrict to DIRECTORIES:
            ALL_files=ALL_files( arrayfun( @(x) and( gt(numel(x.name),2), x.isdir ), ALL_files ), : );
            
            % Checking for 
            fprintf('Checking for %s\n', folder_regexpstring );
            fprintf('within subfolders of:\n')
            arrayfun(@(x) fprintf('%s\\%s\\\n', x.folder, x.name), ALL_files );
                        
            % Check each folders of the TLD to find folder_regexpstring matches
            % Result goes to obj.folderTable
            subdirectories = arrayfun(@(x) dir( sprintf('%s\\%s',x.folder,x.name) ), ALL_files, 'UniformOutput', false );
            
            %% Contents of those directories
            subdirectory_contents = arrayfun( @(x) dir( sprintf('%s\\%s\\',x.folder,x.name) ), ALL_files  , 'UniformOutput', false);
            
            allresults = [];
            for these_contents = subdirectory_contents'
                all_files_this_subdirectory = arrayfun(@(y) regexp( y{1}.name, folder_regexpstring ),...
                                                              arrayfun(@(x) x, these_contents{1}, 'UniformOutput', false), 'UniformOutput', false );
                allresults = [ allresults; arrayfun(@(x) sprintf( '%s\\%s', x.folder, x.name),...
                                                         these_contents{1}( find(arrayfun( @(x) numel(x{1}), all_files_this_subdirectory )==1) ),'UniformOutput',false) ];
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

        function saveTables(obj,varargin)
        
            if nargin>1; mystr = sprintf('_%s_',varargin{1}); else mystr=''; end
            save( sprintf('allfolders%s_%s.mat',mystr,date), 'obj' );
        
        end
        
        function collectParameters(obj)
            
            % Outputs trackingParametersTable
            
            % We need to have found a tracking file, so each
            % tracksTableClass object will have parameters
            %
            % The best way to locate these tracking files is through the
            % linked metadata within each tracks object
            output_cell = struct2cell( structfun(@(x) sprintf('%s\\Tracking.mat',x.metadata.Directory), obj.tracks , 'UniformOutput', false, 'ErrorHandler', @(x,y) obj.doNothing() ) );
            
            parameters_out = cellfun(@(x) load(x,'costMatrices','gapCloseParam'), output_cell, 'UniformOutput', false, 'ErrorHandler', @(x,y) obj.doNothing() );
            
            % Retrieve all the parameters from the cell arrays created in
            % the loading step
            parameters_table = cellfun( @(x) struct2table( x.costMatrices(2).parameters, 'AsArray', true ), parameters_out, 'ErrorHandler', @(x,y) obj.doNothing(), 'UniformOutput', false );
            
            for i = 1:numel(parameters_table); 
                if numel(parameters_table{i})<18; [parameters_table{i}.gapExcludeMS,parameters_table{i}.strategyBD] = deal(nan,nan); 
                end
            end
            all_parameters = table(); for this_table = parameters_table'; if istable(this_table{1}); all_parameters = [ all_parameters; this_table{1} ]; 
                else
                    emptyrow = array2table( nan(1, obj.nparams), 'VariableNames', all_parameters.Properties.VariableNames );
                    [emptyrow.brownScaling, emptyrow.ampRatioLimit,emptyrow.linScaling] = deal( [nan, nan], [nan, nan], [nan, nan] );
                    all_parameters = [ all_parameters; emptyrow ]; 
                end
            end
            all_parameters.brownStdMult = rowfun(@(x) {num2str(x{1}')}, all_parameters(:,4) );
            all_parameters.linStdMult = rowfun(@(x) {num2str(x{1}')}, all_parameters(:,11) );
            
            obj.trackingParametersTable = all_parameters;
            
        end
        %output = arrayfun( @(year) rowfun(@(x) ~isempty( regexp(x{1}, sprintf('%i',year) ) ), obj.subfolderTable(:,1) ), [2016:2019], 'UniformOutput', false );
            %output = cellfun( @(x) obj.subfolderTable( find( x.Var1==1 ), : ), output, 'UniformOutput', false );
            %1
        
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
        
        function makeTrackObjs(obj,varargin)
            
            if nargin>1; mystr = varargin{1}; else; mystr = ''; end
            
            for i = 1:size(obj.subfolderTable)
               searchquery = regexp( obj.subfolderTable(i,:).Name{1}, sprintf('.*%s.*[Ch1]',mystr), 'match'); 
               try
                   tmp_ = tracksTableClass( searchquery{1}, i, obj.metadata.options.optional_args );
                   obj.tracks.(sprintf('obj_%i',i)) = tmp_;
                   obj.metadata.logs.tracks{i} = sprintf('Success');
               catch
                   obj.tracks.(sprintf('obj_%i',i)) = tracksTableClass(i);
                   obj.metadata.logs.tracks{i} = sprintf('%i failed: %s (%s)', i, lasterr, datetime()); % Tell on the failing file
                   fprintf('Created an empty table for obj_%i',i);
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
            if nargin==3
                objToClear = varargin{1};
                comment = varargin{2};
                if and( isnumeric(objToClear) , ischar(comment) )
                    obj.hmmsegs.(sprintf('obj_%i',objToClear)) = brownianTableClass( objToClear, comment);
                    fprintf('Cleared out Brownian Table object %i for reason: %s\n', objToClear, comment);
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
        
        function getTrackLengths( obj )
           
            % For all the objects in the structure %
            for this_obj = fields( obj.tracks )'
                
                obj.tracks.(this_obj{1}).tracksTable.trackLength = arrayfun( @(idx) numel( obj.tracks.(this_obj{1}).tracksTable(idx,:).x{1} ), ...
                    [1:size(obj.tracks.(this_obj{1}).tracksTable,1)] )';
                
            end
            
        end
        
        % House-keeping functions %
        
        function varargout = doNothing(obj,varargin)
            varargout{1}=[];
        end
        
        function varargout = returnNaN(obj,varargin)
            varargout{1}=repmat(NaN,1,varargin{1});
        end
        
        % Overloaded functions %

        
    end
    
end