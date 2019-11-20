function [hits,figname] = multipleRegex( cellarray, varargin )

    hits = [1:numel(cellarray)]'; % All entries are hits before query
    figname = '';
    if numel(varargin)==0
        figname='all';
        return
    else
        for i = 1:numel( varargin )

            figname = [figname, ' ', varargin{i}];
            if regexpi( varargin{i}, 'not')
                removeflag = regexpi(varargin{i},'(?<=not\s).*','match');
                query = sprintf('^((?!%s).)*$', removeflag{1}); myre = @(x) numel( regexpi(x,query) ); 
            else
                query = sprintf('%s',varargin{i}); myre = @(x) numel( regexpi(x,query) ); 
            end

            hits = intersect( hits, find( cellfun( myre, cellarray ) > 0 ) );

        end

        figname = regexprep( figname, '\s', '_' );
    end
    
end

