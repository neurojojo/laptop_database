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
