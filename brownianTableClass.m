classdef brownianTableClass < handle
    
    properties
        brownianTable;
        metadata;
        Nstates = 2;
    end
    
    properties(GetAccess='private')
        hmmTable;
    end
    
    properties(GetAccess='private',Constant)
        varTypes = repmat({'double'},1,7);
        varNames = {'trackIdx','segIdx','hmmSegIdx','hmmSegStart','abs_hmmSegStart','hmm_xSeg','hmm_ySeg'};
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%
        % CONSTRUCTOR FXN   %
        %%%%%%%%%%%%%%%%%%%%%
        
        function obj = brownianTableClass(varargin)
            
            if strcmp( class(varargin{1}),'double')
                obj.metadata.obj_idx = varargin{1};
                obj.metadata.fileStruct = {};
                obj.metadata.Type = 'tracks';
                obj.metadata.DiffCoeff = [NaN, NaN];
                obj.metadata.Comments = 'Empty tracks';
                if strcmp( class(varargin{2}), 'char' ); obj.metadata.Comments = varargin{2}; end
                for i = 1:obj.Nstates; obj.brownianTable.(sprintf('State%i',i)) = table('Size',[0 numel(obj.varNames)],'VariableTypes',obj.varTypes,'VariableNames',obj.varNames); end
                return
            end
            
            if strcmp(class(varargin{1}),'segsTableClass'); segsTableObj = varargin{1};
            obj_idx = varargin{2}; end
            
            % Create default metadata
            obj.metadata = segsTableObj.metadata;
            obj.metadata.Type = 'brownian';
            obj.metadata.obj_idx = obj_idx;
            
            % Create a function to calculate for the diffusion coefficients
            calculate_Diff_Coeff = @(results_,state) sqrt( -2 * results_.cfg.locerror^2 + results_.results.ML_params.sigma_emit(state)^2)^2 * results_.cfg.fs / 2 * results_.cfg.umperpx^2;
            
            if eq(nargin,3); options = varargin{3}; end
            
            obj.metadata.fileStruct = segsTableObj.metadata.fileStruct;
            obj.metadata.DiffCoeff = [NaN, NaN];
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%% HMM DATA PARSED HERE %%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % Locate the Segmentation file in the Files cell
                HMMFile = segsTableObj.metadata.fileStruct.address_analysis_output;
                if isempty( whos('-file',HMMFile,'results') ); obj.metadata.Comments = sprintf('Tracking file does not contain results variable'); return; 
                else; results_ = load(HMMFile); end
                fprintf('Loaded HMM file\n');
                
                % The type of segments fed into HMM Bayes must satisfy
                % these two criteria: 
                diffusingSegIDs = find( not( segsTableObj.segsTable.nan) & ...% (1) HAVE NO NANS and 
                    segsTableObj.segsTable.segType==2);                      % (2) BE TYPE 2
                
                % obj.hmmTable is created with the same length as
                % diffusingSegIDs (hmmTable is not an output of the
                % constructor function, rather, it is a table with the size
                % of the number of Brownian segments that can be analyzed)
                %
                % Each of these segments can be indexed back to a segsTable
                % class segIdx. The subSeg variable is a dummy variable
                % here and is not useful unless working within the
                % scope of this function itself.
                
                obj.hmmTable = segsTableObj.segsTable(diffusingSegIDs,:);
                obj.hmmTable.hmmIdx = [1:size(obj.hmmTable,1)]'; % Create an index for all of the hmm segments
                
                % Check that the number of ML_states (tracks that were
                % analyzed with HMM bayes) is the same as the number of
                % tracks meeting the criteria above
                if eq( numel(results_.results.ML_states), numel(diffusingSegIDs) )
                
                    % Parse states
                                
                    conv2str = @(x) num2str(x,'%i');
                    ML_states = cellfun(conv2str, results_.results.ML_states, 'UniformOutput', false);
                    Nstates=obj.Nstates;
                    tmp_struct = struct();
                    Diff_Coeff = [];
                    
                    rf_x = @(hmmSegStart,hmmSegEnd,segIdx) { obj.hmmTable( segIdx,: ).xSeg{1}(hmmSegStart:hmmSegEnd) };
                    rf_y = @(hmmSegStart,hmmSegEnd,segIdx) { obj.hmmTable( segIdx,: ).ySeg{1}(hmmSegStart:hmmSegEnd) };
                    
                    for i = 1:Nstates
                        Diff_Coeff(i) = calculate_Diff_Coeff( results_, i );
                        mytable = obj.parseStates(ML_states,i); % Send in the ML states to be parsed
                        mytable = [ mytable, rowfun(rf_x, mytable(:,[2,3,4]),'OutputVariableNames','hmm_xSeg'), rowfun(rf_y, mytable(:,[2,3,4]),'OutputVariableNames','hmm_ySeg') ];
                        [mytable.abs_hmmSegStart,mytable.abs_hmmSegEnd,mytable.segIdx,mytable.trackIdx] = deal( ...
                                                                                                            mytable.hmmSegStart + obj.hmmTable( mytable.subSegIdx,:).abs_segStart,...
                                                                                                            mytable.hmmSegEnd + obj.hmmTable( mytable.subSegIdx,:).abs_segStart,...
                                                                                                            obj.hmmTable.segIdx( mytable.subSegIdx ),...
                                                                                                            obj.hmmTable.trackIdx( mytable.subSegIdx));
                        mytable = mytable(:,{'trackIdx','segIdx','hmmSegIdx','hmmSegStart','abs_hmmSegStart','hmm_xSeg','hmm_ySeg'});
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % This part is for associating the segments with %
                        % the number of segments in their parent track   %
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        tracks = mytable.trackIdx;
                        tracks_histogram = table( unique(tracks), histc( tracks, unique(tracks) ) , 'VariableNames', {'trackIdx','NumSegs'} );

                        tracksInSeg = zeros( size(mytable,1), 1 );

                        for j = unique(tracks_histogram.NumSegs)'
                            theseSegs = tracks_histogram.trackIdx( ismember( tracks_histogram.NumSegs, j ) ); 
                            tracksInSeg( find(ismember( mytable.trackIdx, theseSegs ) == 1) ) = j;
                        end

                        mytable.tracksInSeg = tracksInSeg;
                        tmp_struct.(sprintf('State%i',i)) = mytable;
                        
                    end
                    
                    obj.brownianTable = tmp_struct;
                    obj.metadata = segsTableObj.metadata;
                    obj.metadata.DiffCoeff = Diff_Coeff
                    obj.metadata
                    fprintf('Success\n');
                    
                else
                    
                    obj.metadata.Comments = sprintf('Error in the loop creating the table');
                    fprintf('\nWarning! The number of tracks from the HMM Bayes output did NOT match the number of tracks extracted from U-Track and DC-MSS segmentation\nCheck file %s\n',obj.metadata.fileStruct.address_analysis_output);
                    return;
                    
                end
                
           obj.metadata.Type = 'brownian';
           obj.metadata.fileStruct = segsTableObj.metadata.fileStruct;
           
        end
                
        %%%%%%%%%%%%%%%%%%%%%%%
        % END CONSTRUCTOR FXN %
        %%%%%%%%%%%%%%%%%%%%%%%
        
        function lifetimes = lifetimes(obj,state)
           lifetimes = cellfun( @numel, obj.brownianTable.(sprintf('%s',state)).hmm_xSeg );
        end
        
        
    end
    
    methods(Static)

        function output = parseStates(ML_states, Nstate)
            % Search tokens of repeating N's within ML_states which has
            % data like '11111' '1112222111' '222111' (or '11222333')
            % Find the start and end of each match and produce a table into
            % varargout
            fprintf('Parsing state %i\n',Nstate);

            % Find the starts and ends of sequences within a cell
            % containing 1111111122221111111 etc...
            startFxn = @(x) [ regexp( x, sprintf('[%i]{1,}',Nstate), 'start' ); regexp( x, sprintf('[%i]{1,}',Nstate), 'end' ) ];
            output = cellfun(startFxn, ML_states, 'UniformOutput', false);
            
            % For a sequence containing NONE of the state being sought,
            % fill it in with zeros
            output( cellfun(@isempty, output) ) = {zeros(2,1)};
            
            % Each cell has 2 rows x # of sequences in a given state
            % So the number of columns denotes the number of subsequences
            % in the state being sought
            addIdx = @(x) [ [1:size(x,2)]; x ]; % This will index each column, even columns with zeros
            output = cellfun(addIdx, output, 'UniformOutput', false);
            
            output = cell2mat(output);
            output = reshape( output', numel(output)/3, 3 );
            output( find(output(:,1)==1), 4 ) = [1 : numel( find(output(:,1)==1) ) ]';
            zeros_=find(output(:,4)==0); nonzeros_=find(output(:,4)~=0);
            %output(end+1,:) = [1,1,1,1];
            output(zeros_,4) = interp1( nonzeros_, output( nonzeros_, 4 ), zeros_, 'previous','extrap');
            output = output( output(:,2)>0, : ); % Remove zero-valued rows (where a given segment returned no states of this value of Nstate)
            output = array2table(output,'VariableNames',{'hmmSegIdx','hmmSegStart','hmmSegEnd','subSegIdx'});
            
        end
        
    end
    
end

