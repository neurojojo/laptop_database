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

%% Restart rc_obj from here (12/9/2019)

%% Modifications to the folders object
signeFolders.computeRelativeSegIdx();

tic; rc_obj = resultsClusterClass( signeFolders ); toc;

%% Handling text
rc_obj.computeClusters( signeFolders );
writetable( rc_obj.subfoldersTable, 'nov21_rc_subfolderstable.csv' )
rc_obj.subfoldersTable = readtable( 'nov21_rc_subfolderstable_10am.csv' );

%% Pooling

[unique_labels,idx_labels,newSuperclusters] = unique( rc_obj.subfoldersTable.Shortname );
newSuperclustersTable = table( unique(newSuperclusters), unique_labels );
newSuperclustersTable.Properties.VariableNames = {'Supercluster','Clustertext'};

rc_obj.clustersTable = sortrows( newSuperclustersTable, 'Supercluster' );
rc_obj.subfoldersTable.Supercluster = newSuperclusters;
writetable( rc_obj.subfoldersTable, 'nov21_rc_subfolderstable_after_mat_import.csv' )

%%

rc_obj.getConsolidatedLifetimes( signeFolders );
rc_obj.computeSegInfo();
rc_obj.makeDiffusionTable( signeFolders );
rc_obj.consolidateSuperclusterLifetimes( signeFolders );
%% Going back and adding empty databases for objects


%% Make a table for parsing each track into all seg types

accumulator_table = struct();

