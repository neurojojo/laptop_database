classdef tracksTableClass < handle

    properties
       tracksTable;
       metadata;
    end
    
    properties(GetAccess='private')
       Ntracks;
       dims=[0,256,0,256]; % This could change but for our data it seems constant
       Nsegs;
    end
    
    properties(GetAccess='private')
        %defaultFiles = {'Tracking.mat','TrackingPst.mat','smTracesCh1.mat','smTracesCh1Pst.mat','smTracks.mat','results.mat','analysis_output.mat'};
        defaultFiles = {'Tracking.mat','results.mat'};
        FilesToFind;
        % These are properties for the table
        varnames = {'id','trackStart','x','y'};
        vartypes = {'uint8','uint8','cell','cell'};
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%
        % CONSTRUCTOR FUNCTION %
        %%%%%%%%%%%%%%%%%%%%%%%%
        function obj = tracksTableClass(varargin) 
            
            if strcmp( class(varargin{1}),'double')
                obj.metadata.obj_idx = varargin{1};
                obj.metadata.fileStruct = {};
                obj.metadata.Type = 'tracks';
                obj.metadata.Comments = 'Empty tracks';
                obj.tracksTable = table('Size',[0 numel(obj.varnames)],'VariableTypes',obj.vartypes,'VariableNames',obj.varnames);
                return
            end
            % varargin:
            % 1: Directory
            % 2: Index #
            % 3: optional_args
            %    -'FilesToFind'
     
            % Check for filenames
            
            Directory = varargin{1};
            if ~isempty( strfind( Directory, '.mat' ) );
               Directory = regexp( Directory, '.*(?=\\)', 'match' ); Directory = Directory{1};
            end
            
            obj_idx = varargin{2};
            
            % Check for an optional_args structure and parse it if exists
            if nargin>2; optional_args = varargin{3}; end
            
            if ~isempty( find( strcmp('FilesToFind',optional_args) == 1 ) );
                FilesToFind = optional_args{ 1 + find( strcmp( 'FilesToFind', optional_args ) == 1 )}; else FilesToFind = [];
            end
            
            % Create metadata based on the input
            obj.metadata.obj_idx = obj_idx;
            fprintf('Added metadata: %i\n',obj_idx);
            obj.metadata.Directory = Directory;
            fileStruct = struct();
            obj.metadata.fileStruct = fileStruct;
            
            % Create a default table
            obj.tracksTable = table('Size',[0 numel(obj.varnames)],'VariableTypes',obj.vartypes,'VariableNames',obj.varnames);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % There are several types of files that are part of the     %
            % pipeline, look for them here                              %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Signe's Default Profile
            if strcmp(FilesToFind,'signe') % Default folder structure %
                [fileStruct.Tracking,fileStruct.TrackingPst,fileStruct.results,fileStruct.analysis_output] = deal( 1,0,1,1);
                [fileStruct.address_Tracking,fileStruct.address_results,fileStruct.address_analysis_output] = deal( fullfile(Directory,'Tracking.mat'),...
                                                                                            fullfile(Directory,'results.mat'),...
                                                                                           fullfile(Directory,'\Data\analysis_output.mat'));
                % Check for the results.mat file if it exists
                 tmp=whos('-file',fileStruct.address_results,'results','size');
                 % If it does not exist, an error will be thrown and all
                 % the files will be searched
                 fprintf('Signe file profile loaded.\n');  
            end
            
            % User specified profile
            if or( isempty(FilesToFind), strcmp(FilesToFind,'default')) % If the user specified files
                obj.FilesToFind = obj.defaultFiles;
                fileStruct = obj.findFiles(Directory, obj.FilesToFind);     
                [fileStruct.Tracking,fileStruct.TrackingPst,fileStruct.results,fileStruct.analysis_output] = ...
                    deal( any(strcmp(obj.FilesToFind,'Tracking.mat')), any(strcmp(obj.FilesToFind,'TrackingPst.mat')), any(strcmp(obj.FilesToFind,'results.mat')), any(strcmp(obj.FilesToFind,'analysis_output.mat')));    
            end
            
            if ~any( cell2mat(regexp( fieldnames(fileStruct), 'address.*')) )
               obj.metadata.Comments = sprintf('No addresses of files were found. We searched:\n%s\n...Did you enter the directory correctly?', Directory); 
               return
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%% TRACKING DATA PARSED HERE %%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if and(~fileStruct.Tracking, fileStruct.analysis_output); obj.metadata.Comments = sprintf('No tracking file located even though the HMM analysis file exists at:\n%s', fileStruct.address_analysis_output); 
                return
            end
            if ~fileStruct.Tracking; obj.metadata.Comments =  sprintf('No tracking file located and no HMM analysis files located'); 
                return
            end
            
            fileStruct.N_TrackingPst=0; fileStruct.N_Tracking=0;
            
            % Tracking file is located
            if isfield(fileStruct,'Tracking')
                try
                    tracksFinal = load(fileStruct.address_Tracking,'tracksFinal'); 
                    TrackingFile = fileStruct.address_Tracking; 
                catch
                    obj.metadata.Comments = sprintf('Tracking file does not contain tracksFinal variable'); 
                    return
                end
                    fileStruct.N_Tracking = max(size(tracksFinal.tracksFinal)); 
                    TrackingFile = fileStruct.address_Tracking; 
            end
            % TrackingPst file is located
            %if isfield(fileStruct,'TrackingPst'); 
            %    try; 
            %        tmp=whos('-file',fileStruct.address_TrackingPst,'tracksFinal','size'); fileStruct.N_TrackingPst = max(tmp.size); 
            %    catch; 
            %        obj.metadata.Comments = sprintf('Error in the tracking file'); return
            %    end; 
            %end;
            % DC-MSS segmentation file is located
            
            if fileStruct.results
                tmp=whos('-file',fileStruct.address_results,'results','size'); 
                fileStruct.N_results = max(tmp.size); 
                if fileStruct.N_Tracking==fileStruct.N_results; 
                    TrackingFile = fileStruct.address_Tracking; 
                end
                if fileStruct.N_TrackingPst==fileStruct.N_results; 
                    TrackingFile = fileStruct.address_TrackingPst; 
                end
            end
            
            if isempty(TrackingFile); obj.metadata.Comments = sprintf('No suitable Tracking file located'); return; end
            % Locate the Tracking file in the Files cell
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Using the tracksFinal variable, increase the table  %
            % ONCE EVERYTHING HAS CHECKED OUT                     %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            Ntracks = max( size(tracksFinal.tracksFinal) );
            obj.tracksTable = table('Size',[Ntracks numel(obj.varnames)],'VariableTypes',obj.vartypes,'VariableNames',obj.varnames);
            obj.tracksTable.id = [1:Ntracks]';

            % Send tracksFinal variable to extractPosition method to
            % get x and y
            [obj.tracksTable.x, obj.tracksTable.y, obj.tracksTable.trackStart] = obj.extractPosition(tracksFinal.tracksFinal);
            obj.metadata.fileStruct = fileStruct;
            obj.metadata.Type = 'tracks';
            obj.metadata.Comments='NA';
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % END CONSTRUCTOR FUNCTION %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
            
        % Overloaded functions %
            
        function hits = find(obj,search_query)
            
            equality_type = cell2mat(regexp(search_query,'(<=)|(>=)|(<>)|(<)|(>)','match'));
            value = str2double(regexp( search_query, '(\d+)$', 'match' ));
            parameter = regexp( search_query, '[a-zA-Z]+', 'match' ); parameter = parameter{1};
            
            switch equality_type;
                case '<'
                    hits = find( lt(obj.tracksTable.(parameter), value) == 1 );
                case '>'
                    hits = find( gt(obj.tracksTable.(parameter), value) == 1 );
                case '<='
                    hits = find( le(obj.tracksTable.(parameter), value) == 1 );
                case '>='
                    hits = find( ge(obj.tracksTable.(parameter), value) == 1 );
                case '<>'
                    hits = find( ne(obj.tracksTable.(parameter), value) == 1 );
            end
            
        end
        
                
        function plot(obj,trackIdx,varargin)
            
           if nargin==1
               trackIdx = unique(obj.tracksTable.id);
           end
           
           % Plot multiple tracks if they're present
           if gt(numel( trackIdx ),1)
               set(gca,'NextPlot','add');
               thisplot = arrayfun(@(thisIdx) plot( obj.tracksTable(thisIdx,:).x{1},...
                     obj.tracksTable(thisIdx,:).y{1} ), trackIdx ); 
           else
               
               thisplot = plot( obj.tracksTable(trackIdx,:).x{1},...
                     obj.tracksTable(trackIdx,:).y{1} ); 
           end
           
           % Check for optional arguments
           if ~isempty(varargin)
                arrayfun( @(thisline) arrayfun( @(x) set( thisline, varargin{2*x-1}, varargin{2*x} ), [1:numel(varargin)/2] ), thisplot );
           end
           
           
        end
        

        function saveTables(obj,varargin)
            if nargin>1; mystr = varargin{1}; end
            save( sprintf('%s_%s_files_%05d.mat',obj.metadata.Type,mystr,obj.metadata.Key), 'obj' );
        end

    end

        methods(Static)
                  
            % extractPosition function dissects tracksFinal into x,y %
            function varargout = extractPosition(tracksFinal)

                % Extract each x and y position from tracksFinal.tracksCoordAmpCG
                % [x0,y0,...(6 entries),x1,y1,...]
                
                if isfield(tracksFinal,'ids'); tracksFinal = rmfield(tracksFinal,'ids'); end
                tracksSeq = extractfield(tracksFinal, 'seqOfEvents' );
                start_time = tracksSeq(1:8:end);
                
                xy = struct2cell( rmfield(tracksFinal,{'tracksFeatIndxCG','seqOfEvents'}) );
                getX = @(x) [ x(1:8:size(x,2)) ]; getY = @(x) [ x(2:8:size(x,2)) ];
                tmp_x = cellfun(getX, xy, 'UniformOutput', false); tmp_y = cellfun(getY, xy, 'UniformOutput', false);
                [varargout{1},varargout{2},varargout{3}] = deal(tmp_x',tmp_y',start_time');
            
            end
            % END OF extractPosition function %
            
            
            % findFiles function locates desired files %
            function fileStruct = findFiles(Directory, FilesToFind)
                
                for i = 1:numel(FilesToFind)
                    filetmp_ = dir( fullfile(Directory,'**',FilesToFind{i}) );
                    if ~isempty(filetmp_)
                        fprintf('Located %s\n', regexprep( fullfile(  filetmp_.folder, filetmp_.name ), regexprep(Directory,'\\','\\\'), '') ); 
                        
                        if size(filetmp_,1)>1
                            %fprintf('Located %i files\n', size(filetmp_,1) ); 
                            %for j = 1:size(filetmp_,1)
                            %   thisFile = fullfile( filetmp_(j).folder,filetmp_(j).name );
                            %   fprintf('%i) %s\n',j,thisFile); 
                            %end
                            %select_ = input('Which file to select? (Enter a number):');
                            select_ = size(filetmp_,1);
                        else
                            select_ = 1;
                        end
                        
                        fileStruct.( regexprep( FilesToFind{i}, '.mat', '') ) = 1;
                        fileStruct.( regexprep( strcat('address_',FilesToFind{i}), '.mat', '') ) = fullfile(  filetmp_(select_).folder, filetmp_(select_).name ); 
                    else
                        fileStruct.( regexprep( FilesToFind{i}, '.mat', '') ) = 0;
                    end
                end
            end
            % END OF findFiles function %
            
            
        end
        
    end