cd('C:\MATLAB\laptop_database\laptop_database')
addpath('C:\MATLAB\laptop_database\laptop_database')

%% Loading data (findFoldersClass)

options.TLD = 'Z:/#BackupMicData';
options.search_folder = '_SM';
options.search_subfolder = 'analysis_output.mat';
options.optional_args = {'FilesToFind','signe','DC1>DC2'};
tic; signeFolders = findFoldersClass(options); toc;
% Takes about one minute

%%

tic; signeFolders.makeTrackObjs; toc; % About 1 min
tic; signeFolders.makeSegObjs; toc; % About 90 s (just took 300)
% If clearing hmmsegs is necessary:
signeFolders.hmmsegs = struct();
tic; signeFolders.makeHMMSegObjs; toc; % About 160 s %

%%
tic; signeFolders.switchHMMstates; toc;

tic; signeFolders.patchTracks; toc; % Computes the total number of tracks in a segment (currently only for two state models)
signeFolders.assignNames();
% About 2 minutes per gigabyte

tic; signeFolders.saveTables(); toc;
%% Restart rc_obj from here

tic; rc_obj = resultsClusterClass( signeFolders ); toc; % 10 s

%% Handling text
rc_obj.computeClusters( signeFolders );

replacement_table = readtable( 'replacement_table.csv' );
removeMultipleSpaces = @(x) regexprep(x,'(\s){1,}$','');
replacement_table_cell = cellfun( removeMultipleSpaces, replacement_table.Replacement,'UniformOutput',false);

rc_obj.clustersTable.Shortname = replacement_table_cell;

%% Pooling
myjoin = join(rc_obj.subfoldersTable, rc_obj.clustersTable, 'key', 'Supercluster');

[unique_labels,idx_labels,newSuperclusters] = unique( myjoin.Shortname );

newSuperclustersTable = table( unique(newSuperclusters), unique_labels );
newSuperclustersTable.Properties.VariableNames = {'Supercluster','Clustertext'};

rc_obj.clustersTable = sortrows( newSuperclustersTable, 'Supercluster' );
rc_obj.subfoldersTable.Supercluster = newSuperclusters;

%%
rc_obj.getConsolidatedLifetimes( signeFolders );

rc_obj.computeSegInfo();

rc_obj.makeDiffusionTable( signeFolders );

%% DC1 versus DC2
figdetails = 'DC1_v_DC2'
Quantity1 = 'DC1';
Quantity2 = 'DC2';
xlims = [0, 1];
ylims = [0, 1];

mytable = rc_obj.diffusionTableNaNs;
get_supercluster_stats = @( supercluster, quantity ) table( supercluster,...
           sum( mytable.Supercluster == supercluster ),...
           prctile( mytable( mytable.Supercluster == supercluster , : ).(quantity), 25 ),...
           prctile( mytable( mytable.Supercluster == supercluster , : ).(quantity), 50 ),...
           prctile( mytable( mytable.Supercluster == supercluster , : ).(quantity), 75 ),...
           mean( mytable( mytable.Supercluster == supercluster , : ).(quantity) ), ...
           std( mytable( mytable.Supercluster == supercluster , : ).(quantity) ),...
       'VariableNames',{'Supercluster','Nentries','Prc25','Med','Prc75','mu','sigma'} );

variableNames = {'Supercluster','Nentries','Prc25','Med','Prc75','mu','sigma'};

close all
f=figure('color','w'); ax_ = axes('parent',f,'tickdir','out','xlim',[0,0.7],'ylim',[0,0.2]); 

%Superclusters = [11,12,13,14]';

[Superclusters,figname] = multipleRegex( rc_obj.clustersTable.Clustertext, 'not gamma', 'not alfa', 'not ins4a', 'not Gs', 'not Lacro' );
% NEW STEP %
Superclusters = rc_obj.clustersTable.Supercluster(Superclusters);

mycluster_colors = Superclusters;

OrganizeTable = table( Superclusters,...
    repmat( Quantity1, numel(Superclusters), 1 ));
dc1_output = rowfun( get_supercluster_stats, OrganizeTable );
dc1_output = array2table( table2array( dc1_output.Var1), 'VariableNames', variableNames );

OrganizeTable = table( Superclusters,...
    repmat( Quantity2, numel(Superclusters), 1 ));
oc1_output = rowfun( get_supercluster_stats, OrganizeTable );
oc1_output = array2table( table2array( oc1_output.Var1), 'VariableNames', variableNames );

