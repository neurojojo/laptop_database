files = dir('*.svg');

mytitle='Figures from Jan 15, 2020'
f = fopen( 'figures2.html', 'w' );
fprintf(f,'<!doctype html><html lang="en"><head><meta charset="utf-8"><title>')
fprintf(f,'%s</title><link rel="stylesheet" href="styles.css"></head><body><h1>%s</h1>',mytitle,mytitle)
fprintf(f,'<table>')

for i = 1:numel(files)
    fprintf(f,'<tr><td><img src="%s"></td></tr>',files(i).name);
end

fprintf(f,'</table><script src="js/scripts.js"></script></body></html>');