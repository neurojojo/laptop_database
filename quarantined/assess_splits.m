function close_partners = assess_splits( input, t_delta, d_delta )
    
    % Input is a tracksTable
    
    end_positions = table2array( rowfun( @(x,y) [x{1}(end),y{1}(end)] , input(:,{'x','y'})) );
    start_positions = table2array( rowfun( @(x,y) [x{1}(1),y{1}(1)] , input(:,{'x','y'}) ) );
    time_appearance =  table2array( rowfun( @(t) [t] , input(:,{'trackStart'}) ) );

    distmatrix = pdist2( end_positions, start_positions ) + tril( nan( size(start_positions,1), size(start_positions,1) ) );
    timematrix = pdist2( [time_appearance,zeros( numel(time_appearance), 1 )], [time_appearance,zeros( numel(time_appearance), 1 )] );

    close_partners = arrayfun( @(x) intersect( find( timematrix(x,:) < t_delta ), find( distmatrix(x,:) < d_delta ) ), [1:size(timematrix,1)]' , 'UniformOutput', false);

    fprintf('Number of nearby appearances: %i out of %i tracks are within %i frames and %i pixels\n',...
        numel( find( cellfun( @(x) numel(x), close_partners ) >= 1 ) ), size( timematrix, 1 ),...
        t_delta,...
        d_delta);
    
    close_partners = table( find( cellfun( @(x) numel(x), close_partners ) >= 1 ), close_partners(find( cellfun( @(x) numel(x), close_partners ) >= 1 )) );
    
    
end