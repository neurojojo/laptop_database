% Loading only '180222_MH' data
options.TLD = 'Z:/#BackupMicData';
options.search_folder = '180222_MH';
options.search_subfolder = 'results.mat';
options.optional_args = {'FilesToFind','default','DC1>DC2'};
tic; mikeFolders = findFoldersClass(options); toc;
mikeFolders.collectParameters();

%%
tic; mikeFolders.makeTrackObjs; toc;
tic; mikeFolders.makeSegObjs; toc;
%%
mikeFolders.computeRelativeSegIdx();
mikeFolders.assignNames();

tic; rc_obj = resultsClusterClass( mikeFolders ); toc;
rc_obj.computeClusters( mikeFolders );
%%

[unique_labels,idx_labels,newSuperclusters] = unique( rc_obj.subfoldersTable.Shortname );
newSuperclustersTable = table( unique(newSuperclusters), unique_labels );
newSuperclustersTable.Properties.VariableNames = {'Supercluster','Clustertext'};

rc_obj.clustersTable = sortrows( newSuperclustersTable, 'Supercluster' );
rc_obj.subfoldersTable.Supercluster = newSuperclusters;
writetable( rc_obj.subfoldersTable, 'mh_dec18_rc_subfolderstable_after_mat_import.csv' )

%% Rename certain clusters
rc_obj.subfoldersTable.Shortname( strcmp( rc_obj.subfoldersTable.Shortname, 'MH Gi1 1000ng Tet 250 pM Cy3AC' )  ) = {'Control'};

rc_obj.subfoldersTable.Shortname( strcmp( rc_obj.subfoldersTable.Shortname, 'MH Gi1 1000ng Tet 250 pM Cy3AC,10uM Morphine' )  ) = {'Morphine'};
rc_obj.subfoldersTable.Shortname( strcmp( rc_obj.subfoldersTable.Shortname, 'MH Gi1 1000ng Tet 250 pM Cy3AC,1uM DAMGO' ) ) = {'DAMGO'};


%% Break each track up into its segments
%  Compute the mean lifetime of each segment 

accumulator_table = struct();

get_mean_seg_length = @(y) mean( cellfun(@(x) numel(x), y.xSeg) ); % Takes a segsTable as an input
get_var_seg_length = @(y) std( cellfun(@(x) numel(x), y.xSeg) ); % Takes a segsTable as an input

