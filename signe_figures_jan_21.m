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