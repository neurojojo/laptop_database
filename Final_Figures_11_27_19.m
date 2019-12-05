%% PARAMETERS FOR FIGURES 1-5 

close all;
minlength = 3; % All located segments are GT minlength

xlims = [0, 100]; ylims = [0, 100]; newfig=0;
remove_ends = 1; 
sorting = [3,1,2]; colors = 'blues';  %'Gi1 D2 ins4A Quinpirole'
Quantity1 = 'Lifetime1'; Quantity2 = 'Lifetime2'; figdetails = 'Lifetime_xy_';

%% Figure 1
close all;
% Use two brackets to get this to concatenate
query = {{'Gi1 D2 ins4a','not quinpirole','not sulpiride'};...
         {'Gi1 D2 ins4a', 'quinpirole'};...
         {'Gi1 D2 ins4a','Sulpiride'}};
colors = {'blues';'greens';'tans'};
sorting = [1,3,2];
% This plots the crosses
myoutput = rowfun( @(query, colors) plot_rc_obj( rc_obj, remove_ends, minlength, Quantity1, Quantity2, figdetails, xlims, ylims, sorting, colors{1}, query{1}, newfig ),...
    table( query, colors ) )

% This plots the bars
% Get a vector and plot it next to the graph at 50,50
superclusters = cellfun( @(query) multipleRegex( rc_obj.clustersTable.Clustertext, query ), query, 'UniformOutput', false )
% Apply resorting where possible
superclusters = cellfun(@(x) x(sorting), superclusters, 'ErrorHandler',@(x,y) y,'UniformOutput',false)

% Convert this to a column vector to use arrayfun operations
superclusters = cell2mat( superclusters );

%barHeights = cellfun( @(superclusters_subset) ...
%    nanmean(rc_obj.diffusionTableNaNs( ismember( rc_obj.diffusionTableNaNs.Supercluster, superclusters_subset ), : ).Occupancy1), superclusters );

barHeights = arrayfun( @(supercluster) ...
    nanmean(rc_obj.diffusionTableNaNs( ismember( rc_obj.diffusionTableNaNs.Supercluster, supercluster ), : ).Occupancy1), superclusters );

