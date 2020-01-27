% Plotting all the segs side by side
mkdir('signe_figures_jan24')
cd('C:\laptop_database\signe_figures_jan24')

%%

for i = fields( signeFolders.segs )'
    filename = sprintf('allSegs_%s.svg',i{1})
    if and( ~isempty( signeFolders.segs.(i{1}) ), ~exist(filename) )
        if ~isempty( signeFolders.segs.(i{1}).segsTable)
            h=figure('color','w','Position',[25,370,1500,430],'visible','off');
            plot( signeFolders.segs.(i{1}) )
            saveas(h,filename);
            delete(h)
        end
    end
end