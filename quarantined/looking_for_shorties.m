%% First look at those tracks that are very short -- what kinds of particles produce them?

folders_ = signeFolders;

tracklength = table2array( rowfun( @(x) numel(x{1}), folders_.tracks.obj_1.tracksTable(:,{'x'}) ) );
minlength = 30;

shorties = find( tracklength < minlength );
locs = cell2mat( arrayfun( @(x) [fix(folders_.tracks.obj_1.tracksTable(x,:).x{1}(1));fix(folders_.tracks.obj_1.tracksTable(x,:).y{1}(1))]', shorties, 'UniformOutput', false ) );

xy = table( shorties, folders_.tracks.obj_1.tracksTable(shorties,:).trackStart, tracklength(tracklength<minlength), locs(:,1), locs(:,2), 'VariableNames', {'trackTableIdx','trackStart','trackLength','x','y'} );

%%
f = figure('color','w','WindowState','maximized');
nrows = 5; ncols = 5;
ax_ = arrayfun( @(x) subplot(5,5,x), [1:nrows*ncols]' );
zscore2 = @(x) (x-mean2(x))./std2(x);
zscore_lims = [-4,4]
pause(1)
arrayfun(@(idx) imagesc( zscore2(mymovie( xy(idx,:).y+[-10:10], xy(idx,:).x+[-10:10], xy(idx,:).trackStart )), 'parent', ax_(idx), zscore_lims ), [1:(nrows*ncols)] )
for i = 1:[nrows*ncols]; text(0,-2,sprintf('%i (%i)',xy(i,:).trackTableIdx,i),'Parent',ax_(i)); end
%arrayfun(@(idx) text(0, 0, , 'parent', ax_(idx), [0,50] ), [1:100] )

%% Make a brief movie
cd('c:\temp\')

figure; idx=34; 

v = VideoWriter(sprintf('SigneMovies_Track_%i(%i).avi', xy(idx,:).trackTableIdx, idx));
v.FrameRate = 10;
open(v);

framesbefore = 10; framesafter = 40;
themovie = mymovie( xy(idx,:).y+[-10:10], xy(idx,:).x+[-10:10], [xy(idx,:).trackStart-framesbefore:xy(idx,:).trackStart+framesafter] );
for i = 1:size(themovie,3); themovie(:,:,i) = zscore2( themovie(:,:,i) ); end

f = gcf;
f.UserData.movie = themovie;
CLim = [-2 10];

mov = 1;

if mov
    for i = [1:size(themovie,3)]

        myframe = (themovie(:,:,i));
        imagesc( myframe ); 
        title( sprintf('Frame %i',i) );
        writeVideo( v, getframe(gcf) );
        set(gca,'CLim',CLim);
        f.UserData.frameNum = i;

    end
close(v)
else
    f=figure; imagesc( themovie(:,:,1) );
    f.UserData.frameNum = 1;
end

set(gcf, 'windowscrollWheelFcn', {@mouseMove,CLim} );

%% Next look at those tracks that are very long -- what kinds of particles produce them?

tracklength = table2array( rowfun( @(x) numel(x{1}), wes_peter_folders.tracks.obj_1.tracksTable(:,{'x'}) ) );
minlength = 50;

longies = find( tracklength > minlength );
locs = cell2mat( arrayfun( @(x) [fix(wes_peter_folders.tracks.obj_1.tracksTable(x,:).x{1}(1));fix(wes_peter_folders.tracks.obj_1.tracksTable(x,:).y{1}(1))]', longies, 'UniformOutput', false ) );

xy = table( longies, wes_peter_folders.tracks.obj_1.tracksTable(longies,:).trackStart, tracklength(tracklength>minlength), locs(:,1), locs(:,2), 'VariableNames', {'trackTableIdx','trackStart','trackLength','x','y'} );
f = figure('color','w','WindowState','maximized');
ax_ = arrayfun( @(x) subplot(10,10,x), [1:100]' );

pause(1)
arrayfun(@(idx) imagesc( zscore2(mymovie( xy(idx,:).y+[-10:10], xy(idx,:).x+[-10:10], xy(idx,:).trackStart )), 'parent', ax_(idx), [-2,2] ), [1:100] )
