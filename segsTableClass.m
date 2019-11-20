classdef segsTableClass < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        segsTable;
        metadata;
    end
    
    properties(GetAccess='private',Constant)    
            varTypes = {'uint8','uint8','uint8','uint8','uint8','uint8','cell','cell','logical'};
            varNames = {'segIdx','trackIdx','segStart','segEnd','Nframes','segType','x','y','nan'};
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%
        % CONSTRUCTOR FUNCTION %
        %%%%%%%%%%%%%%%%%%%%%%%%
        function obj = segsTableClass(varargin)
            
            tracksTable = varargin{1};
            fileStruct = tracksTable.metadata.fileStruct;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%% SEGMENTATION DATA PARSED HERE %%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Locate the Segmentation file in the Files cell
            SegmentationFile = fileStruct.address_results;
            if isempty( fileStruct.address_results ); error('No segmentation file found'); end
            if isempty( whos('-file',SegmentationFile,'results') ); error('Tracking file does not contain results variable'); end
            % If all errors pass, load segmentation results file
            results_ = load(SegmentationFile,'results');
            
            [trackIdx, segStart, segEnd, Nframes, segType] = obj.getSegments(results_.results);
            Nsegs = numel(trackIdx);
            
            % Altering the table variables will cause errors in rowfun
            % expressions below
            obj.segsTable = table('Size',[Nsegs numel(obj.varNames)],'VariableTypes',obj.varTypes,'VariableNames',obj.varNames);
            obj.segsTable.segIdx = [1:Nsegs]';
            [obj.segsTable.trackIdx, obj.segsTable.segStart, obj.segsTable.segEnd, obj.segsTable.Nframes, obj.segsTable.segType] = deal( trackIdx, segStart, segEnd, Nframes, segType );
            
            fprintf('Loaded segmentation file\n');
            % Optional, discarding NaN segments
            % obj.segsTable = obj.segsTable( isnan(obj.segsTable.segType)==0 ,:);
            % fprintf('Discarded %i NaN classified segments (out of total %i)\n', numel(trackIdx)-size(obj.segsTable,1), size(obj.segsTable,1) );

            tmp_x = tracksTable.tracksTable(obj.segsTable.trackIdx,'x');
            tmp_y = tracksTable.tracksTable(obj.segsTable.trackIdx,'y');

            [obj.segsTable.x,obj.segsTable.y,obj.segsTable.trackStart] = deal( tracksTable.tracksTable( obj.segsTable.trackIdx, : ).x,...
                tracksTable.tracksTable( obj.segsTable.trackIdx, : ).y,...
                tracksTable.tracksTable( obj.segsTable.trackIdx, : ).trackStart);
            
            fxn = @(segStart,segEnd,x,trackStart) { x{1}([segStart-trackStart+1:segEnd-trackStart+1]) };
            obj.segsTable.xSeg = table2array( rowfun(fxn, obj.segsTable(:, [3,4,7,10])) ); % rowfun outputs a table so to avoid creating a table in a table
            obj.segsTable.ySeg = table2array( rowfun(fxn, obj.segsTable(:, [3,4,8,10])) ); % use array2table
            obj.segsTable.nan = cellfun(@any, cellfun( @isnan, obj.segsTable.xSeg , 'UniformOutput', false));
            obj.segsTable.abs_segStart = obj.segsTable.segStart + tracksTable.tracksTable.trackStart( obj.segsTable.trackIdx ) - 1;
            obj.segsTable = obj.segsTable(:,{'trackIdx','segIdx','abs_segStart','segStart','segType','xSeg','ySeg','nan'}); % Rearrange
            
            obj.metadata = tracksTable.metadata;
            obj.metadata.Type = 'segs';
            
        end
        
        function plot(obj,trackId,varargin)
            
            % Input parsing
            hold = find(strcmp(varargin,'hold')==1);
            
            % Open windows parsing
            trackPlotter_obj=findobj('Name','trackPlotter');
            
            if ~isempty(trackPlotter_obj) % The trackPlotter figure is open
            else % Create the trackPlotter figure and an axis for it
                trackPlotter_obj = figure('Name','trackPlotter');
            end

            if isempty(hold) % Hold behavior off
                clf(trackPlotter_obj);
                ax1 = axes('Parent',trackPlotter_obj,'nextplot','replacechildren');
            else % Hold behavior on
                ax1 = axes('Parent',trackPlotter_obj,'nextplot','add');
            end
            
            plot( ax1, obj.tracksTable(trackId,:).x{1}, obj.tracksTable(trackId,:).y{1} );
            
        end
        
        function head(obj,varargin)
            if nargin==1
                disp(obj.table([1:5],:));
            else
                disp(obj.table([1:varargin{1}],:));
            end
        end
        
        function summary(obj)
            means = '';
            for i = 1:size(obj.table,2)
                try
                means=strcat(means,sprintf(' %1.2f', mean(obj.table{:,i})));
                catch
                means=strcat(means,' N/A');
                end
            end
            disp(means)
        end
        
        function showFilename(obj)
            fprintf('%s\n',obj.filename);
        end
    end
    
    methods(Static)
        
        function output_tbl = expandFromCol(my_tbl, col)
           % Given a table with columns a,b,c, ...
           % 
           % a  b     c
           % =  =  =======
           %       [n x m]
           %
           % If c has elements of size [n x m]
           % then a new table is created
           % with n rows
           output_tbl = [];
           for i = 1:size(my_tbl,1)
              output_tbl = [ output_tbl; repmat(i, size( my_tbl(i,:).(sprintf('%s',col)){1} ,1), 1), my_tbl(i,:).(sprintf('%s',col)){1} ];
           end
        end
        
        function output_cell = parseStates(ML_states, Nstate)
            % Search tokens of repeating N's within ML_states which has
            % data like '11111' '1112222111' '222111' (or '11222333')
            % Find the start and end of each match and produce a table into
            % varargout
            fprintf('Parsing state %i\n',Nstate);
            parseFxn = @(x) [ regexp( num2str(x,'%i'), sprintf('[%i]{1,}',Nstate),'start' ); regexp( num2str(x,'%i'), sprintf('[%i]{1,}',Nstate),'end' ) ]';            
            output_cell = cellfun(parseFxn, ML_states, 'UniformOutput', false);

            addIdx = @(x) [ [1:size(x,1)]', x ]; % An index, the start frame, the end frame, and a column for the # of frames in the state
            output_cell = cellfun(addIdx, output_cell, 'UniformOutput', false);
            
        end
        
        
        function varargout = getSegments(results) % Works on a results variable from DC-MSS output
            [all_start,all_end,all_type,all_idx] = deal([],[],[],[]);
            
            for i = 1:numel(results)
                Nsegs = size(results(i).segmentClass.momentScalingSpectrum,1);
                % There is a potential issue here where
                % momentScalingSpectrum makes the ending of one segment the
                % same as the beginning of another segment
                [start_,end_,type_] = deal( results(i).segmentClass.momentScalingSpectrum(:,1),...
                                            results(i).segmentClass.momentScalingSpectrum(:,2),...
                                            results(i).segmentClass.momentScalingSpectrum(:,3) );
                all_idx = [all_idx;repmat(i,Nsegs,1)];
                all_start = [all_start;start_];
                all_end = [all_end;end_];
                all_type = [all_type;type_];
            end
            varargout{1} = all_idx; varargout{2} = all_start; varargout{3} = all_end; varargout{4} = all_end-all_start; varargout{5} = all_type;
        end
        
        
    end
end