crossTable = join( dc1_output(:,[1,3,4,5]),  oc1_output(:,[3,4,5,1]) , 'key', {'Supercluster'});
crossTable.color = [1:size(crossTable,1)]';
crossTable.maxColor = repmat( size(crossTable,1), size(crossTable,1), 1);
crossTable.ax = repmat( ax_, size(crossTable,1), 1);

crossTable.legend = rc_obj.clustersTable( find( ismember( rc_obj.clustersTable.Supercluster, crossTable.Supercluster ) == 1 ), : ).Clustertext;
combineMed = @(name,med1,med2) {sprintf('%s (x=%1.2f y=%1.2f)',name{1},med1,med2)}; newlegend = rowfun( combineMed, crossTable(:,[end,3,6]) );
crossTable.legend = newlegend.Var1;

crossTable = sortrows(crossTable, 'legend' );
crossTable.color = [1:size(crossTable,1)]';
rowfun( @crossObj, crossTable );
set(gca,'Xlim',xlims,'YLim',ylims);

xlabel(sprintf('%s',Quantity1))
ylabel(sprintf('%s',Quantity2))
set(gcf,'WindowState','maximized')
pause(0.5);
textToTop(gca);

figname = regexprep(figname,'\(|\)|(\|)','_');
print( gcf, sprintf('figure_%s_%s_%s_%s_%s.png',figdetails,Quantity1,Quantity2,figname,removeflag), '-dpng', '-r0' )


%% Lifetime plots

remove_ends = 1;
Quantity1 = 'Lifetime1';
Quantity2 = 'Lifetime2';
figdetails = 'Lifetime_xy_';
xlims = [0, 70];
ylims = [0, 70];

if remove_ends; rc_obj.consolidateSuperclusterLifetimes('remove_ends',3); removeflag='removed'; else; rc_obj.consolidateSuperclusterLifetimes(); removeflag=''; end;

close all
f=figure('color','w'); ax_ = axes('parent',f,'tickdir','out','xlim',[0,0.7],'ylim',[0,0.2]); 

variableNames = {'Supercluster','Nentries','Prc25','Med','Prc75','mu','sigma','N'};

[Superclusters,figname] = multipleRegex( rc_obj.clustersTable.Clustertext, 'not gamma', 'not alfa', 'not ins4a', 'not Gs', 'not Lacro' );
% NEW STEP %
Superclusters = rc_obj.clustersTable.Supercluster(Superclusters);

mycluster_colors = Superclusters;

OrganizeTable = table( Superclusters,...
    repmat( Quantity1, numel(Superclusters), 1 ));

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

OrganizeTable = table( Superclusters,...
    repmat( Quantity2, numel(Superclusters), 1 ));

oc1_output = rowfun( get_supercluster_stats, OrganizeTable );
oc1_output = array2table( table2array( oc1_output.Var1), 'VariableNames', variableNames );

crossTable = join( dc1_output(:,[1,3,4,5]),  oc1_output(:,[3,4,5,1]) , 'key', {'Supercluster'});
crossTable.color = [1:size(crossTable,1)]';
crossTable.maxColor = repmat( size(crossTable,1), size(crossTable,1), 1);
crossTable.ax = repmat( ax_, size(crossTable,1), 1);

crossTable.legend = rc_obj.clustersTable( find( ismember( rc_obj.clustersTable.Supercluster, crossTable.Supercluster ) == 1 ), : ).Clustertext;
combineMed = @(name,med1,med2) {sprintf('%s (x=%1.2f y=%1.2f)',name{1},med1,med2)}; newlegend = rowfun( combineMed, crossTable(:,[end,3,6]) );
crossTable.legend = newlegend.Var1;

crossTable = sortrows(crossTable, 'legend' );
crossTable.color = [1:size(crossTable,1)]';
rowfun( @crossObj, crossTable );

xlabel(sprintf('%s',Quantity1))
ylabel(sprintf('%s',Quantity2))

set(gca,'Xlim',xlims,'YLim',ylims);
set(gcf,'WindowState','maximized')
pause(0.5);

mymove = [0,0,0]
moveright = @(x) set(x,'Position',get(x,'Position')+mymove); rowfun(moveright, table( findobj(gca,'Type','text')), 'outputformat','cell' );

textToTop(gca);

figname = regexprep(figname,'\(|\)|(\|)','_');
print( gcf, sprintf('figure_%s_%s_%s.png',figdetails,figname,removeflag), '-dpng', '-r0' )
