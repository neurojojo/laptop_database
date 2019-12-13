savedir = 'C:\MATLAB\laptop_database\laptop_database';

%% Analyze first segment is segtype 2
thisType = 2;
percent_First_seg = @(x) sum( and( (x.segsTable.segType==thisType), and( (x.segsTable.segIdx_relative==1), not(x.segsTable.nan) ) ) )/ ...
    sum( and (x.segsTable.segType==thisType, not(x.segsTable.nan) ) );

% The denominator is all HMM segments
mypcts = struct2array(structfun( percent_First_seg, signeFolders.segs, 'UniformOutput', false ));
getCluster_pcts = @(x) mypcts( rc_obj.subfoldersTable( rc_obj.subfoldersTable.Supercluster == x , : ).AbsoluteIdxToSubfolders );

mypcts_by_sc = arrayfun( getCluster_pcts, rc_obj.clustersTable.Supercluster , 'UniformOutput', false);
mypcts_by_sc_avg = cellfun( @(x) nanmean(x), mypcts_by_sc )

figure('color','w'); axis([0,25,0,1]); set(gca,'tickdir','out'); hold on;
atable = table( rc_obj.clustersTable.Supercluster, rc_obj.clustersTable.Clustertext, mypcts_by_sc, mypcts_by_sc_avg );
atable = sortrows( atable, 'Var4' ); atable.Var5 = [1:size(atable,1)]';

rowfun( @(y,x) plot( repmat(x,1,numel(y{1})), y{1}, 'ko' ) , atable(:,[3,5]) ); 
ylabel( sprintf('Fraction of HMM segments\nwhich are the first in a track') )
camroll(-90)
set(gca,'XTick', atable.Var5 ,'XTickLabel', atable.Var2 )

%% Analyze first segment is segtype 0
thisType = 0;
percent_First_seg = @(x) sum( and( (x.segsTable.segType==thisType), and( (x.segsTable.segIdx_relative==1), not(x.segsTable.nan) ) ) )/ ...
    sum( and (x.segsTable.segType==thisType, not(x.segsTable.nan) ) );

% The denominator is all HMM segments
mypcts = struct2array(structfun( percent_First_seg, signeFolders.segs, 'UniformOutput', false ));
getCluster_pcts = @(x) mypcts( rc_obj.subfoldersTable( rc_obj.subfoldersTable.Supercluster == x , : ).AbsoluteIdxToSubfolders );

mypcts_by_sc = arrayfun( getCluster_pcts, rc_obj.clustersTable.Supercluster , 'UniformOutput', false);
mypcts_by_sc_avg = cellfun( @(x) nanmean(x), mypcts_by_sc )

figure('color','w'); axis([0,25,0,1]); set(gca,'tickdir','out'); hold on;
atable = table( rc_obj.clustersTable.Supercluster, rc_obj.clustersTable.Clustertext, mypcts_by_sc, mypcts_by_sc_avg );
atable = sortrows( atable, 'Var4' ); atable.Var5 = [1:size(atable,1)]';

rowfun( @(y,x) plot( repmat(x,1,numel(y{1})), y{1}, 'ko' ) , atable(:,[3,5]) ); 
ylabel( sprintf('Fraction of Immobile segments\nwhich are the first in a track') )
camroll(-90)
set(gca,'XTick', atable.Var5 ,'XTickLabel', atable.Var2 )

%% Analyze first segment is segtype 1
thisType = 1;
percent_First_seg = @(x) sum( and( (x.segsTable.segType==thisType), and( (x.segsTable.segIdx_relative==1), not(x.segsTable.nan) ) ) )/ ...
    sum( and (x.segsTable.segType==thisType, not(x.segsTable.nan) ) );

% The denominator is all HMM segments
mypcts = struct2array(structfun( percent_First_seg, signeFolders.segs, 'UniformOutput', false ));
getCluster_pcts = @(x) mypcts( rc_obj.subfoldersTable( rc_obj.subfoldersTable.Supercluster == x , : ).AbsoluteIdxToSubfolders );

