mysearch = searchObj(rc_obj, {'ins4A','Myr'} );
x = log(trackDensity)';
y = areas; 
z = perimeters;
idplot( x(mysearch.Indices), y(mysearch.Indices), z(mysearch.Indices), mysearch.Shortname, '3dplot', {'TrackDensity','area','perimeter'} )


%%

mysearch = searchObj(rc_obj, { {'ins4A'} } );
x = mysearch.summarytable.Mean_hmmseg1;
y = mysearch.summarytable.Mean_hmmseg2;
z = areas./perimeters; %log(trackDensity)';
idplot( x, y, z(mysearch.Indices), mysearch.Shortname, '3dplot', {'Mean Lifetime (Fast state)','Mean Lifetime (Slow state)','Area to perimeter ratio'} )

%%

mysearch = searchObj(rc_obj, { {'Quinpirole'},{'Sulpiride'} } );
x = mysearch.summarytable.Mean_hmmseg1;
y = mysearch.summarytable.Mean_hmmseg2;
z = areas./perimeters; %log(trackDensity)';
idplot( x, y, z(mysearch.Indices), mysearch.Shortname, 'tags', mysearch.Indices, '3dplot',...
    {'Mean Lifetime (Fast state)','Mean Lifetime (Slow state)','Area to perimeter ratio'} )


%%

%% Getting perimeter to area plots for signeFolders

areas = structfun(@(x) x.boundaryStats.Area, signeFolders.tracks, 'ErrorHandler', @(x,y) nan );
perimeters = structfun(@(x) x.boundaryStats.Perimeter, signeFolders.tracks, 'ErrorHandler', @(x,y) nan );
filtered_ratio = structfun( @(x) x.metadata.FilteredTracksRatio, signeFolders.tracks, 'ErrorHandler', @(x,y) nan );

figure; idplot( areas, perimeters, [1:numel(areas)] )