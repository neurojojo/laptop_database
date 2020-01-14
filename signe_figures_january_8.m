%% Multiple track trajectory analysis
%
% Possible queries are 'CF','CS','CI','IF','IS','IC'
%
% (1) Most discriminating transitions are from C->S and I->S, the ins4a nearly doubles
% Myr and other controls
% (2) C->F and C->I are similarly likely
% (3) Going from I->C is almost 3x as likely as C->I

query = 'IS';

for this_field = fields(rc_obj.sequencesTable)'
    tmp = rc_obj.sequencesTable.(this_field{1}).dictionaryTable;
    tmp_ = rowfun( @(states,count,length) regexp(states,query), tmp, 'OutputFormat', 'uniform' );
    norm_  = rowfun( @(states,count,length) regexp(states,query(1)), tmp, 'OutputFormat', 'uniform' );
    
    occurances.(this_field{1}) = sum(tmp( logical(cellfun(@(x) numel(x), tmp_)), : ).Count)/...
                                    sum(tmp( logical(cellfun(@(x) numel(x), norm_)), : ).Count);
    
end

f = struct2array( occurances )';
rc_obj.makeBoxplot(f)
ylabel( sprintf('Transition from %s to %s\n(normalized to all %s)',query(1),query(2),query(1)) );