for objectnames = fields( mikeFolders.segs )'
    
    tmp = mikeFolders.segs.( sprintf('%s',objectnames{1}) ).segsTable;
    tmp.segType_letters = repmat(' ', numel(tmp.segType), 1);
    tmp.segType_letters( tmp.segType== 0 ) = 'I';
    tmp.segType_letters( tmp.segType== 1 ) = 'C';
    tmp.segType_letters( tmp.segType== 2 ) = 'D';
    tmp.segType_letters( tmp.segType== 3 ) = 'V';
    tmp.segType_letters( isnan(tmp.segType) == 1 ) = 'N';
    
    mytables_identity = arrayfun( @(x) tmp( tmp.trackIdx == x,:).segType_letters', unique( tmp.trackIdx ), 'UniformOutput', false );
    mytables_duration = arrayfun( @(x) get_mean_seg_length( tmp(tmp.trackIdx == x,:) ), unique( tmp.trackIdx ), 'UniformOutput', true );
    mytables_std = arrayfun( @(x) get_var_seg_length( tmp(tmp.trackIdx == x,:) ), unique( tmp.trackIdx ), 'UniformOutput', true );

    out = mytables_identity;
    % Use a for loop to create a structure (for now)
    [frequency,labels] = hist(categorical(out));
    
    accumulator_tables.(objectnames{1}).dictionaryTable = table( labels, frequency, 'VariableNames', {'States','Count'} );
    accumulator_tables.(objectnames{1}).segmentsTable = table( mytables_identity,mytables_duration,mytables_std, 'VariableNames', {'States','MeanDuration','sdDuration'} );
    
end


%% For single tracks, this is the summary of all the results

get_singleTrackMeans = @(state) cellfun(@(y) accumulator_tables.(y).segmentsTable.MeanDuration( ... 
    find( strcmp(accumulator_tables.(y).segmentsTable.States,state) == 1 )...
    ), fields( accumulator_tables ), 'UniformOutput', false );

varnames = {'MeanImmobile','MeanConfined','MeanDiffusing','NumImmobile','NumConfined','NumDiffusing'};

singletrack_size_duration = table( cellfun( @(x) mean(x), get_singleTrackMeans('I'), 'UniformOutput', true ), ...
    cellfun( @(x) mean(x), get_singleTrackMeans('C'), 'UniformOutput', true ), ...
    cellfun( @(x) mean(x), get_singleTrackMeans('D'), 'UniformOutput', true ), ...
    cellfun( @(x) numel(x), get_singleTrackMeans('I'), 'UniformOutput', true ), ...
    cellfun( @(x) numel(x), get_singleTrackMeans('C'), 'UniformOutput', true ), ...
    cellfun( @(x) numel(x), get_singleTrackMeans('D'), 'UniformOutput', true ), ...
    'VariableNames',varnames );

singletrack_size_duration = [rc_obj.subfoldersTable.Shortname,singletrack_size_duration];
singletrack_size_duration.Properties.VariableNames{1}='Shortname';

[~,b,grouping] = unique( rc_obj.subfoldersTable.Shortname );
labels = rc_obj.subfoldersTable.Shortname(b);

myfigs = cellfun( @(x) figure('Tag',sprintf('%s',x),'Color','w'), varnames );
titles = cellfun(@(column) makeANOVAtitle( singletrack_size_duration.(column), grouping, column ), varnames, 'UniformOutput', false );

organization_table = table( myfigs',titles', varnames','VariableNames',{'Parent','Title','Column'} );

% Boxes need a figure as a parent
myboxes = rowfun(@(figure,title,column) boxplot( singletrack_size_duration.(column{1}), rc_obj.subfoldersTable.Shortname,...
    'Widths',.3,'Colors','k','Parent', figure ), organization_table, 'OutputFormat', 'cell' );

% Scatters need axes as a parent
myaxes = arrayfun( @(fig) get(fig,'Children'), myfigs );
% Set the axis properties
mytitles = rowfun( @(ax,title) set(ax, 'Title', text(0,0,title), 'FontSize', 18, 'box', 'off', 'TickDir', 'out', 'NextPlot', 'add'), table( myaxes', titles' ), 'OutputFormat', 'cell' );

organization_table.Parent = myaxes';
[~,~,scatterlbl] = unique(rc_obj.subfoldersTable.Shortname);
myscatters = rowfun(@(figure,title,column) scatter( scatterlbl, singletrack_size_duration.(column{1}), 'Parent', figure, ...
    'filled','jitter', 'on', 'jitteramount', 0.1, 'markerfacecolor', 'k', 'markeredgecolor', 'k' ),...
    organization_table);

a = rowfun( @(ax,title,column) set(ax,'YLabel', text(0,0,'Frames in a single segment') ), organization_table([1:3],:), 'OutputFormat', 'cell' );
a = rowfun( @(ax,title,column) set(ax,'YLabel', text(0,0,'Occurances') ), organization_table([4:6],:), 'OutputFormat', 'cell' );

arrayfun( @(figure) saveas( figure, sprintf('figure2_%s.svg', figure.Tag) ), myfigs );

%%

pullByState = @(state,Parameter) accumulator_tables.(objectnames{1}).segmentsTable( strcmp(accumulator_tables.(objectnames{1}).segmentsTable.States, state ), : ).(Parameter);

states = {'I','C','D'};
range = [0:10:200];

myhistograms = cellfun( @(x) histc( pullByState( x,'MeanDuration'), range) , states , 'UniformOutput' , false);
figure('color','w'); ax = axes('NextPlot','add','TickDir','out')
cellfun( @(x) plot( range', cumsum(x)/sum(sum(x)), 'linewidth', 4 ), myhistograms );
legend(states); grid on; xlabel('Segment length');

%% Compiling based on regular expression matches

output = [];
queries = {'(CD|ID)','Diffusion following confined or immobile';...
           '(D.*[C]$)','Diffusion ending in confined';...
           '(D.*[I]$)','Diffusion ending in immobile';...
           '(C.*[D]$)','Confined ending in diffusion';...
           '(I.*[D]$)','Immobile ending in diffusion';...
           '(\w[C]$)','Segment ending in confined';...
           '(\w[I]$)','Segment ending in immobile';...
           '(\w[D]$)','Segment ending in diffusion';...
           '^(I)$','Single segment immobile';...
           '^(C)$','Single segment confined';...
           '^(D)$','Single segment diffusing';...
           'I','Segment containing I';...
           'C','Segment containing C';...
           'D','Segment containing D';...
           '^(\w)$','Segments with one piece';...
           '\w{2,}','Segments with two or more pieces'};
queries_tbl = array2table( queries, 'VariableNames', {'Query','Descriptor'} );

sum_over_objects = {};
for i = 1:size( queries_tbl, 1 )
    matched_indices = cellfun( @(y) accumulator_tables.(y).dictionaryTable( find( rowfun(@(x) gt(numel( regexp(x{1}, queries_tbl(i,:).Query{1} ) ),0),...
        accumulator_tables.(y).dictionaryTable(:,1),'OutputFormat','uniform')==true), 2).Count,...
        fields( accumulator_tables ), 'UniformOutput', false );
    % Add them all up
    sum_over_objects{i} = cellfun( @(x) sum(x), matched_indices );
end

%% Pie charts


%% Changing clusternames

rc_obj.subfoldersTable.Shortname( arrayfun( @(x) strcmp('MH Gi1 1000ng Tet 250 pM Cy3AC', x{1}), rc_obj.subfoldersTable.Shortname) ) = {'Control'};
rc_obj.subfoldersTable.Shortname( arrayfun( @(x) strcmp('MH Gi1 1000ng Tet 250 pM Cy3AC,10uM Morphine', x{1}), rc_obj.subfoldersTable.Shortname) ) = {'Morphine'};
rc_obj.subfoldersTable.Shortname( arrayfun( @(x) strcmp('MH Gi1 1000ng Tet 250 pM Cy3AC,1uM DAMGO', x{1}), rc_obj.subfoldersTable.Shortname) ) = {'DAMGO'};


%% Figure 1
mytitle = 'Percentage of segments ending in free diffusion';
mydata = rdivide( output_tbl.ending_d, vsum(output_tbl.ending_d, output_tbl.ending_c, output_tbl.ending_i) );

figure('color','w');
boxplot( mydata, rc_obj.subfoldersTable.Shortname ); box off; hold on;
[~,~,scatterlbl] = unique(rc_obj.subfoldersTable.Shortname);
scatter( scatterlbl,...
    mydata,...
    'filled','jitter', 'on', 'jitteramount', 0.1 ); box off;
set(gca,'TickDir','out'); 
title(sprintf('%s',mytitle))
ylim([0,1])

%% Figure 1 b

%% Figure 1
mytitle = 'Percentage of segments with diffusion after confinement';
mydata = rdivide( output_tbl.d_after_c );

figure('color','w');
boxplot( mydata, rc_obj.subfoldersTable.Shortname ); box off; hold on;
[~,~,scatterlbl] = unique(rc_obj.subfoldersTable.Shortname);
scatter( scatterlbl,...
    mydata,...
    'filled','jitter', 'on', 'jitteramount', 0.1 ); box off;
set(gca,'TickDir','out'); 
title(sprintf('%s',mytitle))
ylim([0,1])



%% Figure 2 
mytitle = 'Ratio of segments ending in free diffusion\nto segments ending in confined or immobile';
mydata = rdivide( output_tbl.ending_d, vsum(output_tbl.ending_d, output_tbl.ending_c, output_tbl.ending_i) );

figure('color','w');
mydata = output(:,1)./output(:,2);
boxplot( mydata, rc_obj.subfoldersTable.Shortname ); box off;
[~,~,scatterlbl] = unique(rc_obj.subfoldersTable.Shortname); hold on;
scatter( scatterlbl,mydata, 'filled','jitter', 'on', 'jitteramount', 0.1 ); box off;
set(gca,'TickDir','out'); 
title(sprintf('Ratio of diffusing segments that exit confined or immobile\nto diffusing segments ending in confined or immobile'))
ylim([0,2])

% output is: d_after_c,d_end_c,c_end_d,ending_c,ending_d

figure('color','w');
mydata = output(:,1)./output(:,2);
boxplot( mydata , rc_obj.subfoldersTable.Shortname ); box off;
[~,~,scatterlbl] = unique(rc_obj.subfoldersTable.Shortname); hold on;
scatter( scatterlbl,mydata, 'filled','jitter', 'on', 'jitteramount', 0.1 ); box off;
set(gca,'TickDir','out'); 
title(sprintf('Ratio of diffusing segments that exit confined or immobile\n to diffusing segments that end in confined or immobile'))
%ylim([0,2])

%% For each object, calculate occupancy of the different states
seglength_output = [];

for myobj = fields( mikeFolders.segs )'

    find( arrayfun( @(x) strcmp(x,'I'), mikeFolders.segs.(sprintf('%s',myobj{1})).segsTable.segType ) == 1 )
    diffsegs = arrayfun( @(x) mikeFolders.segs.(sprintf('%s',myobj{1})).segsTable( mikeFolders.segs.(sprintf('%s',myobj{1})).segsTable.segType == x, : ), [0,1,2,3], 'UniformOutput', false );
    seglengths = arrayfun( @(y) cellfun( @(x) numel(x), diffsegs{y}.xSeg ), [1:4], 'UniformOutput', false );
    seglength_output = [ seglength_output; cellfun( @(x) sum(x), seglengths ) ];

end

occupancy = seglength_output./sum(seglength_output,2);

state = {'Immobile','Confined','Diffusing','Superdiffusing'};
myboxplot = struct();

mypalettes = {'blues','reds','greens','grays'};
close all
figure('color','w'); 
for i = 1:3
    
    colors = palette(mypalettes{i});
    mydata = occupancy(:,i);
    subplot(1,3,i);
    myboxplot = boxplot( mydata , rc_obj.subfoldersTable.Shortname ); box off;
    set(gca,'TickDir','out','NextPlot','add'); 
    title(sprintf('Occupancy (%s)',state{i}));
    boxes = findobj(gca,'Tag','Box');
    box_coords = arrayfun(@(x) [x.XData',x.YData'], boxes , 'UniformOutput', false);
    
    % Patches over the boxes
    cellfun(@(x) patch( x(:,1), x(:,2), colors(1,:) ), box_coords )
    % Capture and redraw the lines
    lines = findobj(gca,'Type','Line');
    line_coords = arrayfun(@(x) [x.XData',x.YData'], lines , 'UniformOutput', false);
    cellfun(@(x) plot( x(:,1), x(:,2), 'k-'), line_coords );
    delete(myboxplot)
    
    [~,~,scatterlbl] = unique(rc_obj.subfoldersTable.Shortname); hold on;
    scatter( scatterlbl,mydata, 'filled','jitter', 'on', 'jitteramount', 0.1, 'markerfacecolor', 'w', 'markeredgecolor', 'k' ); box off;
    ylim([0,1]);
    
end

set(gcf,'Units','normalized')
set(gcf,'position',[14,42,76,47]/100)

%% Relationship between I,C,D,SD
lines = palette('lines');

figure('color','w');
ax = axes('tickdir','out','nextplot','add','xlim',[0,.6],'ylim',[0,.6]);
arrayfun( @(x) plot( occupancy( ismember(rc_obj.subfoldersTable.Supercluster,x) ,1),...
        occupancy( ismember(rc_obj.subfoldersTable.Supercluster,x) ,2) , 'ko', 'markersize', 8, 'markerfacecolor', lines(x,:) ), ...
        [1:3] );
plot([0,0.6],[0,0.6],'k--');
xlabel('Immobile Occupancy'); ylabel('Confined Occupancy');