mypcts_by_sc = arrayfun( getCluster_pcts, rc_obj.clustersTable.Supercluster , 'UniformOutput', false);
mypcts_by_sc_avg = cellfun( @(x) nanmean(x), mypcts_by_sc )

figure('color','w'); axis([0,25,0,1]); set(gca,'tickdir','out'); hold on;
atable = table( rc_obj.clustersTable.Supercluster, rc_obj.clustersTable.Clustertext, mypcts_by_sc, mypcts_by_sc_avg );
atable = sortrows( atable, 'Var4' ); atable.Var5 = [1:size(atable,1)]';

rowfun( @(y,x) plot( repmat(x,1,numel(y{1})), y{1}, 'ko' ) , atable(:,[3,5]) ); 
ylabel( sprintf('Fraction of Confined segments\nwhich are the first in a track') )
camroll(-90)
set(gca,'XTick', atable.Var5 ,'XTickLabel', atable.Var2 )

%% Likelihood of being a segType 1st in a track over all segments of that type
% # of segTypes in the first place / # of segTypes in the experiment
% Must be between 0 and 1
thisType = 3;

computeLL = @(x) histc( x.segsTable( x.segsTable.segIdx_relative==1 , : ).segType, [0:3] )./sum( x.segsTable.segIdx_relative==1 );
mylls_by_idx = struct2array( structfun( computeLL, signeFolders.segs, 'UniformOutput', false ) )

getCluster_lls = @(x) mylls_by_idx( thisType+1, rc_obj.subfoldersTable( rc_obj.subfoldersTable.Supercluster == x , : ).AbsoluteIdxToSubfolders );

mylls_by_sc = arrayfun( getCluster_lls, rc_obj.clustersTable.Supercluster , 'UniformOutput', false)
mylls_by_sc_avg = cellfun( @(x) nanmean(x), mylls_by_sc )


figure('color','w'); axis([0,25,0,.5]); set(gca,'tickdir','out'); hold on;
atable = table( rc_obj.clustersTable.Supercluster, rc_obj.clustersTable.Clustertext, mylls_by_sc, mylls_by_sc_avg );
atable = sortrows( atable, 'Var4' ); atable.Var5 = [1:size(atable,1)]';

rowfun( @(y,x) plot( repmat(x,1,numel(y{1})), y{1}, 'ko' ) , atable(:,[3,5]) ); 
ylabel( sprintf('Fraction of 1st segments\nwhich are segType %i',thisType) )
camroll(-90)
set(gca,'XTick', atable.Var5 ,'XTickLabel', atable.Var2 )

%% Which segment types are more represented?

data = struct2array(structfun( @(x) histc( x.segsTable.segType,[0:3] )/numel(x.segsTable.segType) , signeFolders.segs,'UniformOutput',false));
figure('color','w');

