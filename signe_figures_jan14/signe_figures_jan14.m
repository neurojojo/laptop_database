
%% If an HMM segment has a length of 1, what type of segment is it?
% Single tracks are twice as likely to be in State 1 (fast state)

this_title = 'All data (only single-segment tracks)'
scs = rc_obj.superclusters();

myltable = rc_obj.lifetimesTable( ismember( rc_obj.lifetimesTable.Supercluster, scs ), : );

% Logical for only 1 track in seg
only1track = eq(myltable.tracksInSeg,1);
instate1 = eq(myltable.State,1);
piedata = histc( myltable( only1track, : ).State, [1:2] );
mypietable = table( {'Fast','Slow'}', {'State','State'}', piedata/sum(piedata) );
mylegend = rowfun(@(x,y,z) sprintf('%s %s (%1.0f%s)',x{1},y{1},100*z,char(37)), mypietable,'OutputFormat','cell');

p = pie( piedata, mylegend )
p(1).EdgeColor = [1,1,1]
p(3).LineWidth = 3
set(gcf,'colormap',lines(2))
title( this_title )

print(gcf,sprintf('c:\\laptop_database\\signe_figures_jan14\\piechart_%s.svg', regexprep(this_title,'\s','_') ),'-dsvg')


%% If an HMM segment has a length of 1, what type of segment is it?
% Single tracks are twice as likely to be in State 1 (fast state)

this_title = 'Myristolated data (only single-segment tracks)'
scs = rc_obj.superclusters('myr');

myltable = rc_obj.lifetimesTable( ismember( rc_obj.lifetimesTable.Supercluster, scs ), : );

% Logical for only 1 track in seg
only1track = eq(myltable.tracksInSeg,1);
instate1 = eq(myltable.State,1);
piedata = histc( myltable( only1track, : ).State, [1:2] );
mypietable = table( {'Fast','Slow'}', {'State','State'}', piedata/sum(piedata) );
mylegend = rowfun(@(x,y,z) sprintf('%s %s (%1.0f%s)',x{1},y{1},100*z,char(37)), mypietable,'OutputFormat','cell');

p = pie( piedata, mylegend )
p(1).EdgeColor = [1,1,1]
p(3).LineWidth = 3
set(gcf,'colormap',lines(2))
title( this_title )

print(gcf,sprintf('c:\\laptop_database\\signe_figures_jan14\\piechart_%s.svg', regexprep(this_title,'\s','_') ),'-dsvg')

%% If an HMM segment has a length of 1, what type of segment is it?
% Single tracks are twice as likely to be in State 1 (fast state)

this_title = 'Non-Myristolated data (only single-segment tracks)'
scs = rc_obj.superclusters('myr','not');

myltable = rc_obj.lifetimesTable( ismember( rc_obj.lifetimesTable.Supercluster, scs ), : );

% Logical for only 1 track in seg
only1track = eq(myltable.tracksInSeg,1);
instate1 = eq(myltable.State,1);
piedata = histc( myltable( only1track, : ).State, [1:2] );
mypietable = table( {'Fast','Slow'}', {'State','State'}', piedata/sum(piedata) );
mylegend = rowfun(@(x,y,z) sprintf('%s %s (%1.0f%s)',x{1},y{1},100*z,char(37)), mypietable,'OutputFormat','cell');

p = pie( piedata, mylegend )
p(1).EdgeColor = [1,1,1]
p(3).LineWidth = 3
set(gcf,'colormap',lines(2))
title( this_title )

print(gcf,sprintf('c:\\laptop_database\\signe_figures_jan14\\piechart_%s.svg', regexprep(this_title,'\s','_') ),'-dsvg')

%% If an HMM segment has a length of 1, what type of segment is it?
% Single tracks are twice as likely to be in State 1 (fast state)

this_title = 'ins4a data (only single-segment tracks)'
scs = rc_obj.superclusters('ins4a');

myltable = rc_obj.lifetimesTable( ismember( rc_obj.lifetimesTable.Supercluster, scs ), : );

% Logical for only 1 track in seg
only1track = eq(myltable.tracksInSeg,1);
instate1 = eq(myltable.State,1);
piedata = histc( myltable( only1track, : ).State, [1:2] );
mypietable = table( {'Fast','Slow'}', {'State','State'}', piedata/sum(piedata) );
mylegend = rowfun(@(x,y,z) sprintf('%s %s (%1.0f%s)',x{1},y{1},100*z,char(37)), mypietable,'OutputFormat','cell');

p = pie( piedata, mylegend )
p(1).EdgeColor = [1,1,1]
p(3).LineWidth = 3
set(gcf,'colormap',lines(2))
title( this_title )

print(gcf,sprintf('c:\\laptop_database\\signe_figures_jan14\\piechart_%s.svg', regexprep(this_title,'\s','_') ),'-dsvg')


%%

mytitle = 'Only 1-length state 1 (fast)';

figure('color','w');
details.title = mytitle;
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

print(gcf,sprintf('c:\\laptop_database\\signe_figures_jan14\\histogram_%s.svg', regexprep(mytitle,'\s','_') ),'-dsvg')

%%
mytitle =  'Only 1-length state 2 (slow)';

