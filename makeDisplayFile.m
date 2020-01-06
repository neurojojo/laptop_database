function makeDisplayFile(filename,directory)

    cd(directory);
    fid = fopen(sprintf('WEBDISPLAY_%s',filename),'w');
    
    enclose = @(x) fprintf(fid,'<div class="image fit"><img src="%s"></div>',x);
    files = dir('*.svg');
    
    fprintf(fid,'<html><head><link rel="stylesheet" href="main.css" /></head><style>img {max-width:600px;max-height:600px;}</style><body><div id="main"><div class="inner"><div class="columns" id="thecolumns">'); 
    arrayfun( @(x) enclose(x.name), files );
    fprintf(fid,'</div></div></div></body></html>')
    fclose(fid);
    
end