% Set up the table
%
ygain=25;
y0=65;
x0=50;
w=5;
% Setting up colors
mycolors = cell2mat( cellfun(@(x) palette(x), colors , 'UniformOutput', false) );
mycolors = mycolors([1:numel(barHeights)],:);
% Plotting bottom layer
mytable = table( x0+[0:numel(barHeights)-1]'*w, ygain*ones(numel(barHeights),1), min( mycolors*1.1, 1) );
rowfun( @(x,height,color) barObj( 'a', x, y0, w, height, gca, color ), mytable )
% Plotting top layer
mytable = table( x0+[0:numel(barHeights)-1]'*w, ygain*barHeights, mycolors );
rowfun( @(x,height,color) barObj( 'a', x, y0, w, height, gca, color ), mytable )

mytext = text( x0, y0+ygain, 'Occupancy Table', 'VerticalAlignment', 'bottom', 'horizontalalignment','left' );
myaxis = axisObj( x0, y0, ygain, 1, linspace(y0,y0+ygain,5)', num2str( linspace(0,1,5)' ) )
%mytext2 = text( x0, y0+ygain, 'State 2 ', 'VerticalAlignment','top','HorizontalAlignment','right','Rotation',0 );
%mytext2 = text( x0, y0, 'State 1 ', 'VerticalAlignment','bottom','HorizontalAlignment','right','Rotation',0 );
%% Figure 2

colors = {'blues';'reds'}; 
query = {{'2400 ng'};...
        {'Gi','not D2','not Lat'}};

rowfun( @(query, colors) plot_rc_obj( rc_obj, remove_ends, minlength, Quantity1, Quantity2, figdetails, xlims, ylims, sorting, colors{1}, query{1}, newfig ),...
    table( query, colors ) )


%% Figure 3
colors = {'blues';'reds'}; 
query = {{'D2','1200 ng', 'no treat', 'not PTXR'};
    {'PTXR','1200 ng', 'no treat'}};

rowfun( @(query, colors) plot_rc_obj( rc_obj, remove_ends, minlength, Quantity1, Quantity2, figdetails, xlims, ylims, sorting, colors{1}, query{1}, newfig ),...
    table( query, colors ) )

%% Figure 4
close all
query = {{'Gi','D2','not ins4a', 'no treat'};...
         {'Myr'};...
         {'Gi1 D2 Quinpirole'};...
         {'Gi1 D2 PTXR Quinpirole'}};
colors = {'blues';'reds';'greens';'grays'}
    
rowfun( @(query, colors) plot_rc_obj( rc_obj, remove_ends, minlength, Quantity1, Quantity2, figdetails, xlims, ylims, sorting, colors{1}, query{1}, newfig ),...
    table( query, colors ) )


% This plots the bars
% Get a vector and plot it next to the graph at 50,50
superclusters = cellfun( @(query) multipleRegex( rc_obj.clustersTable.Clustertext, query ), query, 'UniformOutput', false )
% Apply resorting where possible
superclusters = cellfun(@(x) x(sorting), superclusters, 'ErrorHandler',@(x,y) y,'UniformOutput',false)

% Convert this to a column vector to use arrayfun operations
superclusters = cell2mat( superclusters );

%barHeights = cellfun( @(superclusters_subset) ...
%    nanmean(rc_obj.diffusionTableNaNs( ismember( rc_obj.diffusionTableNaNs.Supercluster, superclusters_subset ), : ).Occupancy1), superclusters );

barHeights = arrayfun( @(supercluster) ...
    nanmean(rc_obj.diffusionTableNaNs( ismember( rc_obj.diffusionTableNaNs.Supercluster, supercluster ), : ).Occupancy1), superclusters );

% Set up the table
%
ygain=25;
y0=65;
x0=50;
w=5;
%
% Setting up colors
mycolors = cell2mat( cellfun(@(x) palette(x), colors , 'UniformOutput', false) );
mycolors = mycolors([1:numel(barHeights)],:);
% Plotting bottom layer
mytable = table( x0+[0:numel(barHeights)-1]'*w, ygain*ones(numel(barHeights),1), min( mycolors*1.1, 1) );

rowfun( @(x,height,color) barObj( 'a', x, y0, w, height, gca, color ), mytable )
% Plotting top layer
mytable = table( x0+[0:numel(barHeights)-1]'*w, ygain*barHeights, mycolors );
rowfun( @(x,height,color) barObj( 'a', x, y0, w, height, gca, color ), mytable )

mytext = text( x0, y0+ygain, 'Occupancy Table', 'VerticalAlignment', 'bottom', 'horizontalalignment','left' );
myaxis = axisObj( x0, y0, ygain, 1, linspace(y0,y0+ygain,5)', num2str( linspace(0,1,5)' ) )
%mytext2 = text( x0, y0+ygain, 'State 2 ', 'VerticalAlignment','top','HorizontalAlignment','right','Rotation',0 );
%mytext2 = text( x0, y0, 'State 1 ', 'VerticalAlignment','bottom','HorizontalAlignment','right','Rotation',0 );
%% Figure 5

close all; sorting=[];
colors = {'blues';'greens';'tans';'reds'}
query = { {'Gi','not D2','not ins4a', 'no treat'};...
          {'Gi','not D2','not ins4a', 'quinpirole'};...
          {'Gi','D2','2400'};...
          {'Myr'} };

rowfun( @(query, colors) plot_rc_obj( rc_obj, remove_ends, minlength, Quantity1, Quantity2, figdetails, xlims, ylims, sorting, colors{1}, query{1}, newfig ),...
    table( query, colors ) )

%% Figure 6

close all; sorting=[];
colors = {'blues';'greens'}
query = { {'Gi','D2','2400'};...
          {'ins4a'} };

rowfun( @(query, colors) plot_rc_obj( rc_obj, remove_ends, minlength, Quantity1, Quantity2, figdetails, xlims, ylims, sorting, colors{1}, query{1}, newfig ),...
    table( query, colors ) )

%% All occupancy stats FIGURE 1
query = {{'Gi1 D2 ins4a','not quinpirole','not sulpiride'};...
         {'Gi1 D2 ins4a', 'quinpirole'};...
         {'Gi1 D2 ins4a','Sulpiride'}};

plot_bar_obj(rc_obj,query,colors)

%% All occupancy stats FIGURE 2

query = {{'2400 ng'};...
        {'Gi','not D2','not Lat'}};

plot_bar_obj(rc_obj,query,colors)

%% Figure 5 Occ

query = { {'Gi','not D2','not ins4a', 'no treat'};...
          {'Gi','not D2','not ins4a', 'quinpirole'};...
          {'Gi','D2','2400'};...
          {'Myr'} };
      
plot_bar_obj(rc_obj,query,colors)

%% Some others
query = { {'100'} };
      
plot_bar_obj(rc_obj,query,colors)