myhandles = arrayfun( @(x) subplot(4,1,x,'xlim', [0,1]), [1:4] )
rowfun( @(x,y) histogram( y, 'parent', x, 'binwidth', 0.01 ), table( myhandles', data ) )
myhandles = arrayfun( @(x) subplot(4,1,x,'xlim', [0,1]), [1:4] )

%% When conditioned upon position
clc
segStep = 1;

data = struct2array(structfun( @(x) histc( x.segsTable.segType(x.segsTable.segIdx_relative==segStep),[0:3] )/numel(x.segsTable.segType(x.segsTable.segIdx_relative==segStep)) , signeFolders.segs,'UniformOutput',false));
figure; plot( nanmean(data, 2 ) )

% Usually segments start in Diffusion then go to Confined and back

%% What happens when segIdx_identifier == 1 (where there was only one segment)
clc

mydata = struct2array(structfun( @(x) histc( x.segsTable.segType(x.segsTable.segIdx_identifier==1),[0:3] )/numel(x.segsTable.segType(x.segsTable.segIdx_identifier==1)) , signeFolders.segs,'UniformOutput',false,'ErrorHandler',@(x,y) signeFolders.doNothing));
figure; plot( nanmean(mydata, 2 ) )

%% Condense segments into one big table

% Create a sparse 3d 
% Pre-allocation steps
non_empty_objs = find( structfun(@(x) ~isempty(x.segsTable), signeFolders.segs ) == 1 );
my_seg_total = arrayfun( @(x) numel(signeFolders.segs.(sprintf('obj_%i',x)).segsTable.segIdx) , non_empty_objs );
my_track_total = arrayfun( @(x) numel(signeFolders.segs.(sprintf('obj_%i',x)).segsTable.trackIdx) , non_empty_objs );
my_seg_identifier = cell2mat( arrayfun( @(x) signeFolders.segs.(sprintf('obj_%i',x)).segsTable.segIdx_identifier , non_empty_objs  , 'UniformOutput' , false) );
my_seg_Idx = cell2mat( arrayfun( @(x) signeFolders.segs.(sprintf('obj_%i',x)).segsTable.segIdx_identifier , non_empty_objs  , 'UniformOutput' , false) );

%%
% Expand a 2-d array
my_seg_idx_2d = cell2mat(table2array(  rowfun( @(x,y) {repmat(x,y,1)}, table(non_empty_objs, my_seg_idx)) ) );
my_track_idx_2d = cell2mat(table2array(  rowfun( @(x,y) {repmat(x,y,1)}, table(my_track_idx, my_seg_idx)) ) );
my_track_idx_2d =  cell2mat(table2array(  rowfun( @(x,y) {repmat(x,y,1)}, table(non_empty_objs, my_seg_idx)) ) );

objIdx_segIdx = table( my_track_idx, my_seg_idx_2d, my_track_idx_2d, 'VariableNames', {'AbsoluteIdxToSubfolders','absSegIdentifier','Ntracks'} );

%max_segs = max( cell2mat( struct2cell( structfun( @(x) max( double(x.segsTable.segIdx) )+1, signeFolders.segs, 'UniformOutput', false ) ) ) );


%%

% Use 3d array for hashing
% x
x = cell2mat( arrayfun( @(x) x.segsTable.trackIdx, mysubstruct, 'UniformOutput', false ) );
% y
x = cell2mat( arrayfun( @(x) x.segsTable.segIdx, mysubstruct, 'UniformOutput', false ) );
% z

%% THIS IS GOOD (1)
% Fraction of tracks yielding only one segment

%structfun(@(x) x.segsTable, signeFolders.segs )
clc

mysubstruct = arrayfun( @(x) signeFolders.segs.(sprintf('obj_%i',x)) , non_empty_objs );

output_multiple = cell2mat( struct2cell( structfun(@(x) numel(x.segsTable( and(x.segsTable.segIdx_relative==1,x.segsTable.segIdx_identifier==0) , : )), signeFolders.segs, 'UniformOutput', false, 'ErrorHandler', @(x,y) signeFolders.returnNaN(1) ) ) );
output_single = cell2mat( struct2cell( structfun(@(x) numel(x.segsTable( and(x.segsTable.segIdx_relative==1,x.segsTable.segIdx_identifier==1) , : )), signeFolders.segs, 'UniformOutput', false, 'ErrorHandler', @(x,y) signeFolders.returnNaN(1) ) ) );

% Use return NaN to avoid placing empty entries into the table
Lengths_seg_generating_tracks = table( [1:numel(output_single)]', output_single./(output_single+output_multiple), output_single, output_multiple , 'VariableNames', {'AbsoluteIdxToSubfolders', 'Fraction_single', 'Ntracks_single','Ntracks_multiple'} );

trackNumberTable = join( Lengths_seg_generating_tracks, rc_obj.diffusionTable(:,[1:3]), 'Key', 'AbsoluteIdxToSubfolders' );
trackNumberTable = sortrows( trackNumberTable, 'Fraction_single' );
trackNumberTable = sortrows( trackNumberTable, 'Shortname' );
figure('color','w'); boxplot( trackNumberTable.Fraction_single, trackNumberTable.Shortname ); set(gca,'TickDir','out'); box off; camroll(-90); ylim([0.8,1])
ylabel('Fraction of tracks yielding only one segment')

%% THIS IS GOOD (2)
% Fraction of single-segments in diffusing state

histograms_by_obj = struct2array( structfun(@(x) (1/sum(and(x.segsTable.segIdx_relative==1,x.segsTable.segIdx_identifier==1))).*histc(x.segsTable.segType( and(x.segsTable.segIdx_relative==1,x.segsTable.segIdx_identifier==1) ), [0:2]), ...
    signeFolders.segs, 'UniformOutput', false, 'ErrorHandler', @(x,y) signeFolders.returnNaN(3)' ) )';

fraction_Diffusing = table( [1:numel(output_single)]', histograms_by_obj(:,3), 'VariableNames', {'AbsoluteIdxToSubfolders','Fraction_Diffusing'} );
histogramTable = join( fraction_Diffusing, rc_obj.diffusionTable(:,[1:3]), 'Key', 'AbsoluteIdxToSubfolders' );
histogramTable = sortrows( histogramTable, 'Shortname' );

figure('color','w'); boxplot( histogramTable.Fraction_Diffusing, histogramTable.Shortname ); set(gca,'TickDir','out'); box off; camroll(-90);
ylabel('Fraction of single-segments in diffusing state')

%% THIS IS GOOD (3)
% Fraction of compound-segments in diffusing state

histograms_by_obj = struct2array( structfun(@(x) (1/sum(x.segsTable.segIdx_identifier==0)).*histc(x.segsTable.segType(x.segsTable.segIdx_identifier==0), [0:2]), ...
    signeFolders.segs, 'UniformOutput', false, 'ErrorHandler', @(x,y) signeFolders.returnNaN(3)' ) )';

fraction_Diffusing = table( [1:numel(output_single)]', histograms_by_obj(:,3), 'VariableNames', {'AbsoluteIdxToSubfolders','Fraction_Diffusing'} );
histogramTable = join( fraction_Diffusing, rc_obj.diffusionTable(:,[1:3]), 'Key', 'AbsoluteIdxToSubfolders' );
histogramTable = sortrows( histogramTable, 'Shortname' );

figure('color','w'); boxplot( histogramTable.Fraction_Diffusing, histogramTable.Shortname ); set(gca,'TickDir','out'); box off; camroll(-90);
ylabel('Fraction of compound-segments in diffusing state')

%% THIS IS GOOD (4)
% Fraction of single-segments in HMM state 1

tmp = structfun(@(x) x.segsTable.segIdx(x.segsTable.segIdx_identifier==1), ...
    signeFolders.segs, 'UniformOutput', false, 'ErrorHandler', @(x,y) signeFolders.returnNaN(3)' );

output = struct();
count=1;

for i = fields(tmp)'
    
    if and( ~isempty( signeFolders.hmmsegs.(i{1}).brownianTable ), isfield( signeFolders.hmmsegs.(i{1}).brownianTable, 'State1' ) )
        if ~isempty( signeFolders.hmmsegs.(i{1}).brownianTable.State1 )
            tbl1 = signeFolders.hmmsegs.(i{1}).brownianTable.State1( ismember( signeFolders.hmmsegs.(i{1}).brownianTable.State1.segIdx, tmp.( i{1} ) ), : );
            tbl2 = signeFolders.hmmsegs.(i{1}).brownianTable.State2( ismember( signeFolders.hmmsegs.(i{1}).brownianTable.State2.segIdx, tmp.( i{1} ) ), : );
            myidx = str2double( regexp( i{1}, '\d+', 'match' ) );
            tbl1 = [ table( repmat( myidx,size(tbl1,1),1),repmat( 1,size(tbl1,1),1) ), tbl1 ];
            tbl2 = [ table( repmat( myidx,size(tbl2,1),1),repmat( 2,size(tbl2,1),1) ), tbl2 ];
            output.(i{1}) = [tbl1;tbl2];
            output.(i{1}).Properties.VariableNames{1} = 'AbsoluteIdxToSubfolders';
            output.(i{1}).Properties.VariableNames{2} = 'State';
        end
    end

end

tmp = struct2array( structfun( @(x) [x.AbsoluteIdxToSubfolders(1);sum(x.State==1);sum(x.State==2)], output , 'UniformOutput', false) )';
states = table( tmp(:,1), tmp(:,2), tmp(:,3),...
    'VariableNames',{'AbsoluteIdxToSubfolders','State1','State2'} );

states_table = join( states, rc_obj.diffusionTable(:,[1:3]), 'Key', 'AbsoluteIdxToSubfolders' );
states_table = sortrows( states_table, 'Shortname' );

figure('color','w'); boxplot( states_table.State1./(states_table.State1+states_table.State2), states_table.Shortname ); set(gca,'TickDir','out'); box off; camroll(-90);
ylabel('Fraction of single-segments in state 1')

%% THIS IS GOOD (4)
% Fraction of compound-segments in HMM state 1

tmp = structfun(@(x) x.segsTable.segIdx(x.segsTable.segIdx_identifier==0), ...
    signeFolders.segs, 'UniformOutput', false, 'ErrorHandler', @(x,y) signeFolders.returnNaN(3)' );

output = struct();
count=1;

for i = fields(tmp)'
    
    if and( ~isempty( signeFolders.hmmsegs.(i{1}).brownianTable ), isfield( signeFolders.hmmsegs.(i{1}).brownianTable, 'State1' ) )
        if ~isempty( signeFolders.hmmsegs.(i{1}).brownianTable.State1 )
            tbl1 = signeFolders.hmmsegs.(i{1}).brownianTable.State1( ismember( signeFolders.hmmsegs.(i{1}).brownianTable.State1.segIdx, tmp.( i{1} ) ), : );
            tbl2 = signeFolders.hmmsegs.(i{1}).brownianTable.State2( ismember( signeFolders.hmmsegs.(i{1}).brownianTable.State2.segIdx, tmp.( i{1} ) ), : );
            myidx = str2double( regexp( i{1}, '\d+', 'match' ) );
            tbl1 = [ table( repmat( myidx,size(tbl1,1),1),repmat( 1,size(tbl1,1),1) ), tbl1 ];
            tbl2 = [ table( repmat( myidx,size(tbl2,1),1),repmat( 2,size(tbl2,1),1) ), tbl2 ];
            output.(i{1}) = [tbl1;tbl2];
            output.(i{1}).Properties.VariableNames{1} = 'AbsoluteIdxToSubfolders';
            output.(i{1}).Properties.VariableNames{2} = 'State';
        end
    end

end

tmp = struct2array( structfun( @(x) [x.AbsoluteIdxToSubfolders(1);sum(x.State==1);sum(x.State==2)], output , 'UniformOutput', false) )';
states = table( tmp(:,1), tmp(:,2), tmp(:,3),...
    'VariableNames',{'AbsoluteIdxToSubfolders','State1','State2'} );

states_table = join( states, rc_obj.diffusionTable(:,[1:3]), 'Key', 'AbsoluteIdxToSubfolders' );
states_table = sortrows( states_table, 'Shortname' );

figure('color','w'); boxplot( states_table.State1./(states_table.State1+states_table.State2), states_table.Shortname ); set(gca,'TickDir','out'); box off; camroll(-90);
ylabel('Fraction of compound-segments in state 1')
