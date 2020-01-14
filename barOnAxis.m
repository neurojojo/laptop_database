function barOnAxis( barHeights, ygain, y0, x0, w, colors, mytitle )

    %Defaults:
    %---------
    %ygain=25;
    %y0=65;
    %x0=50;
    %w=5;
    %colors = {'blues';'greens';'tans'};
    
    
    % Setting up colors
    mycolors = cell2mat( cellfun(@(x) palette(x), colors , 'UniformOutput', false) );
    mycolors = mycolors([1:numel(barHeights)],:);
    
    % Plotting bottom layer
    mytable = table( x0+[0:numel(barHeights)-1]'*w, ygain*ones(numel(barHeights),1), min( mycolors*1.1, 1) );
    rowfun( @(x,height,color) barObj( 'a', x, y0, w, height, gca, color ), mytable )
    
    % Plotting top layer
    mytable = table( x0+[0:numel(barHeights)-1]'*w, ygain*barHeights, mycolors );
    rowfun( @(x,height,color) barObj( 'a', x, y0, w, height, gca, color ), mytable )

    mytext = text( x0, y0+ygain, mytitle, 'VerticalAlignment', 'bottom', 'horizontalalignment','left' );
    myaxis = axisObj( x0, y0, ygain, 1, linspace(y0,y0+ygain,5)', num2str( linspace(0,1,5)' ) );

end