classdef searchObj
    % Creating a search object
    
    properties
        hits
    end
    
    methods
        function obj = searchObj(resultsClassObj, query, varargin)
            
            if strcmp(varargin{1}, 'sequenceByTrackIdx' )
                
                tosearch = structfun( @(x) x.sequenceByTrackIdx , resultsClassObj.sequencesTable, 'UniformOutput', false );

            end
            
            for objs = fields(tosearch)'
                
                %objs
                tmp = find( cellfun( @(x) numel(cell2mat(regexp( x, query ))), tosearch.(objs{1}).Sequence ) > 0 );
                obj.hits.(objs{1}) = tosearch.(objs{1}).trackIdx(tmp);
                
            end
            
            
        end        
    end
end

