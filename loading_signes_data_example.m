cd('C:\MATLAB\databaseClasses')
addpath('C:\MATLAB\databaseClasses')

%% Loading data (findFoldersClass)

options.TLD = 'Z:/#BackupMicData';
options.search_folder = '_SM';
options.search_subfolder = 'analysis_output.mat';
options.optional_args = {'FilesToFind','signe','DC1>DC2'};
tic; signeFolders = findFoldersClass(options); toc;
% Takes about one minute

%%

tic; signeFolders.makeTrackObjs; toc;
tic; signeFolders.makeSegObjs; toc;
% If clearing hmmsegs is necessary:
signeFolders.hmmsegs = struct();

tic; signeFolders.makeHMMSegObjs; toc;
tic; signeFolders.switchHMMstates; toc;
tic; signeFolders.patchTracks; toc; % Computes the total number of tracks in a segment (currently only for two state models)
signeFolders.assignNames();
% About 2 minutes per gigabyte
%% Clear out Brownian Tables that aren't good

objects_to_clear = readtable('objects_to_clear.csv');
clearfxn = @(x,y) signeFolders.clearTables( x, y{1} );
rowfun( clearfxn, objects_to_clear, 'NumOutputs', 0 )
%% Restart rc_obj from here

tic; rc_obj = resultsClusterClass( signeFolders ); toc;

%rc_obj.newgroup([46,47])
%rc_obj.newgroup([34,35,36])
%rc_obj.newgroup([44,45])
%rc_obj.integrityCheck();

%
%% Handling text
rc_obj.computeClusters( signeFolders );
writetable( rc_obj.subfoldersTable, 'nov21_rc_subfolderstable.csv' )

%replacement_table = readtable( 'replacement_table.csv' );
%removeMultipleSpaces = @(x) regexprep(x,'(\s){1,}$','');
%replacement_table_cell = cellfun( removeMultipleSpaces, replacement_table.Replacement,'UniformOutput',false);

rc_obj.subfoldersTable = readtable( 'nov21_rc_subfolderstable_10am.csv' );

%% Pooling

[unique_labels,idx_labels,newSuperclusters] = unique( rc_obj.subfoldersTable.Shortname );

newSuperclustersTable = table( unique(newSuperclusters), unique_labels );
newSuperclustersTable.Properties.VariableNames = {'Supercluster','Clustertext'};

rc_obj.clustersTable = sortrows( newSuperclustersTable, 'Supercluster' );
rc_obj.subfoldersTable.Supercluster = newSuperclusters;
%%
writetable( rc_obj.subfoldersTable, 'nov21_rc_subfolderstable_after_mat_import.csv' )

%%

rc_obj.getConsolidatedLifetimes( signeFolders );
rc_obj.computeSegInfo();

%%
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

[Superclusters,figname] = multipleRegex( rc_obj.clustersTable.Clustertext, 'D2', 'not gamma', 'not alfa', 'not ins4a', 'not Gs', 'not Lacro' );
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
print( gcf, sprintf('figure_%s_%s_%s_%s_%s.png',figdetails,Quantity1,Quantity2,figname), '-dpng', '-r0' )

%% Lifetime plots

remove_ends = 1;
Quantity1 = 'Lifetime1';
Quantity2 = 'Lifetime2';
figdetails = 'Lifetime_xy_';
newfig = 0;
sorting = []; colors = 'tans'; query = {'Gi1 D2 ins4a','Sulpiride'};

% Possible queries
% sorting = [3,1,2]; colors = 'blues'; query = {'Gi1 D2 ins4a','not quinpirole','not sulpiride'}; %'Gi1 D2 ins4A Quinpirole'
% 
% sorting = [3,1,2]; colors = 'reds'; query = {'Gi1 D2 ins4a', 'quinpirole'}; %'Gi1 D2 ins4A Quinpirole'
%
% sorting = []; colors = 'tans'; query = {'Gi1 D2 ins4a','Sulpiride'};
[Superclusters,figname] = multipleRegex( rc_obj.clustersTable.Clustertext, query );

plot_rc_obj( rc_obj, remove_ends, Quantity1, Quantity2, figdetails, xlims, ylims, sorting, colors, query, newfig )
%% Figure 1
close all;

sorting = [3,1,2]; colors = 'blues'; query = {'Gi1 D2 ins4a','not quinpirole','not sulpiride'}; %'Gi1 D2 ins4A Quinpirole'
plot_rc_obj( rc_obj, remove_ends, Quantity1, Quantity2, figdetails, xlims, ylims, sorting, colors, query, newfig )

sorting = [3,1,2]; colors = 'reds'; query = {'Gi1 D2 ins4a', 'quinpirole'}; %'Gi1 D2 ins4A Quinpirole'
plot_rc_obj( rc_obj, remove_ends, Quantity1, Quantity2, figdetails, xlims, ylims, sorting, colors, query, newfig )

sorting = []; colors = 'tans'; query = {'Gi1 D2 ins4a','Sulpiride'};
plot_rc_obj( rc_obj, remove_ends, Quantity1, Quantity2, figdetails, xlims, ylims, sorting, colors, query, newfig )

xlim([0,40]); ylim([0,80]);
textToTop(gca);

%% Figure 2
close all;
sorting = []; colors = 'blues'; query = {'2400 ng'};
plot_rc_obj( rc_obj, remove_ends, Quantity1, Quantity2, figdetails, xlims, ylims, sorting, colors, query, newfig )

sorting = []; colors = 'reds'; query = {'Gi','not D2','not Lat'};
plot_rc_obj( rc_obj, remove_ends, Quantity1, Quantity2, figdetails, xlims, ylims, sorting, colors, query, newfig )


%% Figure 3
close all;
sorting = []; colors = 'blues'; query = {'D2','1200 ng', 'no treat', 'not PTXR'};
plot_rc_obj( rc_obj, remove_ends, Quantity1, Quantity2, figdetails, xlims, ylims, sorting, colors, query, newfig )

sorting = []; colors = 'reds'; query = {'PTXR','1200 ng', 'no treat'};
plot_rc_obj( rc_obj, remove_ends, Quantity1, Quantity2, figdetails, xlims, ylims, sorting, colors, query, newfig )

