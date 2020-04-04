function mymovie = loadmovie(directory_)
    
    files = dir( sprintf('%s\\*.tif', directory_) );
    fprintf('Loading from directory %s\n', directory_ );
    
    for i = 1:numel( files )
        mymovie(:,:,i) = imread( fullfile(files(i).folder, files(i).name) );
    end

end