function plot_rc_obj( rc_obj, ...
    remove_ends,...
    Quantity1,...
    Quantity2,...
    figdetails,...
    xlims,...
    ylims,...
    sorting,...
    colors,...
    query,...
    newfig)
    

    if remove_ends; rc_obj.consolidateSuperclusterLifetimes('remove_ends',3); removeflag='removed'; else; rc_obj.consolidateSuperclusterLifetimes(); removeflag=''; end;

    if or(newfig,isempty( findobj('Type','Figure') ))
        close all
        f=figure('color','w'); ax_ = axes('parent',f,'tickdir','out','xlim',[0,0.7],'ylim',[0,0.2]); 
    end

    ax_ = gca;
    variableNames = {'Supercluster','Nentries','Prc25','Med','Prc75','mu','sigma','N'};
    [Superclusters,figname] = multipleRegex( rc_obj.clustersTable.Clustertext, query );
    % NEW STEP %
    Superclusters = rc_obj.clustersTable.Supercluster(Superclusters);

    mycluster_colors = Superclusters;

    OrganizeTable = table( 'size',[numel(Superclusters),2],'VariableTypes',{'double','char'},'VariableNames',{'Supercluster','Clustertext'} );
    OrganizeTable.Supercluster = Superclusters;
    OrganizeTable.Clustertext = repmat( Quantity1, numel(Superclusters), 1 );

    % get_supercluster_stats defined for this table
    mytable = rc_obj.consolidatedLifetimes;
    get_supercluster_stats = @( supercluster, quantity ) table( supercluster,...
               sum( mytable.Supercluster == supercluster ),...
               prctile( mytable( mytable.Supercluster == supercluster , : ).(quantity), 25 ),...
               prctile( mytable( mytable.Supercluster == supercluster , : ).(quantity), 50 ),...
               prctile( mytable( mytable.Supercluster == supercluster , : ).(quantity), 75 ),...
               mean( mytable( mytable.Supercluster == supercluster , : ).(quantity) ), ...
               std( mytable( mytable.Supercluster == supercluster , : ).(quantity) ),...
               numel( mytable( mytable.Supercluster == supercluster , : ).(quantity) ),...
           'VariableNames',variableNames);
    dc1_output = rowfun( get_supercluster_stats, OrganizeTable );
    dc1_output = array2table( table2array( dc1_output.Var1), 'VariableNames', variableNames );
    % End of this quantity

    OrganizeTable = table( 'size',[numel(Superclusters),2],'VariableTypes',{'double','char'},'VariableNames',{'Supercluster','Clustertext'} );
    OrganizeTable.Supercluster = Superclusters;
    OrganizeTable.Clustertext = repmat( Quantity2, numel(Superclusters), 1 );

    oc1_output = rowfun( get_supercluster_stats, OrganizeTable );
    oc1_output = array2table( table2array( oc1_output.Var1), 'VariableNames', variableNames );

    crossTable = join( dc1_output(:,[1,3,4,5]),  oc1_output(:,[3,4,5,1]) , 'key', {'Supercluster'});
    crossTable.color = [1:size(crossTable,1)]';
    if sum(sorting)>0; crossTable.sorting = sorting'; else; crossTable.sorting = [1:size(crossTable,1)]'; end

    crossTable.ax = repmat( ax_, size(crossTable,1), 1);

    crossTable.legend = rc_obj.clustersTable( find( ismember( rc_obj.clustersTable.Supercluster, crossTable.Supercluster ) == 1 ), : ).Clustertext;

    combineMed = @(name,med1,med2) {sprintf('%s (x=%1.2f y=%1.2f)',name{1},med1,med2)}; newlegend = rowfun( combineMed, crossTable(:,[end,3,6]) );
    crossTable.legend = newlegend.Var1;

    if sum(sorting)>0; crossTable = sortrows(crossTable, 'sorting' ); end;
    % Color after sorting
    crossTable.color = [1:size(crossTable,1)]';
    crossTable.colors = repmat( colors, size(crossTable,1), 1);

    rowfun( @crossObj, crossTable );

    xlabel(sprintf('%s',Quantity1))
    ylabel(sprintf('%s',Quantity2))

    set(gca,'Xlim',xlims,'YLim',ylims);
    set(gcf,'WindowState','maximized')
    pause(0.5);

    textToTop(gca);

    figname = regexprep(figname,'\(|\)|(\|)','_');
    print( gcf, sprintf('figure_%s_%s_%s.png',figdetails,figname,removeflag), '-dpng', '-r0' )

    xlim([0,50])
    if remove_ends; title('Ends removed'); else; title('Ends kept'); end
    
end