%% For each object, calculate occupancy of the different states
seglength_output = [];

for myobj = fields( mikeFolders.segs )'

    diffsegs = arrayfun( @(x) mikeFolders.segs.(sprintf('%s',myobj{1})).segsTable( mikeFolders.segs.(sprintf('%s',myobj{1})).segsTable.segType == x, : ), [0,1,2,3], 'UniformOutput', false );
    seglengths = arrayfun( @(y) cellfun( @(x) numel(x), diffsegs{y}.xSeg ), [1:4], 'UniformOutput', false );
    seglength_output = [ seglength_output; cellfun( @(x) sum(x), seglengths ) ];

end

occupancy = seglength_output./sum(seglength_output,2);

state = {'Immobile','Confined','Diffusing','Superdiffusing'};
myboxplot = struct();

mypalettes = {'rust','pink','greens','grays'};
close all
figure('color','w'); 
for i = 1:3
    
    colors = palette(mypalettes{i});
    mydata = occupancy(:,i);
    subplot(1,3,i);
    myboxplot = boxplot( mydata , rc_obj.subfoldersTable.Shortname ); box off;
    set(gca,'TickDir','out','NextPlot','add'); 
    boxes = findobj(gca,'Tag','Box');
    box_coords = arrayfun(@(x) [x.XData',x.YData'], boxes , 'UniformOutput', false);
    
    % Patches over the boxes
    cellfun(@(x) patch( x(:,1), x(:,2), colors(1,:) ), box_coords )
    % Capture and redraw the lines
    lines = findobj(gca,'Type','Line');
    line_coords = arrayfun(@(x) [x.XData',x.YData'], lines , 'UniformOutput', false);
    cellfun(@(x) plot( x(:,1), x(:,2), 'k-'), line_coords );
    delete(myboxplot)
    
    [~,~,scatterlbl] = unique(rc_obj.subfoldersTable.Shortname); hold on;
    scatter( scatterlbl,mydata, 'filled','jitter', 'on', 'jitteramount', 0.1, 'markerfacecolor', 'w', 'markeredgecolor', 'k' ); box off;
    ylim([0,1]);
    
    % Anova results
    [a,b] = anovan( mydata,scatterlbl,'display','off' );
    headers = cellfun(@(x) regexprep(x,'\?|\s|\.|>',''), b(1,:), 'UniformOutput', false);
    mytable = cell2table( b([2:end],:), 'VariableNames', headers' );
    [df_X1,df_Error,Fscore,pvalue] = deal( mytable( strcmp(mytable.Source,'X1'), : ).df,...
                                           mytable( strcmp(mytable.Source,'Error'), : ).df,...
                                           mytable( strcmp(mytable.Source,'X1'), : ).F{1},...
                                           mytable( strcmp(mytable.Source,'X1'), : ).ProbF{1} );
    pvalues_possible = [0.001,0.05,0.1,1]; pvalue_ = lt(pvalue, pvalues_possible); pvalue = pvalues_possible(find(pvalue_==1,1));
    % Add a title with F-score
    if pvalue<1; mytitle = sprintf('%s (F_{(%i,%i)}=%1.2f, p<%1.3f)',state{i},df_X1,df_Error,Fscore,pvalue);
    else
        mytitle = sprintf('%s (F_{(%i,%i)}=%1.2f, p>0.05)',state{i},df_X1,df_Error,Fscore);
    end
    
    title(mytitle);
    
    
end

set(gcf,'Units','normalized')
set(gcf,'position',[14,42,76,47]/100)
suptitle('Occupancy by state');


%% Relationship between I,C,D,SD
lines = palette('lines');

figure('color','w');
ax = axes('tickdir','out','nextplot','add','xlim',[0,.6],'ylim',[0,.6]);
arrayfun( @(x) plot( occupancy( ismember(rc_obj.subfoldersTable.Supercluster,x) ,1),...
        occupancy( ismember(rc_obj.subfoldersTable.Supercluster,x) ,2) , 'ko', 'markersize', 8, 'markerfacecolor', lines(x,:) ), ...
        [1:3] );
plot([0,0.6],[0,0.6],'k--');
xlabel('Immobile Occupancy'); ylabel('Confined Occupancy');
[~,b,~] = unique( rc_obj.subfoldersTable.Supercluster )
legend( rc_obj.subfoldersTable.Shortname(b) );

%% Examination of individual states (data aggregation)

output = [];
queries = {'(CD|ID)','Diffusion following confined or immobile';...
           '(D.*[C]$)','Diffusion ending in confined';...
           '(D.*[I]$)','Diffusion ending in immobile';...
           '(C.*[D]$)','Confined ending in diffusion';...
           '(I.*[D]$)','Immobile ending in diffusion';...
           '(\w[C]$)','Segment ending in confined';...
           '(\w[I]$)','Segment ending in immobile';...
           '(\w[D]$)','Segment ending in diffusion';...
           '^(I)$','Single segment immobile';...
           '^(C)$','Single segment confined';...
           '^(D)$','Single segment diffusing';...
           'I','Segment containing I';...
           'C','Segment containing C';...
           'D','Segment containing D';...
           '^(\w)$','Segments with one piece';...
           '\w{2,}','Segments with two or more pieces'};
queries_tbl = array2table( queries, 'VariableNames', {'Query','Descriptor'} );

sum_over_objects = {};
for i = 1:size( queries_tbl, 1 )
    matched_indices = cellfun( @(y) accumulator_tables.(y).dictionaryTable( find( rowfun(@(x) gt(numel( regexp(x{1}, queries_tbl(i,:).Query{1} ) ),0),...
        accumulator_tables.(y).dictionaryTable(:,1),'OutputFormat','uniform')==true), 2).Count,...
        fields( accumulator_tables ), 'UniformOutput', false );
    % Add them all up
    sum_over_objects{i} = cellfun( @(x) sum(x), matched_indices );
end

%%

for i = 1:numel( sum_over_objects )
    
    mydata = sum_over_objects{i};
    mydescription = queries_tbl(i,:).Descriptor{1};
    
    figure('color','w');
    boxplot( mydata, rc_obj.subfoldersTable.Shortname ); box off; hold on;
    [~,~,scatterlbl] = unique(rc_obj.subfoldersTable.Shortname);
    scatter( scatterlbl,...
        mydata,...
        'filled','jitter', 'on', 'jitteramount', 0.1 ); box off;
    set(gca,'TickDir','out'); 
    
    
    % Anova results
    [a,b] = anovan( mydata,scatterlbl,'display','off' );
    headers = cellfun(@(x) regexprep(x,'\?|\s|\.|>',''), b(1,:), 'UniformOutput', false);
    mytable = cell2table( b([2:end],:), 'VariableNames', headers' );
    [df_X1,df_Error,Fscore,pvalue] = deal( mytable( strcmp(mytable.Source,'X1'), : ).df,...
                                           mytable( strcmp(mytable.Source,'Error'), : ).df,...
                                           mytable( strcmp(mytable.Source,'X1'), : ).F{1},...
                                           mytable( strcmp(mytable.Source,'X1'), : ).ProbF{1} );
    pvalues_possible = [0.001,0.05,0.1,1]; pvalue_ = lt(pvalue, pvalues_possible); pvalue = pvalues_possible(find(pvalue_==1,1));
    % Add a title with F-score
    if pvalue<1; mytitle = sprintf('%s\n(F_{(%i,%i)}=%1.2f, p<%1.3f)',mydescription,df_X1,df_Error,Fscore,pvalue);
    else
        mytitle = sprintf('%s\n(F_{(%i,%i)}=%1.2f, p>0.05)',mydescription,df_X1,df_Error,Fscore);
    end
    
    title(sprintf('%s',mytitle))
    saveas(gcf,sprintf('C:/laptop_database/MHanalysis/figure_%s.svg',mydescription));
end