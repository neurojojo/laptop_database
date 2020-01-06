function mytitle = makeANOVAtitle( mydata, labels, mydescription )

    % Anova results
    [a,b] = anovan( mydata,labels,'display','off' );
    headers = cellfun(@(x) regexprep(x,'\_|\?|\s|\.|>',''), b(1,:), 'UniformOutput', false);
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
    
end