figure('color','w');
details.title = mytitle;
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

print(gcf,sprintf('c:\\laptop_database\\signe_figures_jan14\\histogram_%s.svg', regexprep(mytitle,'\s','_') ),'-dsvg')


%% Comparison with state 1 transitions

figure('color','w');
mytitle = 'Transition tracks state 2 (slow)';
details.title = mytitle;
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

print(gcf,sprintf('c:\\laptop_database\\signe_figures_jan14\\histogram_%s.svg', regexprep(mytitle,'\s','_') ),'-dsvg')

%% State 2 transitions

figure('color','w');
mytitle = 'Transition tracks state 2 (slow)';
details.title = mytitle;
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

print(gcf,sprintf('c:\\laptop_database\\signe_figures_jan14\\histogram_%s.svg', regexprep(mytitle,'\s','_') ),'-dsvg')

%% State 1 ends are shorter

mytitle =  'Lifetime of last segment in track if state 1';

figure('color','w');
details.title = mytitle;
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

print(gcf,sprintf('c:\\laptop_database\\signe_figures_jan14\\histogram_%s.svg', regexprep(mytitle,'\s','_') ),'-dsvg')

%% State 2 ends are longer

figure('color','w');
mytitle = 'Lifetime of last segment in track if state 2';

details.title = mytitle;
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

print(gcf,sprintf('c:\\laptop_database\\signe_figures_jan14\\histogram_%s.svg', regexprep(mytitle,'\s','_') ),'-dsvg')


%% Fraction of tracks that are single tracks

mytitle = 'Fraction of tracks that are single tracks'

data = rc_obj.lifetimesTable(logical((rc_obj.lifetimesTable.tracksInSeg==1)),:);
figure('color','w'); bar( [0:24], histc( data.Supercluster, [0:24] )./histc( rc_obj.lifetimesTable.Supercluster, [0:24] ),'k' ); camroll(-90)
set(gca,'XTick', unique(rc_obj.lifetimesTable.Supercluster), 'TickDir', 'out', 'XTickLabel', rc_obj.clustersTable.Clustertext); box off;
ylabel(mytitle)

print(gcf,sprintf('c:\\laptop_database\\signe_figures_jan14\\unordered_barchart_%s.svg', regexprep(mytitle,'\s','_') ),'-dsvg')


%% Fraction of tracks that are single tracks (in state 1)

mytitle = 'Fraction of tracks that are single tracks in State 1';

data = rc_obj.lifetimesTable(logical((rc_obj.lifetimesTable.tracksInSeg==1).*(rc_obj.lifetimesTable.State==1)),:);
figure('color','w'); bar( [0:24], histc( data.Supercluster, [0:24] )./histc( rc_obj.lifetimesTable.Supercluster, [0:24] ),'k' ); camroll(-90)
set(gca,'XTick', unique(rc_obj.lifetimesTable.Supercluster), 'TickDir', 'out', 'XTickLabel', rc_obj.clustersTable.Clustertext); box off;
ylabel(mytitle)
ylim([0,1])

print(gcf,sprintf('c:\\laptop_database\\signe_figures_jan14\\unordered_barchart_%s.svg', regexprep(mytitle,'\s','_') ),'-dsvg')



%%
mytitle = 'Fraction of tracks that are single tracks in State 2';

data = rc_obj.lifetimesTable(logical((rc_obj.lifetimesTable.tracksInSeg==1).*(rc_obj.lifetimesTable.State==2)),:);
figure('color','w'); bar( [0:24], histc( data.Supercluster, [0:24] )./histc( rc_obj.lifetimesTable.Supercluster, [0:24] ),'k' ); camroll(-90)
set(gca,'XTick', unique(rc_obj.lifetimesTable.Supercluster), 'TickDir', 'out', 'XTickLabel', rc_obj.clustersTable.Clustertext); box off;
ylabel(mytitle)
ylim([0,1])


print(gcf,sprintf('c:\\laptop_database\\signe_figures_jan14\\unordered_barchart_%s.svg', regexprep(mytitle,'\s','_') ),'-dsvg')


%% Likelihood to be in State 1 versus State 2 if a single track

mytitle = 'Likelihood to be in State 1 versus State 2 if a single track'

data1 = rc_obj.lifetimesTable(logical((rc_obj.lifetimesTable.tracksInSeg==1).*(rc_obj.lifetimesTable.State==1)),:);
data2 = rc_obj.lifetimesTable(logical((rc_obj.lifetimesTable.tracksInSeg==1).*(rc_obj.lifetimesTable.State==2)),:);

figure('color','w'); bar( [0:24], histc( data1.Supercluster, [0:24] )./histc( data2.Supercluster, [0:24] ),'k' ); camroll(-90)
set(gca,'XTick', unique(rc_obj.lifetimesTable.Supercluster), 'TickDir', 'out', 'XTickLabel', rc_obj.clustersTable.Clustertext); box off;
ylabel(mytitle)
ylim([0,10])

print(gcf,sprintf('c:\\laptop_database\\signe_figures_jan14\\unordered_barchart_%s.svg', regexprep(mytitle,'\s','_') ),'-dsvg')

%% Markov analysis

letters = ['F';'S';'I';'C';'G';'N';'V'];




