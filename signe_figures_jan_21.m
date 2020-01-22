% Signe figures 1/21/2020


mytable = structfun( @(x) x( and( x.multiSegmentTrack_identifier==2, x.segType_combined==101 ), : ), rc_obj.mergedSegmentsTable, 'ErrorHandler', @(x,y) [0], 'UniformOutput', false);
lifetimes = structfun( @(x) mean(x.Lifetime_hmmseg), mytable, 'ErrorHandler', @(x,y) [0] , 'UniformOutput', false);
lts1 = struct2array(lifetimes)';

mytable = structfun( @(x) x( and( x.multiSegmentTrack_identifier==2, x.segType_combined==102 ), : ), rc_obj.mergedSegmentsTable, 'ErrorHandler', @(x,y) [0], 'UniformOutput', false);
lifetimes = structfun( @(x) mean(x.Lifetime_hmmseg), mytable, 'ErrorHandler', @(x,y) [0] , 'UniformOutput', false);
lts2 = struct2array(lifetimes)';

mytable = structfun( @(x) x( and( x.multiSegmentTrack_identifier==2, x.segType_combined==101 ), : ), rc_obj.mergedSegmentsTable, 'ErrorHandler', @(x,y) [0], 'UniformOutput', false);
num_segs_1 = structfun( @(x) numel(x.Lifetime_hmmseg), mytable, 'ErrorHandler', @(x,y) [0] , 'UniformOutput', false);
num_segs_1 = struct2array(num_segs_1)';


mytable = structfun( @(x) x( and( x.multiSegmentTrack_identifier==2, x.segType_combined==102 ), : ), rc_obj.mergedSegmentsTable, 'ErrorHandler', @(x,y) [0], 'UniformOutput', false);
num_segs_2 = structfun( @(x) numel(x.Lifetime_hmmseg), mytable, 'ErrorHandler', @(x,y) [0] , 'UniformOutput', false);
num_segs_2 = struct2array(num_segs_2)';

rc_obj.makeBoxplot( num_segs_1 );
rc_obj.makeBoxplot( num_segs_2 );

%% Putting together a plot


query = {{'Gi1 D2 ins4a','not quinpirole','not sulpiride'};...
         {'Gi1 D2 ins4a', 'quinpirole'};...
         {'Gi1 D2 ins4a','Sulpiride'}};
     
query = {{'2400 ng'};...
        {'Gi','not D2','not Lat'}};
    
query = {{'D2','1200 ng', 'no treat', 'not PTXR'};
    {'PTXR','1200 ng', 'no treat'}};


query = {{'Gi','D2','not ins4a', 'no treat'};...
         {'Myr'};...
         {'Gi1 D2 Quinpirole'};...
         {'Gi1 D2 PTXR Quinpirole'}};
    
query = { {'Gi','not D2','not ins4a', 'no treat'};...
          {'Gi','not D2','not ins4a', 'quinpirole'};...
          {'Gi','D2','2400'};...
          {'Myr'} };

  
