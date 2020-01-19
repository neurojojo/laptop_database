% Signe data plotting (primarily single track trajectories)
%
% Figures showing the # of states per trajectory,
% total number of single state trajectories,
% PCA on the single states of interest (I,C,F,S = immobile, confined, fast,
% slow)
%
% Preliminary: (1) Myristolated has many more single state tracks than any
% other
% (2) ins4a allows for transitioning tracks
% (3) Single state tracks are most likely to be in 'F' state
% (4) Myristolated can be separated from other data based on the
% strength of PC1 (but not PC2)
% (5) Myristolation places tracks into 'F' state while all other tracks are
% equally likely

% Longest length segments possible
f=structfun( @(x) max(x.dictionaryTable.Length), rc_obj.sequencesTable )
rc_obj.makeBoxplot( f )
ylabel('Longest length segment possible')
print(gcf,sprintf('c:\\laptop_database\\signe_figures_jan14\\boxplot_longest_segs.svg', regexprep(this_title,'\s','_') ),'-dsvg')

%% Occurance-weighted average of # states per trajectory

f=structfun( @(x) nansum( x.dictionaryTable.Count.*x.dictionaryTable.Length )/nansum(x.dictionaryTable.Count), rc_obj.sequencesTable );
rc_obj.makeBoxplot( f );
ylabel('Occurance-weighted average of # states per trajectory')

print(gcf,sprintf('c:\\laptop_database\\signe_figures_jan14\\boxplot_occurence_weighted_average.svg', regexprep(this_title,'\s','_') ),'-dsvg')

%% The total number of single state trajectories

f=structfun( @(x) nansum( x.dictionaryTable.Count( eq(x.dictionaryTable.Length,1) ))/nansum(x.dictionaryTable.Count), rc_obj.sequencesTable );
rc_obj.makeBoxplot( f );
ylabel('Percentage of trajectories that are 1 state')

print(gcf,sprintf('c:\\laptop_database\\signe_figures_jan14\\boxplot_1state_percentage.svg', regexprep(this_title,'\s','_') ),'-dsvg')

%% The total number of non-single state trajectories

f=structfun( @(x) nansum( x.dictionaryTable.Count( gt(x.dictionaryTable.Length,1) ))/nansum(x.dictionaryTable.Count), rc_obj.sequencesTable );
rc_obj.makeBoxplot( f );
ylabel('Percentage of trajectories that are >1 state')

print(gcf,sprintf('c:\\laptop_database\\signe_figures_jan14\\boxplot_gt1state_percentage.svg', regexprep(this_title,'\s','_') ),'-dsvg')

%% What are the distributions of single state trajectories

f=structfun( @(x) sortrows( x.dictionaryTable(x.dictionaryTable.Length==1,:), 'States' ), ...
rc_obj.sequencesTable, 'UniformOutput', false );
single_states = {'C','F','G','I','N','S','V'};

to_analyze = structfun( @(x) eq(7,size(x,1)), f );
all_fields = fields( f );
myfields = all_fields( to_analyze );

counts_matrix = cell2mat( cellfun( @(x) f.(x).Count', myfields, 'UniformOutput', false ) );

% Normalize by row sum before table-izing (when it becomes impossible)
counts_matrix = bsxfun(@rdivide, counts_matrix, sum(counts_matrix,2) );
counts_tbl = array2table( counts_matrix, 'VariableNames',single_states );

% myfields as cell
myfields_cell = cell2mat( cellfun(@(x) str2double(cell2mat(regexp(x,'\d','match'))), myfields, 'UniformOutput', false) );
lbls_myfields = rc_obj.subfoldersTable( ismember( rc_obj.subfoldersTable.AbsoluteIdxToSubfolders, myfields_cell ), : ).Shortname;

figure('WindowState','Maximize'); imagesc( counts_matrix(:,[2,6,4,1]) )
set(gca,'XTick',[1:4],'XTickLabel', single_states([2,6,4,1]) ,'TickDir','out',...
    'YTick',[1:numel(lbls_myfields)],'YTickLabel',lbls_myfields,'FontSize',8,'YTickLabelRotation',90,'Position',[.02,.25,.95,.75]);
camroll(90);


%% The total number of non-single state trajectories

for i = 1:numel(single_states)
    
    f_ = nan( size( rc_obj.subfoldersTable, 1 ), 1 );
    f_( ismember( rc_obj.subfoldersTable.AbsoluteIdxToSubfolders, myfields_cell ) ) = counts_matrix(:,i);

    rc_obj.makeBoxplot( f_ );
    set(gcf,'WindowState','Maximize','Color','w');
    ylabel( sprintf('Fraction of single tracks that are %s', single_states{i} ) );
    ylim([0,.5])
    grid on
    
    filename = sprintf('c:\\laptop_database\\signe_figures_jan14\\boxplot_state_%s_percentage.svg', single_states{i} );
    print(gcf,filename,'-dsvg')

end

%% Creating a GLM based on counts_matrix as predictors
%
% This figure shows the different PCs that can then be examined for their
% value as predictors

single_states = {'C','F','G','I','N','S','V'};

y = rc_obj.subfoldersTable.Supercluster( ismember( rc_obj.subfoldersTable.AbsoluteIdxToSubfolders, myfields_cell ) );
shortnames = rc_obj.subfoldersTable.Shortname( ismember( rc_obj.subfoldersTable.AbsoluteIdxToSubfolders, myfields_cell ) );
X = counts_matrix(:,[1,2,4,6]);
[c,s,l,t,e,mu1] = pca( X );

pca_lbls = single_states([1,2,4,6]);

%[b,dev,stats] = glmfit(X(:,[1,3:7]), X(:,2));
A = counts_matrix; B = s*c' + repmat( mu1, size(s,1), 1 );

for i = 1:size(c,2)
    
    figure;
    plot(c(:,i));
    set(gca,'XTick',[1:7],'XTickLabel',pca_lbls);
    title(mu1(i))
    
end

% Remake data with only first two PC's
s0 = s;
s0(:,[3:4]) = 0;
B = s0*c' + repmat( mu1, size(s,1), 1 );

mdl=fitlm(X(:),B(:));

%% Plotting with scatter

Filenames = rc_obj.subfoldersTable.Filename( ismember( rc_obj.subfoldersTable.AbsoluteIdxToSubfolders, myfields_cell ) );

subset = cellfun( @(x) gt(numel(regexpi(x,('Myr'))),0), shortnames );
colors = jet(max(y));
figure('color','w'); scatter(s(subset,1),s(subset,2),24,colors(y(subset),:),'filled')

hold on;
subset = not(cellfun( @(x) gt(numel(regexpi(x,('Myr'))),0), shortnames ));
scatter(s(subset,1),s(subset,2),24,'filled')


f_ = nan( size( rc_obj.subfoldersTable, 1 ), 1 );
f_( ismember( rc_obj.subfoldersTable.AbsoluteIdxToSubfolders, myfields_cell ) ) = s(:,1);

rc_obj.makeBoxplot( f_ )

table( table(Filenames(subset)), s(:,1) )