for objectnames = fields( signeFolders.segs )'
    try

        if ~isempty( signeFolders.hmmsegs.(objectnames{1}).brownianTable )
            tmp = sortrows( outerjoin( signeFolders.segs.(objectnames{1}).segsTable(:,[1,2,5]),...
                [signeFolders.hmmsegs.(objectnames{1}).brownianTable.State1(:,[1,2,4,8]);signeFolders.hmmsegs.(objectnames{1}).brownianTable.State2(:,[1,2,4,8])],...
                'Keys', {'trackIdx','segIdx'} ), {'trackIdx_left','segIdx_left','hmmSegStart'} );
            
            % Initialize the column based on the output of DC-MSS
            tmp.segType_combined = tmp.segType_left; 
            % If DC-MSS returns a NaN value, set this value to -1
            tmp.segType_combined( isnan(tmp.segType_left) ) = -1;
            % If DC-MSS returns 2, but contains a NaN value in the x- or y-coordinates
            tmp.segType_combined( and(tmp.segType_left==2, isnan(tmp.trackIdx_right)) ) = -2; 
            % If the DC-MSS returns 2, does not contain a NaN value
            % imputes the segment type from the segType_right column
            tmp.segType_combined( and(tmp.segType_left==2, ~isnan(tmp.trackIdx_right)) ) = tmp.segType_right( and(tmp.segType_left==2, ~isnan(tmp.trackIdx_right)) );

            tmp.segType_letters = repmat({''}, size(tmp,1), 1);
            
            
            % There are two sources of error tracks
            % (1) Segment < 20 in length and gets categorized as NaN
            % (2) Segment x or y has NaN entries (due to gap closing)
            % We combine them into one here
            tmp( tmp.segType_combined==-2,:).segType_letters = repmat({'G'}, sum( tmp.segType_combined==-2 ), 1);
            tmp( tmp.segType_combined==-1,:).segType_letters = repmat({'N'}, sum( tmp.segType_combined==-1 ), 1);
            tmp( tmp.segType_combined==0,:).segType_letters = repmat({'I'}, sum(tmp.segType_combined==0), 1 );
            tmp( tmp.segType_combined==1,:).segType_letters = repmat({'C'}, sum(tmp.segType_combined==1), 1 );
            tmp( tmp.segType_combined==101,:).segType_letters = repmat({'F'}, sum(tmp.segType_combined==101), 1 );
            tmp( tmp.segType_combined==102,:).segType_letters = repmat({'S'}, sum(tmp.segType_combined==102), 1 );
            tmp( tmp.segType_combined==3,:).segType_letters = repmat({'V'}, sum(tmp.segType_combined==3), 1 );

            mytables = arrayfun( @(x) cellstr(cell2mat(tmp( tmp.trackIdx_left == x,:).segType_letters)'), unique( tmp.trackIdx_left ), 'UniformOutput', false );
            
            fprintf('%s %1.5f\n', objectnames{1}, 100*numel(find( cellfun( @(x) numel(x), cellfun( @(x) regexp( x{1}, 'II' ), mytables , 'UniformOutput', false))==1 )) / size(mytables,1))
            %bad_tracks = cellfun(@(x) or( strcmp(x{1},'E'), isempty(x{1}) ), mytables , 'UniformOutput', true);
            %out = arrayfun( @(x) mytables{x}, find(bad_tracks==0) );
        
            out = mytables;
            % Use a for loop to create a structure (for now)
            accumulator = struct();

            for i = 1:size(out,1)
                   if ~isfield( accumulator, out{i} )
                       accumulator.( sprintf('%s',out{i}{1}) ) = 1;
                   else
                       accumulator.( sprintf('%s',out{i}{1}) ) = accumulator.( sprintf('%s',out{i}{1}) )+1;
                   end
            end

            accumulator_tables.(objectnames{1}).dictionaryTable = table( fields( accumulator ), struct2array(accumulator)', 'VariableNames', {'States','Count'} );
        end
    catch
       fprintf('Failed for %s\n',objectnames{1}); 
    end
end

%%
cellfun(@(y) sum( cellfun( @(x) gt(numel(regexp(x{1},y)),0), mytables ) ), {'E','IC','IF','IS','CI','CF','CS','FI','FC','FS','SI','SC','SF'} )


%% End of rc_obj loading

%% If an HMM segment has a length of 1, what type of segment is it?
% Single tracks are twice as likely to be in State 1 (fast state)

% Logical for only 1 track in seg
only1track = eq(rc_obj.lifetimesTable.tracksInSeg,1);
instate1 = eq(rc_obj.lifetimesTable.State,1);
piedata = histc( rc_obj.lifetimesTable( only1track, : ).State, [1:2] );
mypietable = table( {'State','State'}', [1:2]', piedata/sum(piedata) );
mylegend = rowfun(@(x,y,z) sprintf('%s %i (%1.0f%s)',x{1},y,100*z,char(37)), mypietable,'OutputFormat','cell');

pie( piedata, mylegend )

%%
xlims = [0,1000]; ylims = [0,1000];
myparams = {'State1Tracks','State2Tracks','Supercluster'};
details.typeoftrack = 'only1length';
details.xlabels = 'Ntracks state 1';
details.ylabels = 'Ntracks state 2';
colors = jet( 5+numel(unique(rc_obj.consolidatedLifetimes.Supercluster)) );

rc_obj.consolidateSuperclusterLifetimes( details.typeoftrack );

fig = figure( 'color','w','userdata', rc_obj.consolidatedLifetimes(:,myparams) ) ; 
ax_ = axis(); hold on;
rowfun(@(x,y,z,obj_idx) plot(x,y,'ko','MarkerFaceColor',colors(z,:),'Tag',sprintf('SC%i',obj_idx)), rc_obj.consolidatedLifetimes(:,{'State1Tracks','State2Tracks','Supercluster','Obj_Idx'}) );
xlim(xlims);ylim(ylims);
plot(xlims,ylims,'k--')
xlabel(details.xlabels); ylabel(details.ylabels);

%set(gca,'tickdir','out')
%datacursormode on
%dcm_obj = datacursormode(fig);
%set(dcm_obj,'UpdateFcn',{@myupdatefcn_signe})
%%

figure('color','w');
details.title = 'Only 1-length state 1';
details.xlabel = '(s)';
binwidth = 0.5;
xlims = [0,50];
ylims = [0,0.3];
data = rc_obj.lifetimesTable( and( instate1, only1track ), : );
Quantity = 'Lifetime';
histogram( 0.15*data.(Quantity) , 'normalization','pdf','binwidth',binwidth);
xlabel(sprintf('%s %s',Quantity,details.xlabel));
box off; set(gca,'TickDir','out');
title(details.title);
xlim(xlims); ylim(ylims);

%%

figure('color','w');
details.title = 'Only 1-length state 2';
details.xlabel = '(s)'
binwidth = 0.5;
xlims = [0,50];
ylims = [0,0.3];
data = rc_obj.lifetimesTable( and( eq(rc_obj.lifetimesTable.State,2), eq(rc_obj.lifetimesTable.tracksInSeg,1) ), : );
Quantity = 'Lifetime';
histogram( 0.15*data.(Quantity) , 'normalization','pdf', 'binwidth', binwidth);
xlabel(sprintf('%s %s',Quantity,details.xlabel));
box off; set(gca,'TickDir','out');
title(details.title);
xlim(xlims); ylim(ylims);


%% Comparison with state 1 transitions

figure('color','w');
details.title = 'Transition tracks state 1';
details.xlabel = '(s)'
binwidth = 0.5;
xlims = [0,50];
ylims = [0,0.5];
data = rc_obj.lifetimesTable( logical(eq(rc_obj.lifetimesTable.State,1).*... 
                                      gt(rc_obj.lifetimesTable.tracksInSeg,2).*...
                                      eq(rc_obj.lifetimesTable.Identifier,0)), : );
Quantity = 'Lifetime';
histogram( 0.15*data.(Quantity) , 'normalization','pdf', 'binwidth', binwidth);
xlabel(sprintf('%s %s',Quantity,details.xlabel));
box off; set(gca,'TickDir','out');
title(details.title);
xlim(xlims); ylim(ylims);

%% State 2 transitions

figure('color','w');
details.title = 'Transition tracks state 2';
details.xlabel = '(s)'
binwidth = 0.5;
xlims = [0,50];
ylims = [0,0.8];
data = rc_obj.lifetimesTable( logical(eq(rc_obj.lifetimesTable.State,2).*... 
                                      gt(rc_obj.lifetimesTable.tracksInSeg,2).*...
                                      eq(rc_obj.lifetimesTable.Identifier,0)), : );
Quantity = 'Lifetime';
histogram( 0.15*data.(Quantity) , 'normalization','pdf', 'binwidth', binwidth);
xlabel(sprintf('%s %s',Quantity,details.xlabel));
box off; set(gca,'TickDir','out');
title(details.title);
xlim(xlims); ylim(ylims);

%% State 1 ends are shorter

figure('color','w');
details.title = 'Lifetime of last segment in track if state 1';
details.xlabel = '(s)'
binwidth = 0.5;
xlims = [0,50];
ylims = [0,0.3];
data = rc_obj.lifetimesTable( and( eq(rc_obj.lifetimesTable.State,1), eq(rc_obj.lifetimesTable.Identifier,1) ), : );
Quantity = 'Lifetime';
histogram( 0.15*data.(Quantity) , 'normalization','pdf', 'binwidth', binwidth);
xlabel(sprintf('%s %s',Quantity,details.xlabel));
box off; set(gca,'TickDir','out');
title(details.title);
xlim(xlims); ylim(ylims);


%% State 2 ends are longer

figure('color','w');
details.title = 'Lifetime of last segment in track if state 2';
details.xlabel = '(s)'
binwidth = 0.5;
xlims = [0,50];
ylims = [0,0.3];
data = rc_obj.lifetimesTable( and( eq(rc_obj.lifetimesTable.State,2), eq(rc_obj.lifetimesTable.Identifier,1) ), : );
Quantity = 'Lifetime';
histogram( 0.15*data.(Quantity) , 'normalization','pdf', 'binwidth', binwidth);
xlabel(sprintf('%s %s',Quantity,details.xlabel));
box off; set(gca,'TickDir','out');
title(details.title);
xlim(xlims); ylim(ylims);

%% Fraction of tracks that are single tracks

data = rc_obj.lifetimesTable(logical((rc_obj.lifetimesTable.tracksInSeg==1)),:);
figure('color','w'); bar( [0:24], histc( data.Supercluster, [0:24] )./histc( rc_obj.lifetimesTable.Supercluster, [0:24] ),'k' ); camroll(-90)
set(gca,'XTick', unique(rc_obj.lifetimesTable.Supercluster), 'TickDir', 'out', 'XTickLabel', rc_obj.clustersTable.Clustertext); box off;
ylabel('Fraction of tracks that are single tracks')

%% Fraction of tracks that are single tracks (in state 1)
data = rc_obj.lifetimesTable(logical((rc_obj.lifetimesTable.tracksInSeg==1).*(rc_obj.lifetimesTable.State==1)),:);
figure('color','w'); bar( [0:24], histc( data.Supercluster, [0:24] )./histc( rc_obj.lifetimesTable.Supercluster, [0:24] ),'k' ); camroll(-90)
set(gca,'XTick', unique(rc_obj.lifetimesTable.Supercluster), 'TickDir', 'out', 'XTickLabel', rc_obj.clustersTable.Clustertext); box off;
ylabel('Fraction of tracks that are single tracks in State 1')
ylim([0,1])

data = rc_obj.lifetimesTable(logical((rc_obj.lifetimesTable.tracksInSeg==1).*(rc_obj.lifetimesTable.State==2)),:);
figure('color','w'); bar( [0:24], histc( data.Supercluster, [0:24] )./histc( rc_obj.lifetimesTable.Supercluster, [0:24] ),'k' ); camroll(-90)
set(gca,'XTick', unique(rc_obj.lifetimesTable.Supercluster), 'TickDir', 'out', 'XTickLabel', rc_obj.clustersTable.Clustertext); box off;
ylabel('Fraction of tracks that are single tracks in State 2')
ylim([0,1])

%% Likelihood to be in State 1 versus State 2 if a single track

data1 = rc_obj.lifetimesTable(logical((rc_obj.lifetimesTable.tracksInSeg==1).*(rc_obj.lifetimesTable.State==1)),:);
data2 = rc_obj.lifetimesTable(logical((rc_obj.lifetimesTable.tracksInSeg==1).*(rc_obj.lifetimesTable.State==2)),:);

figure('color','w'); bar( [0:24], histc( data1.Supercluster, [0:24] )./histc( data2.Supercluster, [0:24] ),'k' ); camroll(-90)
set(gca,'XTick', unique(rc_obj.lifetimesTable.Supercluster), 'TickDir', 'out', 'XTickLabel', rc_obj.clustersTable.Clustertext); box off;
ylabel('Odds of State 1 to State 2 for a single track')
ylim([0,50])

%%
mytable = signeFolders.hmmsegs.obj_5.brownianTable
[x1,y1] = deal( rowfun(@(x) mean(x{1}), mytable.State1(:,{'hmm_xSeg'}) ),...
    rowfun(@(x) mean(x{1}), mytable.State1(:,{'hmm_ySeg'}) ));
[x2,y2] = deal( rowfun(@(x) mean(x{1}), mytable.State2(:,{'hmm_xSeg'}) ),...
    rowfun(@(x) mean(x{1}), mytable.State2(:,{'hmm_ySeg'}) ));

figure; 
subplot(1,2,1); imagesc( (1/numel(x1.Var1))*histcounts2(x1.Var1,y1.Var1,[64,64]) ); axis image; title('State 1 (all segments)')
subplot(1,2,2); imagesc( (1/numel(x2.Var1))*histcounts2(x2.Var1,y2.Var1,[64,64]) ); axis image; title('State 2 (all segments)')
%subplot(1,3,3); imagesc( histcounts2(x2.Var1,y2.Var1,[64,64])./histcounts2(x1.Var1,y1.Var1,[64,64]) ); axis image; title('Odds of State 1 versus State 2 (all segments)');

set(gcf,'position',[55,280,670,330])

%%

figure; cdfplot( rc_obj.lifetimesTable(rc_obj.lifetimesTable.Supercluster==20,:).tracksInSeg )